module Replicated.Op.Op exposing (ClosedChunk, Context(..), FrameChunk, Op(..), OpPattern(..), OpPayloadAtom(..), OpPayloadAtoms, OpenTextOp, OpenTextRonFrame, Problem(..), ReducerID, Reference(..), RonFormat(..), atomToJsonValue, atomToRonString, closedChunksToFrameText, closedOpToString, contextStackToString, create, id, initObject, object, pattern, payload, payloadToJsonValue, problemToString, reducer, reference, ronParser)

{-| Just Ops - already-happened events and such. Ignore Frames for now, they are "write batches" so once they're written they will slef-concatenate in the list of Ops.
-}

import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Parser.Advanced as Parser exposing ((|.), (|=), Token(..), float, inContext, succeed, symbol)
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



-- PARSER LIBRARY


type alias RonParser a =
    Parser.Parser Context Problem a


type Context
    = ParsingOp (Maybe OpID)
    | ParsingOpID
    | ParsingChunk
    | ParsingFrame
    | ParsingPayloadAtom


contextToString : Context -> String
contextToString context =
    case context of
        ParsingOp (Just expectedOpID) ->
            "an Op (with expected ID " ++ OpID.toString expectedOpID ++ ")"

        ParsingOp Nothing ->
            "an Op (no prior op to deduce ID)"

        ParsingOpID ->
            "an Op ID"

        ParsingChunk ->
            "a chunk"

        ParsingFrame ->
            "a frame"

        ParsingPayloadAtom ->
            "a payload atom"


contextStackToString : List { row : Int, col : Int, context : Context } -> String
contextStackToString contextStack =
    let
        contextItemToString { row, col, context } =
            contextToString context ++ " (r" ++ String.fromInt row ++ ",c" ++ String.fromInt col ++ ") "
    in
    List.map contextItemToString contextStack
        |> String.join ", inside "


type Problem
    = ExpectingChunkEnd
    | ExpectingFrameEnd
    | ExpectingSpecReferenceAtom
    | ExpectingSpecReducerIDAtom
    | ExpectingSpecOpIDAtom
    | ExpectingSpecObjectIDAtom
    | ExpectingReducerName
    | ExpectingOpSeparator
    | ExpectingAlphaNumUnderscoreParens
    | ExpectingIntegerAtom
    | ExpectingFloatAtom
    | InvalidIntegerAtom
    | InvalidFloatAtom
    | ExpectingUUID
    | ExpectingQuotedString
    | ExpectingEscapedSingleQuote
    | ExpectedEndOfInput
    | ExpectingIDClock
    | InvalidIDClock
    | ExpectingNodeID
    | ExpectingVersionSymbol
    | ExpectingComment
    | InfiniteLoop


problemToString : Problem -> String
problemToString problem =
    case problem of
        ExpectingChunkEnd ->
            "Expecting end of chunk"

        ExpectingFrameEnd ->
            "Expecting end of frame (.)"

        ExpectingSpecReferenceAtom ->
            "Expecting a spec reference atom (:)"

        ExpectingSpecReducerIDAtom ->
            "Expecting a spec reducer ID atom (*)"

        ExpectingSpecOpIDAtom ->
            "Expecting a spec op ID atom (@)"

        ExpectingSpecObjectIDAtom ->
            "Expecting a spec object ID atom (#)"

        ExpectingReducerName ->
            "Expecting a known reducer name (lww, replist, ...)"

        ExpectingOpSeparator ->
            "Expecting an op separator (,)"

        ExpectingAlphaNumUnderscoreParens ->
            "Expecting an alphanumeric character (or underscore)"

        ExpectingIntegerAtom ->
            "Expecting an integer atom"

        ExpectingFloatAtom ->
            "Expecting a float atom"

        InvalidIntegerAtom ->
            "Integer atom was not valid"

        InvalidFloatAtom ->
            "Float atom was not valid"

        ExpectingUUID ->
            "Expecting a RON UUID atom (>)"

        ExpectingQuotedString ->
            "Expecting a quoted string (')"

        ExpectingEscapedSingleQuote ->
            "Expecting an escaped single quote (\\')"

        ExpectedEndOfInput ->
            "Expecting the RON to end entirely"

        ExpectingIDClock ->
            "Expecting the clock portion of a UUID"

        InvalidIDClock ->
            "Clock portion of UUID was not valid"

        ExpectingNodeID ->
            "Expecting a node ID"

        ExpectingVersionSymbol ->
            "Expecting an op ID version symbol (+ or -)"

        ExpectingComment ->
            "Expecting a line comment (@~ ...)"

        InfiniteLoop ->
            "Infinite Loop"



