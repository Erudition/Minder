module Replicated.Op.Op exposing (ClosedChunk, FrameChunk, Op(..), OpPattern(..), OpPayloadAtom(..), OpPayloadAtoms, OpenTextOp, OpenTextRonFrame, ReducerID, Reference(..), RonFormat(..), atomToJsonValue, atomToRonString, closedChunksToFrameText, closedOpToString, create, id, initObject, object, pattern, payload, payloadToJsonValue, reducer, reference, ronParser)

{-| Just Ops - already-happened events and such. Ignore Frames for now, they are "write batches" so once they're written they will slef-concatenate in the list of Ops.
-}

import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Parser exposing ((|.), (|=), Parser, float, spaces, succeed, symbol)
import Replicated.Op.OpID as OpID exposing (ObjectID, OpID)
import Result.Extra
import Set exposing (Set)
import SmartTime.Moment as Moment


type Op
    = Op ClosedOp


type alias ClosedOp =
    { reducerID : ReducerID
    , objectID : ObjectID
    , operationID : OpID
    , reference : Reference
    , payload : OpPayloadAtoms
    }



-- PARSERS


ronParser : Parser (List OpenTextRonFrame)
ronParser =
    let
        frameHelp : List OpenTextRonFrame -> Parser (Parser.Step (List OpenTextRonFrame) (List OpenTextRonFrame))
        frameHelp framesReversed =
            Parser.oneOf
                [ succeed (\frame -> Parser.Loop (frame :: framesReversed))
                    |= frameParser
                    |. spaces
                , succeed ()
                    -- make sure we've consumed all input
                    |> Parser.map (\_ -> Parser.Done (List.reverse framesReversed))
                ]
    in
    Parser.loop [] frameHelp


frameParser : Parser OpenTextRonFrame
frameParser =
    let
        chunks : Parser FrameChunk
        chunks =
            Parser.loop [] opsInChunk

        opsInChunk : List OpenTextOp -> Parser (Parser.Step (List OpenTextOp) FrameChunk)
        opsInChunk opsReversed =
            case Maybe.andThen .endOfChunk (List.head opsReversed) of
                Nothing ->
                    opLineParserChainLoop opsReversed

                Just chunkEndType ->
                    succeed ()
                        |> Parser.map (\_ -> Debug.log "FINISHED PARSING CHUNK\n" <| Parser.Done (FrameChunk (List.reverse opsReversed) chunkEndType))

        opLineParserChainLoop opsReversed =
            let
                lastSeenOp =
                    List.head opsReversed

                parseLineWithContext =
                    opLineParser (Maybe.map .opID lastSeenOp) (Maybe.map .reference lastSeenOp)
            in
            succeed (\thisOp -> Parser.Loop (thisOp :: opsReversed))
                |. spaces
                |= parseLineWithContext
                |. sameLineSpaces

        chunksInFrame : List FrameChunk -> Parser (Parser.Step (List FrameChunk) (List FrameChunk))
        chunksInFrame chunksReversed =
            Parser.oneOf
                [ succeed (\thisChunk -> Parser.Loop (thisChunk :: chunksReversed))
                    |= chunks
                    |. spaces
                , succeed ()
                    |. symbol "."
                    |> Parser.map (\_ -> Parser.Done (List.reverse chunksReversed))
                ]
    in
    succeed OpenTextRonFrame
        |= Parser.loop [] chunksInFrame


type alias FrameChunk =
    { ops : List OpenTextOp, terminator : FrameChunkType }


type alias ClosedChunk =
    List Op


type FrameChunkType
    = EventChunk -- 3.0: FACT
    | AssertionChunk -- 3.0 CLAIM
    | QueryChunk -- 3.0: QUERY


type alias OpenTextRonFrame =
    { chunks : List FrameChunk
    }


