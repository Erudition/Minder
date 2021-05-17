module Replicated.Reducer.LWWObject exposing (..)

import Bytes.Decode
import Bytes.Encode
import Dict exposing (Dict)
import Json.Decode
import Json.Encode exposing (Value)
import Replicated.Identifier exposing (..)
import Replicated.Node exposing (Node, ReplicaTree)
import Replicated.Object as Object exposing (InclusionInfo(..))
import Replicated.Op as Op exposing (Op, Payload)
import Replicated.Serialize as RS exposing (Codec)
import SmartTime.Moment as Moment exposing (Moment)


{-| Parsed out of an ObjectLog tree, when reducer is set to the LWW Record type of this module. Requires a creation op to exist - from which the `origin` field is filled. Any other Ops must be FieldEvents, though there may be none.
-}
type LWWObject
    = LWWObject
        { id : ObjectID
        , changeHistory : List FieldChange -- can be truncated by timestamp for a historical snapshot
        , included : Object.InclusionInfo
        }


build : Node -> ObjectID -> LWWObject
build replica objectID =
    let
        lwwDatabase =
            Maybe.withDefault Dict.empty (Dict.get "lww" replica.db)

        existingObject =
            Maybe.withDefault Dict.empty (Dict.get objectID lwwDatabase)

        history =
            List.filterMap toFieldChange (Dict.toList existingObject)
    in
    LWWObject { id = objectID, changeHistory = history, included = All }


type FieldChange
    = FieldChange
        { stamp : EventStamp
        , field : FieldIdentifier
        , changedTo : FieldValue
        }


toFieldChange : ( EventString, Payload ) -> Maybe FieldChange
toFieldChange ( eventDetailsString, payload ) =
    let
        payloadCodec =
            RS.tuple fieldIdentifierCodec RS.string

        interpretedPayload =
            Result.toMaybe (RS.decodeFromString payloadCodec payload)

        eventDetailsCodec =
            RS.tuple RS.string RS.string

        interpretedEventDetails =
            Result.toMaybe (RS.decodeFromString eventDetailsCodec eventDetailsString)

        convert validPayload =
            FieldChange
                { stamp = eventDetails.stamp
                , field = Tuple.first validPayload
                , changedTo = Tuple.second validPayload
                }
    in
    Maybe.map convert interpretedPayload


{-| A sample of a Replicated Record at a given point in time - such as right now.
contains only the latest (as of the desired time) update to each field.
-}
type alias Snapshot =
    Dict FieldIdentifier FieldValue


{-| Take a snapshot of the record object, since all we care about is the latest value of each field.
-}
latest : LWWObject -> Snapshot
latest (LWWObject { changeHistory }) =
    -- TODO OPTIMIZE by stopping once we've found something for all fields (if possible)
    let
        toKeyValuePair (FieldChange fieldEvent) =
            ( fieldEvent.field, fieldEvent.changedTo )
    in
    -- redundant keys in the list should overwrite previous ones, so
    -- TODO make sure list is in oldest to newest order
    -- TODO ideally we'd start from newest and iteratively Dict.insert only unseen keys?
    Dict.fromList (List.map toKeyValuePair changeHistory)


{-| A snapshot of what the Replicated Record looked like at some point in the past.
-}
asOf : Moment -> LWWObject -> Snapshot
asOf cutoff (LWWObject recordObject) =
    let
        isPrior (FieldChange fieldEvent) =
            let
                ( eventTime, eventOrigin ) =
                    fieldEvent.stamp
            in
            Moment.isSameOrEarlier eventTime cutoff

        cutoffHistory =
            List.filter isPrior recordObject.changeHistory
    in
    latest (LWWObject { id = recordObject.id, changeHistory = cutoffHistory, included = recordObject.included })


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


fieldIdentifierCodec =
    RS.tuple RS.byte RS.string


type alias FieldName =
    String


type alias FieldSlot =
    Int


type alias FieldValue =
    String



--type alias Field fieldtype =
--    { slot : Int -- 0 to 255 so it can be in one byte
--    , codec : Codec () fieldtype
--    , backupCodecs : List (Codec () fieldtype)
--    , default : fieldtype
--    , history : FieldHistory
--    }
--get : Dict FieldSlot FieldHistory -> FieldSlot -> Codec () fieldtype -> fieldtype -> fieldtype
--get object slot codec default =
--    let
--        field =
--            Field slot codec [] default fieldHistory
--
--        fieldHistory =
--            Dict.get slot object
--
--        latest =
--            List.head (Dict.values fieldHistory)
--    in
--    case latest of
--        Nothing ->
--            field.default
--
--        Just fieldValue ->
--            case S.decodeFromJson field.codec fieldValue of
--                Err e ->
--                    field.default
--
--                Ok value ->
--                    value
--set : Field fieldtype -> Op
--set field =
--    Op ()


type alias UserExample =
    { personID : Int
    , name : String
    , address : String
    }