-- TOKENS


frameTerminator : Token Problem
frameTerminator =
    Token "." ExpectingFrameEnd


referenceStarter : Token Problem
referenceStarter =
    Token ":" ExpectingSpecReferenceAtom


opIDStarter : Token Problem
opIDStarter =
    Token "@" ExpectingSpecOpIDAtom


reducerIDStarter : Token Problem
reducerIDStarter =
    Token "*" ExpectingSpecReducerIDAtom


objectIDStarter : Token Problem
objectIDStarter =
    Token "#" ExpectingSpecObjectIDAtom


lwwName : Token Problem
lwwName =
    Token "lww" ExpectingReducerName


repListName : Token Problem
repListName =
    Token "replist" ExpectingReducerName


opSeparator : Token Problem
opSeparator =
    Token "," ExpectingOpSeparator


eventChunkTerminator : Token Problem
eventChunkTerminator =
    Token ";" ExpectingChunkEnd


assertionChunkTerminator : Token Problem
assertionChunkTerminator =
    Token "!" ExpectingChunkEnd


queryChunkTerminator : Token Problem
queryChunkTerminator =
    Token "?" ExpectingChunkEnd


uuidStarter : Token Problem
uuidStarter =
    Token ">" ExpectingUUID


intStarter : Token Problem
intStarter =
    Token "=" ExpectingUUID


floatStarter : Token Problem
floatStarter =
    Token "^" ExpectingUUID


stringWrapSingleQuote : Token Problem
stringWrapSingleQuote =
    Token "'" ExpectingQuotedString


escapedSingleQuote : Token Problem
escapedSingleQuote =
    Token "\\'" ExpectingEscapedSingleQuote


escapingBackslash : Token Problem
escapingBackslash =
    Token "\\" ExpectingEscapedSingleQuote


versionPlus : Token Problem
versionPlus =
    Token "+" ExpectingVersionSymbol


versionMinus : Token Problem
versionMinus =
    Token "-" ExpectingVersionSymbol


lineCommentStarter : Token Problem
lineCommentStarter =
    Token "@~" ExpectingComment



-- PARSERS


opIDParser : RonParser OpID
opIDParser =
    let
        parseCounter =
            Parser.int ExpectingIDClock InvalidIDClock

        parseNodeID =
            Parser.variable
                -- TODO what to really expect?
                { start = Char.isLower
                , inner = \c -> Char.isAlphaNum c || c == '_'
                , reserved = Set.fromList [ "lww", "replist" ]
                , expecting = ExpectingNodeID
                }

        parseVersionSplitter =
            Parser.oneOf
                [ Parser.map (\_ -> False) (symbol versionPlus)
                , Parser.map (\_ -> True) (symbol versionMinus)
                ]
    in
    inContext ParsingOpID <|
        succeed OpID.fromPrimitives
            |= parseCounter
            |= parseVersionSplitter
            |= parseNodeID


ronParser : RonParser (List OpenTextRonFrame)
ronParser =
    let
        frameHelp : List OpenTextRonFrame -> RonParser (Parser.Step (List OpenTextRonFrame) (List OpenTextRonFrame))
        frameHelp framesReversed =
            Parser.oneOf
                [ succeed (\frame -> Parser.Loop (frame :: framesReversed))
                    |= frameParser
                    |. whitespace
                , succeed ()
                    |. Parser.end ExpectedEndOfInput
                    -- make sure we've consumed all input
                    |> Parser.map (\_ -> Parser.Done (List.reverse framesReversed))
                ]
    in
    Parser.loop [] frameHelp


