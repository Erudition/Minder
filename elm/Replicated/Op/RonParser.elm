module Replicated.Op.RonParser exposing (..)

import List.Nonempty as Nonempty exposing (Nonempty(..))
import Parser.Advanced as Parser exposing ((|.), (|=), Token(..), float, inContext, succeed, symbol)
import Replicated.Op.Atom as Atom exposing (Atom(..))
import Replicated.Op.ID as OpID exposing (ObjectID, OpID)
import Replicated.Op.Op exposing (..)
import Replicated.Op.Payload as Payload exposing (Payload)
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)
import Set exposing (Set)



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
    Token ReducerID.lwwTag ExpectingReducerName


repListName : Token Problem
repListName =
    Token ReducerID.repListTag ExpectingReducerName


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
                , reserved = Set.fromList [ ReducerID.lwwTag, ReducerID.repListTag ]
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


type FrameChunkType
    = EventChunk -- 3.0: FACT
    | AssertionChunk -- 3.0 CLAIM
    | QueryChunk -- 3.0: QUERY


type alias OpenTextRonFrame =
    { chunks : List FrameChunk
    }


type UnresolvedOpReference
    = UnresolvedOpReference OpID
    | UnresolvedReducerReference ReducerID


{-| RON: "Open notation is just a shorted version of closed one. Reducer id and object id are omitted in this case, as those could be deduced from full DB and reference id."

The ChainSpanOpenOp is part of a Chain Span, from which it infers its OpID (spans have incremental OpIDs).

-}
type alias OpenTextOp =
    { reducerSpecified : Maybe ReducerID
    , objectSpecified : Maybe ObjectID
    , opID : OpID
    , reference : UnresolvedOpReference
    , payload : Payload
    , endOfChunk : Maybe FrameChunkType
    }


opLineParser : Maybe OpID -> RonParser OpenTextOp
opLineParser prevOpIDMaybe =
    let
        opRefparser =
            succeed identity
                |. symbol referenceStarter
                |= Parser.oneOf
                    -- TODO allow any reducer name?
                    [ Parser.map UnresolvedReducerReference <|
                        succeed identity
                            |= reducerIDParser
                    , succeed UnresolvedOpReference
                        |= opIDParser
                    ]

        reducerIDParser : RonParser ReducerID
        reducerIDParser =
            -- Parser.getChompedString (Parser.chompWhile Char.isAlpha)
            --     |> Parser.andThen (\reducerID -> succeed reducerID)
            Parser.oneOf
                [ succeed ReducerID.LWWReducer
                    |. Parser.keyword lwwName
                , succeed ReducerID.RepListReducer
                    |. Parser.keyword repListName
                ]

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
                        , Parser.map UnresolvedOpReference <| succeed prevOpID
                        ]

                _ ->
                    opRefparser

        opPayloadParser : List Atom -> RonParser (Parser.Step Payload Payload)
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


payloadAtomParser : RonParser Atom
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
nakedStringTag : RonParser Atom
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
ronInt : RonParser Atom
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
ronFloat : RonParser Atom
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
explicitRonPointer : RonParser Atom
explicitRonPointer =
    succeed IDPointerAtom
        |. Parser.token uuidStarter
        |= opIDParser


quotedString : RonParser Atom
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