{-| RON: "Open notation is just a shorted version of closed one. Reducer id and object id are omitted in this case, as those could be deduced from full DB and reference id."

The ChainSpanOpenOp is part of a Chain Span, from which it infers its OpID (spans have incremental OpIDs).

-}
type alias OpenTextOp =
    { reducerSpecified : Maybe ReducerID
    , objectSpecified : Maybe ObjectID
    , opID : OpID
    , reference : Reference
    , payload : OpPayloadAtoms
    , endOfChunk : Maybe FrameChunkType
    }


opLineParser : Maybe OpID -> Maybe Reference -> Parser OpenTextOp
opLineParser prevOpIDMaybe prevRefMaybe =
    let
        opRefparser =
            succeed identity
                |. symbol ":"
                |= Parser.oneOf
                    [ succeed (ReducerReference "lww")
                        |. Parser.keyword "lww"
                    , succeed (ReducerReference "replist")
                        |. Parser.keyword "replist"
                    , succeed OpReference
                        |= OpID.parser
                    ]

        reducerIDParser : Parser ReducerID
        reducerIDParser =
            Parser.getChompedString (Parser.chompWhile Char.isAlpha)
                |> Parser.andThen (\reducerID -> succeed reducerID)

        optionalReducerIDParser =
            Parser.oneOf
                [ Parser.map Just <|
                    succeed identity
                        |. symbol "*"
                        |= reducerIDParser
                , succeed Nothing
                ]

        optionalObjectIDParser =
            Parser.oneOf
                [ Parser.map Just <|
                    succeed identity
                        |. symbol "#"
                        |= OpID.parser
                , succeed Nothing
                ]

        optionalOpIDParser =
            case prevOpIDMaybe of
                Just prevOpID ->
                    Parser.oneOf
                        [ succeed identity
                            |. symbol "@"
                            |= OpID.parser
                        , succeed (OpID.nextOpInChain prevOpID)
                        ]

                Nothing ->
                    succeed identity
                        |. symbol "@"
                        |= OpID.parser

        optionalRefParser =
            case prevOpIDMaybe of
                Just prevOpID ->
                    Parser.oneOf
                        [ opRefparser
                        , Parser.map OpReference <| succeed prevOpID
                        ]

                _ ->
                    opRefparser

        opPayloadParser : List OpPayloadAtom -> Parser (Parser.Step OpPayloadAtoms OpPayloadAtoms)
        opPayloadParser atomsReversed =
            Parser.oneOf
                [ succeed (\thisAtom -> Parser.Loop (thisAtom :: atomsReversed))
                    -- This MUST fail if no alphaNumeric char (or _) or quote, to allow line to end
                    |= payloadAtomParser
                , succeed (\_ -> Parser.Loop atomsReversed)
                    -- This MUST fail if no spaces, to allow line to end (avoid chompWhile infinite loop problem)
                    |= Parser.chompIf (\c -> c == ' ' || c == '\t' || c == '\u{000D}')
                , succeed ()
                    |> Parser.map (\_ -> Parser.Done (List.reverse atomsReversed))
                ]

        lineEndParser =
            Parser.oneOf
                [ succeed Nothing
                    |. symbol ","
                , succeed (Just EventChunk)
                    |. symbol ";"
                , succeed (Just AssertionChunk)
                    |. symbol "!"
                , succeed (Just QueryChunk)
                    |. symbol "?"
                ]
    in
    succeed OpenTextOp
        |= optionalReducerIDParser
        |. sameLineSpaces
        |= optionalObjectIDParser
        |. sameLineSpaces
        |= optionalOpIDParser
        |. sameLineSpaces
        |= optionalRefParser
        |. sameLineSpaces
        |= Parser.loop [] opPayloadParser
        -- TODO don't parse payload on header ops?
        |= lineEndParser


payloadAtomParser : Parser OpPayloadAtom
payloadAtomParser =
    Parser.oneOf
        [ explicitRonPointer
        , ronInt
        , ronFloat
        , nakedStringTag -- can interpret nums
        , quotedString
        ]