frameParser : RonParser OpenTextRonFrame
frameParser =
    let
        chunks : RonParser FrameChunk
        chunks =
            Parser.loop [] opsInChunk

        opsInChunk : List OpenTextOp -> RonParser (Parser.Step (List OpenTextOp) FrameChunk)
        opsInChunk opsReversed =
            case Maybe.andThen .endOfChunk (List.head opsReversed) of
                Nothing ->
                    opLineParserChainLoop opsReversed

                Just chunkEndType ->
                    succeed ()
                        |> Parser.map
                            (\_ ->
                                Parser.Done (FrameChunk (List.reverse opsReversed) chunkEndType)
                            )

        opLineParserChainLoop opsReversed =
            let
                lastSeenOp =
                    List.head opsReversed

                parseRealOp =
                    succeed (\thisOp -> Parser.Loop (thisOp :: opsReversed))
                        |. whitespace
                        |= opLineParser (Maybe.map .opID lastSeenOp)
                        |. whitespace

                commentPseudoOp =
                    succeed (\_ -> Parser.Loop opsReversed)
                        |= Parser.lineComment lineCommentStarter
            in
            Parser.oneOf
                [ commentPseudoOp
                , parseRealOp
                ]

        chunksInFrame : List FrameChunk -> RonParser (Parser.Step (List FrameChunk) (List FrameChunk))
        chunksInFrame chunksReversed =
            Parser.oneOf
                [ succeed (\thisChunk -> Parser.Loop (thisChunk :: chunksReversed))
                    |= chunks
                    |. whitespace
                , succeed ()
                    |. symbol frameTerminator
                    |> Parser.map (\_ -> Parser.Done (List.reverse chunksReversed))
                ]
    in
    succeed OpenTextRonFrame
        |= Parser.loop [] chunksInFrame
        |> inContext ParsingFrame


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


opLineParser : Maybe OpID -> RonParser OpenTextOp
opLineParser prevOpIDMaybe =
    let
        opRefparser =
            succeed identity
                |. symbol referenceStarter
                |= Parser.oneOf
                    -- TODO allow any reducer name
                    [ succeed (ReducerReference "lww")
                        |. Parser.keyword lwwName
                    , succeed (ReducerReference "replist")
                        |. Parser.keyword repListName
                    , succeed OpReference
                        |= opIDParser
                    ]

        reducerIDParser : RonParser ReducerID
        reducerIDParser =
            Parser.getChompedString (Parser.chompWhile Char.isAlpha)
                |> Parser.andThen (\reducerID -> succeed reducerID)

        optionalReducerIDParser =
            Parser.oneOf
                [ Parser.map Just <|
                    succeed identity
                        |. symbol reducerIDStarter
                        |= reducerIDParser
                , succeed Nothing
                ]

        optionalObjectIDParser =
            Parser.oneOf
                [ Parser.map Just <|
                    succeed identity
                        |. symbol objectIDStarter
                        |= opIDParser
                , succeed Nothing
                ]

        optionalOpIDParser =
            case prevOpIDMaybe of
                Just prevOpID ->
                    Parser.oneOf
                        [ succeed identity
                            |. symbol opIDStarter
                            |= opIDParser
                        , succeed (OpID.nextOpInChain prevOpID)
                        ]

                Nothing ->
                    succeed identity
                        |. symbol opIDStarter
                        |= opIDParser

        optionalRefParser =
            case prevOpIDMaybe of
                Just prevOpID ->
                    Parser.oneOf
                        [ opRefparser
                        , Parser.map OpReference <| succeed prevOpID
                        ]

                _ ->
                    opRefparser

        opPayloadParser : List OpPayloadAtom -> RonParser (Parser.Step OpPayloadAtoms OpPayloadAtoms)
        opPayloadParser atomsReversed =
            Parser.oneOf
                [ succeed (\thisAtom -> Parser.Loop (thisAtom :: atomsReversed))
                    -- This MUST fail if no alphaNumeric char (or _) or quote, to allow line to end
                    |= payloadAtomParser
                    |. whitespace

                -- , succeed (\_ -> Parser.Loop atomsReversed)
                --     -- This MUST fail if no spaces, to allow line to end (avoid chompWhile infinite loop problem)
                --     |= Parser.chompIf (\c -> c == ' ' || c == '\t' || c == '\u{000D}') ExpectedEndOfInput
                , succeed ()
                    |> Parser.map (\_ -> Parser.Done (List.reverse atomsReversed))
                ]

        opEndParser =
            Parser.oneOf
                [ succeed Nothing
                    |. symbol opSeparator
                , succeed (Just EventChunk)
                    |. symbol eventChunkTerminator
                , succeed (Just AssertionChunk)
                    |. symbol assertionChunkTerminator
                , succeed (Just QueryChunk)
                    |. symbol queryChunkTerminator
                ]
    in
    succeed OpenTextOp
        |= optionalReducerIDParser
        |. whitespace
        |= optionalObjectIDParser
        |. whitespace
        |= optionalOpIDParser
        |. whitespace
        |= optionalRefParser
        |. whitespace
        |= Parser.loop [] opPayloadParser
        -- TODO don't parse payload on header ops?
        |= opEndParser
        |> inContext (ParsingOp (Maybe.map OpID.nextOpInChain prevOpIDMaybe))