--buildExampleObject : Record -> UserExample
--buildExampleObject object =
--    { person = get object 1 S.int 0
--    , name = get object 2 S.string ""
--    }


exampleCodec : RS.Codec e UserExample
exampleCodec =
    record UserExample
        |> field ( 1, "personID" ) .personID RS.int 17
        |> field ( 2, "name" ) .name RS.string "John Doe"
        |> field ( 3, "address" ) .address RS.string "Nowhere"
        |> obsolete []
        |> finishRecord


type alias RecordDict =
    Dict FieldIdentifier FieldValue


decodeFromDict : Codec e RecordDict
decodeFromDict =
    RS.dict fieldIdentifierCodec RS.string



--- DOING IT MY WAY -- RIPPED FROM SERIALIZE LIBRARY


{-| A partially built Codec for a record.
-}
type PartialRecord errs full remaining
    = PartialRecord
        { encoder : full -> List Bytes.Encode.Encoder
        , decoder : Bytes.Decode.Decoder (Result (RS.Error errs) remaining)
        , jsonEncoders : List ( String, full -> Json.Encode.Value )
        , jsonArrayDecoder : Json.Decode.Decoder (Result (RS.Error errs) remaining)
        , fieldIndex : Int
        }


record : remaining -> PartialRecord errs full remaining
record remainingConstructor =
    PartialRecord
        { encoder = \_ -> []
        , decoder = Bytes.Decode.succeed (Ok remainingConstructor)
        , jsonEncoders = []
        , jsonArrayDecoder = Json.Decode.succeed (Ok remainingConstructor)
        , fieldIndex = 0
        }


field : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldType -> fieldType -> PartialRecord errs full (fieldType -> remaining) -> PartialRecord errs full remaining
field ( fieldSlot, fieldName ) fieldGetter fieldValueCodec fieldDefault (PartialRecord recordCodecSoFar) =
    let
        jsonObjectFieldKey =
            -- For now, just stick number and name together.
            String.fromInt fieldSlot ++ fieldName

        addToPartialBytesEncoderList existingRecord =
            -- Tack on the new encoder to the big list of all the encoders
            (RS.getEncoder fieldValueCodec <| fieldGetter existingRecord) :: recordCodecSoFar.encoder existingRecord

        addToPartialJsonEncoderList =
            -- Tack on the new encoder to the big list of all the encoders
            ( jsonObjectFieldKey, RS.getJsonEncoder fieldValueCodec << fieldGetter ) :: recordCodecSoFar.jsonEncoders

        combineIfBothSucceed decoderA decoderB =
            case ( decoderA, decoderB ) of
                ( Ok aDecodedValue, Ok bDecodedValue ) ->
                    -- is A being applied to B?
                    Ok (aDecodedValue bDecodedValue)

                ( Err a_error, _ ) ->
                    Err a_error

                ( _, Err b_error ) ->
                    Err b_error

        fieldJsonObjectDecoder =
            -- Getting JSON Object field seems more efficient than finding our field in an array because the elm kernel uses JS direct access, object["fieldname"], under the hood. That's better than `index` because Elm won't let us use Strings for that or even numbers out of order. Plus it's more human-readable JSON!
            Json.Decode.field jsonObjectFieldKey (RS.getJsonDecoder fieldValueCodec)
    in
    PartialRecord
        { encoder = addToPartialBytesEncoderList
        , decoder =
            Bytes.Decode.map2
                combineIfBothSucceed
                recordCodecSoFar.decoder
                (RS.getBytesDecoder fieldValueCodec)
        , jsonEncoders = addToPartialJsonEncoderList
        , jsonArrayDecoder =
            Json.Decode.map2
                combineIfBothSucceed
                recordCodecSoFar.jsonArrayDecoder
                fieldJsonObjectDecoder
        , fieldIndex = recordCodecSoFar.fieldIndex + 1
        }


{-| Finish creating a codec for a record.
-}
finishRecord : PartialRecord errs full full -> Codec errs full
finishRecord (PartialRecord allFieldsCodec) =
    let
        encodeAsJsonObject fullRecord =
            let
                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
                    ( fieldKey, fieldEncoder fullRecord )
            in
            Json.Encode.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)

        encodeAsDictList fullRecord =
            Json.Encode.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders

        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
            Json.Encode.list identity [ Json.Encode.string fieldKey, entryValueEncoder fullRecord ]
    in
    RS.Codec
        { encoder = allFieldsCodec.encoder >> List.reverse >> Bytes.Encode.sequence
        , decoder = allFieldsCodec.decoder
        , jsonEncoder = encodeAsJsonObject
        , jsonDecoder = allFieldsCodec.jsonArrayDecoder
        }


{-| Does nothing but remind you not to reuse historical slots
-}
obsolete : List FieldIdentifier -> anything -> anything
obsolete reservedList input =
    input