{-| Parses RON atoms without quotes (like abc123) into strings, with the same restrictions as elm record field names. Only for letter-number "tags" such as field names -- all other strings must be quoted!
May NOT start with a digit.
-}
nakedStringTag : Parser OpPayloadAtom
nakedStringTag =
    let
        letterNumbersUnderscore char =
            Char.isAlphaNum char || char == '_'
    in
    Parser.map NakedStringAtom <|
        Parser.getChompedString <|
            succeed ()
                -- chompWhile always succeeds, we need this to fail on empty
                |. Parser.chompIf letterNumbersUnderscore
                |. Parser.chompWhile letterNumbersUnderscore


{-| Ron Integers start with equal sign =1099
When unambiguous, prefixes could be omitted
-}
ronInt : Parser OpPayloadAtom
ronInt =
    Parser.number
        { int = Just IntegerAtom
        , hex = Nothing
        , octal = Nothing
        , binary = Nothing
        , float = Nothing
        }


{-| Ron Integers start ^: ^3.14159, ^2.9979E5.
When unambiguous, prefixes could be omitted
-}
ronFloat : Parser OpPayloadAtom
ronFloat =
    -- TODO parse prefix
    Parser.number
        { int = Nothing
        , hex = Nothing
        , octal = Nothing
        , binary = Nothing
        , float = Just FloatAtom
        }


{-| Ron Integers start ^: ^3.14159, ^2.9979E5.
When unambiguous, prefixes could be omitted
-}
explicitRonPointer : Parser OpPayloadAtom
explicitRonPointer =
    succeed IDPointerAtom
        |. Parser.token ">"
        |= OpID.parser


quotedString : Parser OpPayloadAtom
quotedString =
    succeed StringAtom
        |. Parser.token "'"
        |= Parser.loop [] quotedStringHelp


quotedStringHelp : List String -> Parser (Parser.Step (List String) String)
quotedStringHelp piecesReversed =
    Parser.oneOf
        [ succeed (\_ -> Parser.Loop ("\\'" :: piecesReversed))
            |= Parser.keyword "\\'"

        -- ^When we detect an escaped quote, don't stop parsing this atom
        , succeed (\_ -> Parser.Done (String.join "" (List.reverse piecesReversed)))
            |= Parser.token "'"
        , Parser.chompWhile isUninteresting
            |> Parser.getChompedString
            |> Parser.map (\chunk -> Parser.Loop (chunk :: piecesReversed))
        ]


isUninteresting : Char -> Bool
isUninteresting char =
    char /= '\\' && char /= '\''


sameLineSpaces : Parser ()
sameLineSpaces =
    Parser.chompWhile (\c -> c == ' ' || c == '\t' || c == '\u{000D}')



-- CLOSED OP PARTS


type Reference
    = OpReference OpID
    | ReducerReference ReducerID


referenceToString : Reference -> String
referenceToString givenRef =
    case givenRef of
        OpReference opID ->
            OpID.toString opID

        ReducerReference reducerID ->
            reducerID


opIDFromReference : Reference -> Maybe OpID
opIDFromReference givenRef =
    case givenRef of
        OpReference opID ->
            Just opID

        _ ->
            Nothing


type alias OpPayloadAtoms =
    -- TODO make Nonempty?
    List OpPayloadAtom


type OpPayloadAtom
    = NakedStringAtom String
    | StringAtom String
    | IDPointerAtom OpID
    | OtherUUIDAtom String
    | IntegerAtom Int
    | FloatAtom Float


payloadToJsonValue : Nonempty OpPayloadAtom -> JE.Value
payloadToJsonValue (Nonempty head tail) =
    case tail of
        [] ->
            atomToJsonValue head

        multiple ->
            JE.list identity (List.map atomToJsonValue (head :: multiple))