payloadAtomParser : RonParser OpPayloadAtom
payloadAtomParser =
    Parser.oneOf
        [ explicitRonPointer
        , ronInt -- should come before float if possible
        , ronFloat
        , nakedStringTag -- can interpret nums
        , quotedString
        ]
        |> inContext ParsingPayloadAtom


{-| Parses RON atoms without quotes (like abc123) into strings, with the same restrictions as elm record field names. Only for letter-number "tags" such as field names -- all other strings must be quoted!
May NOT start with a digit.
-}
nakedStringTag : RonParser OpPayloadAtom
nakedStringTag =
    let
        letterNumbersUnderscoreParens char =
            Char.isAlphaNum char || char == '_' || char == '(' || char == ')'
    in
    Parser.map NakedStringAtom <|
        Parser.getChompedString <|
            succeed ()
                -- chompWhile always succeeds, we need this to fail on empty
                |. Parser.chompIf letterNumbersUnderscoreParens ExpectingAlphaNumUnderscoreParens
                |. Parser.chompWhile letterNumbersUnderscoreParens


{-| Borrowed from <https://github.com/elm/parser/issues/14#issuecomment-450547742>
to get around the long-ignored <https://github.com/elm/parser/issues/28>
-}
correctIntWorkaround : RonParser Int
correctIntWorkaround =
    Parser.getChompedString (Parser.chompWhile Char.isDigit)
        |> Parser.andThen
            (\str ->
                case String.toInt str of
                    Just n ->
                        Parser.succeed n

                    Nothing ->
                        Parser.problem ExpectingIntegerAtom
            )


{-| Ron Integers start with equal sign =1099
When unambiguous, prefixes could be omitted
-}
ronInt : RonParser OpPayloadAtom
ronInt =
    let
        parseInt =
            -- Parser.int ExpectingIntegerAtom InvalidIntegerAtom
            correctIntWorkaround

        explicit =
            succeed IntegerAtom
                |. Parser.token intStarter
                |= parseInt
    in
    Parser.oneOf [ explicit, Parser.map IntegerAtom parseInt ]


{-| Ron Integers start ^: ^3.14159, ^2.9979E5.
When unambiguous, prefixes could be omitted
-}
ronFloat : RonParser OpPayloadAtom
ronFloat =
    let
        -- The built-in float parser has a bug with leading 'e'.
        -- See <https://github.com/elm/parser/issues/44>
        correctFloatWorkaround =
            -- By making it backtrackable, even if the input start with an 'e', we will be able to try out other alternative instead of getting stuck on it as an invalid number.
            Parser.backtrackable <| Parser.float ExpectingFloatAtom InvalidFloatAtom

        normalFloat =
            -- Broken by parser bug
            Parser.float ExpectingFloatAtom InvalidFloatAtom

        explicit =
            succeed FloatAtom
                |. Parser.token floatStarter
                |= correctFloatWorkaround
    in
    Parser.oneOf [ explicit, Parser.map FloatAtom correctFloatWorkaround ]


{-| Ron UUIDs start with >
-}
explicitRonPointer : RonParser OpPayloadAtom
explicitRonPointer =
    succeed IDPointerAtom
        |. Parser.token uuidStarter
        |= opIDParser


quotedString : RonParser OpPayloadAtom
quotedString =
    succeed StringAtom
        |. Parser.token stringWrapSingleQuote
        |= Parser.loop [] quotedStringHelp


ifProgress : RonParser (List String) -> Int -> RonParser (Parser.Step Int ())
ifProgress parser offset =
    succeed identity
        |. parser
        |= Parser.getOffset
        |> Parser.map
            (\newOffset ->
                if offset == newOffset then
                    Parser.Done ()

                else
                    Parser.Loop newOffset
            )