atomToJsonValue : OpPayloadAtom -> JE.Value
atomToJsonValue atom =
    case atom of
        NakedStringAtom string ->
            JE.string string

        StringAtom string ->
            JE.string string

        IDPointerAtom opID ->
            JE.string (OpID.toPointerString opID)

        OtherUUIDAtom uuid ->
            JE.string uuid

        IntegerAtom int ->
            JE.int int

        FloatAtom float ->
            JE.float float


{-| Convert an atom into the raw string to be put in a RON Op.
TODO : generate naked atoms when unambiguous.
-}
atomToRonString : OpPayloadAtom -> String
atomToRonString atom =
    case atom of
        NakedStringAtom string ->
            string

        StringAtom string ->
            "'" ++ string ++ "'"

        OtherUUIDAtom string ->
            string

        IDPointerAtom opID ->
            OpID.toPointerString opID

        IntegerAtom int ->
            String.fromInt int

        FloatAtom float ->
            String.fromFloat float


jsonValueToAtom : JE.Value -> OpPayloadAtom
jsonValueToAtom valueJE =
    -- --                atomToValue inputString =
    --                     case JD.decodeString JD.value ("\"" ++ inputString ++ "\"") of
    --                         Ok val ->
    --                             val
    --
    --                         Err err ->
    --                             Debug.todo <| "couldn't convert atom (" ++ inputString ++ ") to JD.Value - " ++ Debug.toString err
    StringAtom (JE.encode 0 valueJE)


type alias ReducerID =
    String


type OpPattern
    = NormalOp
    | DeletionOp
    | UnDeletionOp
    | CreationOp
    | Acknowledgement
    | Annotation


pattern : Op -> OpPattern
pattern (Op opRecord) =
    case ( OpID.isReversion opRecord.operationID, Maybe.map OpID.isReversion (opIDFromReference opRecord.reference) ) of
        ( False, Just False ) ->
            -- "+", "+"
            NormalOp

        ( True, Just False ) ->
            -- "-", "+"
            DeletionOp

        ( True, Just True ) ->
            -- "-", "-"
            UnDeletionOp

        ( False, Nothing ) ->
            -- "+", "$"
            CreationOp

        ( False, Just True ) ->
            -- "+", "-"
            Acknowledgement

        _ ->
            -- "$", "+" or "$", "-"
            Annotation


type alias Frame =
    Nonempty Op


create : ReducerID -> OpID.ObjectID -> OpID -> Reference -> OpPayloadAtoms -> Op
create givenReducer givenObject opID givenReference givenPayload =
    let
        finalReference =
            if givenReference == OpReference opID then
                Debug.log "giving op reference to its own ID!!!!" givenReference

            else
                givenReference
    in
    Op
        { reducerID = givenReducer
        , objectID = givenObject
        , operationID = opID
        , reference = finalReference
        , payload = givenPayload
        }


initObject : ReducerID -> OpID -> Op
initObject givenReducer opID =
    Op
        { reducerID = givenReducer
        , objectID = opID
        , operationID = opID
        , reference = ReducerReference givenReducer
        , payload = []
        }


reference (Op op) =
    op.reference


reducer (Op op) =
    op.reducerID


payload (Op op) =
    op.payload


id (Op op) =
    op.operationID


object (Op op) =
    op.objectID


type RonFormat
    = ClosedOps
    | OpenOps
    | CompressedOps (Maybe Op)


closedOpToString : RonFormat -> Op -> String
closedOpToString format (Op op) =
    let
        reducerID =
            "*" ++ op.reducerID

        objectID =
            "#" ++ OpID.toString op.objectID

        opID =
            "@" ++ OpID.toString op.operationID

        ref =
            ":" ++ referenceToString op.reference

        encodePayloadAtom atom =
            JE.encode 0 atom

        inclusionList =
            case format of
                ClosedOps ->
                    [ reducerID, objectID, opID, ref ]

                OpenOps ->
                    [ opID, ref ]

                CompressedOps Nothing ->
                    [ opID, ref ]

                CompressedOps (Just (Op previousOp)) ->
                    case ( OpID.isIncremental previousOp.operationID op.operationID, op.reference == OpReference previousOp.operationID ) of
                        ( True, True ) ->
                            [ "    ", "    " ]

                        ( True, False ) ->
                            [ "    ", ref ]

                        ( False, True ) ->
                            [ opID, "    " ]

                        ( False, False ) ->
                            [ opID, ref ]
    in
    String.join " " (inclusionList ++ List.map atomToRonString op.payload)