quotedStringHelp : List String -> RonParser (Parser.Step (List String) String)
quotedStringHelp piecesReversed =
    -- infinite loop should be fixed now, all chars are consumed
    -- note that we don't unescape anything but single-quote chars like
    -- https://github.com/elm/parser/blob/master/examples/DoubleQuoteString.elm
    -- does, because we assume it's a JSON-escaped string and leave it that way
    Parser.oneOf
        [ succeed (\_ -> Parser.Loop ("\\'" :: piecesReversed))
            -- When we detect an escaped quote, add it, don't stop parsing this atom
            |= Parser.token escapedSingleQuote
        , succeed (\_ -> Parser.Loop ("\\" :: piecesReversed))
            -- Something else was escaped, add backslash but leave the following intact,
            -- because it can't be an ending quote after above parser; don't stop parsing this atom
            |= Parser.token escapingBackslash
        , succeed (\_ -> Parser.Done (String.concat (List.reverse piecesReversed)))
            -- Done! Finish loop when we encounter the next unescaped single quote
            |= Parser.token stringWrapSingleQuote
        , Parser.chompWhile isUninteresting
            -- keep chomping until endquote or escape slash, then come back to top of this oneOf list
            |> Parser.getChompedString
            |> Parser.map (\chunk -> Parser.Loop (chunk :: piecesReversed))
        ]


isUninteresting : Char -> Bool
isUninteresting char =
    -- was: char /= '\\' && char /= '\''
    -- use case, in case Char == check is still unoptimized in compiler
    case char of
        '\\' ->
            -- just \
            -- interesting because we are about to escape the next character
            False

        '\'' ->
            -- just '
            -- interesting because an unescaped single quote means the end
            False

        _ ->
            -- everything else is uninteresting, keep chomping till we hit one of the above
            True


sameLineSpaces : RonParser ()
sameLineSpaces =
    -- DEPRECATED Pretty sure ron should be line-agnostic
    let
        isSameLineSpace c =
            -- use case, in case Char == check is still unoptimized in compiler
            case c of
                ' ' ->
                    True

                '\t' ->
                    True

                '\u{000D}' ->
                    True

                _ ->
                    False
    in
    Parser.chompWhile isSameLineSpace


whitespace : RonParser ()
whitespace =
    let
        isWhitespace c =
            -- use case, in case Char == check is still unoptimized in compiler
            case c of
                ' ' ->
                    True

                '\t' ->
                    True

                '\u{000D}' ->
                    True

                '\n' ->
                    True

                _ ->
                    False
    in
    Parser.chompWhile isWhitespace



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
            JE.string (OpID.toRonPointerString opID)

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
            let
                ronSafeString =
                    String.replace "'" "\\'" string
            in
            "'" ++ ronSafeString ++ "'"

        OtherUUIDAtom string ->
            string

        IDPointerAtom opID ->
            OpID.toRonPointerString opID

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

        emptyAtom =
            " "

        inclusionList =
            case format of
                ClosedOps ->
                    [ reducerID, objectID, opID, ref ]

                OpenOps ->
                    [ opID, ref ]

                CompressedOps Nothing ->
                    [ opID, ref ]

                CompressedOps (Just (Op previousOp)) ->
                    case ( OpID.isIncremental previousOp.operationID op.operationID && not (OpID.isReversion op.operationID), op.reference == OpReference previousOp.operationID ) of
                        ( True, True ) ->
                            [ emptyAtom, emptyAtom ]

                        ( True, False ) ->
                            [ emptyAtom, ref ]

                        ( False, True ) ->
                            [ opID, emptyAtom ]

                        ( False, False ) ->
                            [ opID, emptyAtom ]
    in
    String.join "\t" (inclusionList ++ List.map atomToRonString op.payload)



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
            case opsInChunk of
                [] ->
                    Nothing

                _ ->
                    List.Extra.mapAccuml perOp Nothing opsInChunk
                        |> Tuple.second
                        |> String.join " ,\n"
                        |> (\s -> s ++ " ;\n\n")
                        |> Just

        perOp prevOpMaybe thisOp =
            ( Just thisOp, closedOpToString (CompressedOps prevOpMaybe) thisOp )

        -- ( Just thisOp, closedOpToString (ClosedOps) thisOp )
    in
    case List.filterMap perChunk chunkList of
        [] ->
            ""

        readyChunks ->
            String.concat readyChunks
                |> (\s -> s ++ ".❃")