-- closedOpFromString : String -> Maybe Op -> Result String Op
-- closedOpFromString inputString previousOpMaybe =
--     let
--         inputChunks =
--             inputString
--                 |> String.split "\""
--
--         -- headerAtoms =
--         --     inputChunks
--         --         |> List.head
--         --         |> Maybe.map String.words
--         --         |> Maybe.withDefault []
--         atoms =
--             inputChunks
--                 |> List.indexedMap
--                     (\i s ->
--                         if modBy (i + 1) 2 == 0 then
--                             [ s ]
--
--                         else
--                             String.words s
--                     )
--                 |> List.concat
--
--         opIDatom =
--             List.head (List.filter (String.startsWith "@") atoms)
--
--         extractOpID atom =
--             OpID.fromString (String.dropLeft 1 atom)
--
--         opIDMaybe =
--             Maybe.withDefault (Maybe.map (id >> OpID.nextOpInChain) previousOpMaybe) (Maybe.map extractOpID opIDatom)
--
--         referenceAtom =
--             List.head (List.filter (String.startsWith ":") atoms)
--
--         referenceMaybe =
--             -- if reference is missing, it is assumed to be the previous Op's ID
--             Maybe.withDefault (Maybe.map id previousOpMaybe) (Maybe.map extractOpID referenceAtom)
--
--         otherAtoms =
--             List.Extra.filterNot (\atom -> String.startsWith ":" atom || String.startsWith "@" atom) atoms
--
--         remainderPayload =
--             let
--                 atomAsJEValue atomString =
--                     JD.decodeString JD.value atomString
--                         |> Result.toMaybe
--             in
--             List.filterMap atomAsJEValue otherAtoms
--
--         reducerSpecified =
--             case ( referenceAtom, previousOpMaybe ) of
--                 -- TODO check an actual list of known reducers
--                 ( Just ":lww", _ ) ->
--                     Just "lww"
--
--                 ( Just ":replist", _ ) ->
--                     Just "replist"
--
--                 ( _, Just previousOp ) ->
--                     Just (reducer previousOp)
--
--                 ( _, Nothing ) ->
--                     -- TODO Check the database. for now assume lww
--                     Just "lww"
--
--         resultWithReducer givenReducer =
--             case ( opIDMaybe, otherAtoms, referenceMaybe ) of
--                 ( Just opID, [], _ ) ->
--                     -- no payload - must be a creation op
--                     Ok (create givenReducer opID opID (ReducerReference givenReducer) [])
--
--                 ( Just opID, _, Just ref ) ->
--                     -- there's a payload - reference is required
--                     case Maybe.map object previousOpMaybe of
--                         Just objectLastTime ->
--                             Ok (create givenReducer objectLastTime opID (OpReference ref) remainderPayload)
--
--                         Nothing ->
--                             -- TODO locate object via tree somehow
--                             Err <| "Couldn't determine the object this op applies to: " ++ inputString
--
--                 ( Just _, _, Nothing ) ->
--                     Err <| "This op has a nonempty payload (not a creation op) but I couldn't find the required *reference* atom (:) and got no prior op in the chain to deduce it from: " ++ inputString
--
--                 ( Nothing, _, _ ) ->
--                     Err <| "Couldn't find Op's ID (@) and got no prior op to deduce it from. Input String: “" ++ inputString ++ "”"
--     in
--     case reducerSpecified of
--         Just foundReducer ->
--             resultWithReducer foundReducer
--
--         Nothing ->
--             Err <| "No reducer found for op: " ++ inputString
-- {-| A span is [or is part of] a chain (sequential refs) with sequential IDs as well.
--
-- Here we pass in the previously parsed Op (when available) to parsing of the next op, so we may derive its ID implicitly
--
-- -}
--
--
-- fromSpan : String -> Result String (List Op)
-- fromSpan span =
--     let
--         spanOpLines =
--             String.split ",\n" span
--                 |> List.filterMap dropBlank
--
--         dropBlank line =
--             case String.trim line of
--                 "" ->
--                     Nothing
--
--                 notEmpty ->
--                     Just notEmpty
--
--         addToOpList : List String -> Result String (List Op) -> Result String (List Op)
--         addToOpList unparsedOpList parsedOpListResult =
--             -- Definitely a more efficient FP way to do this
--             case ( unparsedOpList, parsedOpListResult ) of
--                 ( _, Err err ) ->
--                     -- we crashed somewhere.
--                     Err err
--
--                 ( [], _ ) ->
--                     -- nothing to parse.
--                     Ok []
--
--                 ( [ unparsedOp ], Ok [] ) ->
--                     -- not started yet, one item to parse
--                     Result.map List.singleton (closedOpFromString unparsedOp Nothing)
--
--                 ( nextUnparsedOp :: remainingUnparsedOps, Ok [] ) ->
--                     -- not started yet, multiple items to parse
--                     addToOpList remainingUnparsedOps (Result.map List.singleton (closedOpFromString nextUnparsedOp Nothing))
--
--                 ( [ unparsedOp ], Ok [ parsedOp ] ) ->
--                     -- one down, one to go
--                     Result.map (\new -> new :: [ parsedOp ]) (closedOpFromString unparsedOp (Just parsedOp))
--
--                 ( nextUnparsedOp :: remainingUnparsedOps, Ok ((lastParsedOp :: _) as parsedOps) ) ->
--                     -- multiple done, multiple remain
--                     -- parsedOps is reversed, it's more efficient to grab a list head than the last item
--                     addToOpList remainingUnparsedOps <| Result.map (\new -> new :: parsedOps) (closedOpFromString nextUnparsedOp (Just lastParsedOp))
--
--         finalList =
--             -- recursively move from one list to the other
--             -- second list is backwards for performance (ostensibly)
--             addToOpList spanOpLines (Ok [])
--     in
--     -- TODO does having it reversed defeat the point of building it backwards?
--     Result.map List.reverse finalList
-- {-| TODO determine when a chain is not a single span
-- -}
-- fromChain : String -> Result String (List Op)
-- fromChain chain =
--     fromSpan chain
-- {-| TODO determine when a chunk is not a single chain
-- -}
-- fromChunk : String -> Result String (List Op)
-- fromChunk chunk =
--     fromChain chunk
-- {-| A frame can have multiple chunks
-- -}
-- fromFrame : String -> Result String (List Op)
-- fromFrame frame =
--     let
--         chunks =
--             String.split " ;" frame
--     in
--     Result.map List.concat <| Result.Extra.combineMap fromChunk chunks
-- {-| A log can have multiple frames
-- -}
-- fromLog : String -> Result String (List Op)
-- fromLog log =
--     let
--         frames =
--             String.split "." log
--     in
--     Result.map List.concat <| Result.Extra.combineMap fromChunk frames


type alias FrameString =
    String


closedChunksToFrameText : List ClosedChunk -> FrameString
closedChunksToFrameText chunkList =
    let
        perChunk opsInChunk =
            List.Extra.mapAccuml perOp Nothing opsInChunk
                |> Tuple.second
                |> String.join " ,\n"
                |> (\s -> s ++ " ;\n\n")

        perOp prevOpMaybe thisOp =
            ( Just thisOp, closedOpToString (CompressedOps prevOpMaybe) thisOp )
    in
    List.map perChunk chunkList
        |> String.concat
        |> (\s -> s ++ ".\n")
