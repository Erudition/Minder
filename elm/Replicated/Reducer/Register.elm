module Replicated.Reducer.Register exposing (..)

import Bytes.Decode
import Bytes.Encode
import Dict exposing (Dict)
import Helpers
import Json.Decode as JD
import Json.Encode as JE exposing (Value)
import Replicated.Node.Node exposing (Node, ReplicaTree)
import Replicated.Node.NodeID exposing (NodeID)
import Replicated.Object as Object exposing (Object)
import Replicated.Op.Op as Op exposing (Op, Payload, PreOp, ReducerID)
import Replicated.Op.OpID as OpID
import Replicated.Serialize as RS exposing (Codec)
import SmartTime.Moment as Moment exposing (Moment)


{-| Parsed out of an ObjectLog tree, when reducer is set to the Register Record type of this module. Requires a creation op to exist - from which the `origin` field is filled. Any other Ops must be FieldEvents, though there may be none.
-}
type Register
    = Register
        { id : OpID.ObjectID
        , changeHistory : List FieldChange -- can be truncated by timestamp for a historical snapshot
        , included : Object.InclusionInfo
        }


reducerID : Op.ReducerID
reducerID =
    "lww"


getID (Register register) =
    register.id


empty : OpID.ObjectID -> Register
empty objectID =
    Register { id = objectID, changeHistory = [], included = Object.All }


build : Node -> OpID.ObjectID -> Maybe Register
build node objectID =
    let
        convertObjectToRegister : Object -> Register
        convertObjectToRegister obj =
            Register { id = objectID, changeHistory = buildHistory obj.events, included = Object.All }
    in
    Maybe.map convertObjectToRegister (getObjectIfExists node objectID)


getObjectIfExists : Node -> OpID.ObjectID -> Maybe Object
getObjectIfExists node objectID =
    let
        registerDatabase =
            Maybe.withDefault Dict.empty (Dict.get "lww" node.db)
    in
    Dict.get (OpID.toString objectID) registerDatabase


creation : Node -> OpID.ObjectID -> Op
creation node objectID =
    Object.create reducerID objectID


fieldToOp : OpID.InCounter -> NodeID -> Register -> OpID.OpID -> FieldIdentifier -> FieldValue -> ( Op, OpID.OutCounter )
fieldToOp inCounter nodeID register opToReference fieldIdentifier fieldValue =
    let
        ( myNewID, nextCounter ) =
            OpID.generate inCounter nodeID
    in
    ( Op.create
        reducerID
        (getID register)
        myNewID
        (Just opToReference)
        (JE.encode 0 <| encodePayload ( fieldIdentifier, fieldValue ))
    , nextCounter
    )


{-| For Register we really don't need to check references, I think, except maybe to ensure that the events are in causal order.
-}
buildHistory : Dict String Object.Event -> List FieldChange
buildHistory eventDict =
    let
        orderCheck : ( String, Object.Event ) -> Bool
        orderCheck ( _, Object.Event eventDetails ) =
            -- TODO we need to fold to actually check this, right now we just see if it's there
            -- Dict.member eventDetails.reference eventDict
            True
    in
    List.filterMap toFieldChange (List.filter orderCheck (Dict.toList eventDict))


type FieldChange
    = FieldChange
        { stamp : OpID.EventStamp
        , field : FieldIdentifier
        , changedTo : FieldValue
        }


{-| Converts a generic Object Event (with its eventstampstring used as Dict key) to a Register field change item.
-}
toFieldChange : ( String, Object.Event ) -> Maybe FieldChange
toFieldChange ( eventStampString, Object.Event eventDetails ) =
    let
        interpretedPayload =
            Result.toMaybe (JD.decodeString decodePayload eventDetails.payload)

        stampFromString =
            Maybe.map OpID.getEventStamp (OpID.fromString eventStampString)

        fieldChangeWithStamp validStamp validPayload =
            FieldChange
                { stamp = validStamp
                , field = Tuple.first validPayload
                , changedTo = Tuple.second validPayload
                }
    in
    case ( interpretedPayload, stampFromString ) of
        ( Just payload, Just stamp ) ->
            Just (fieldChangeWithStamp stamp payload)

        _ ->
            Nothing



--payloadCodec : Codec e RegisterPayload
--payloadCodec =
--    RS.tuple fieldIdentifierCodec RS.string


getFieldLatest : Register -> ( FieldSlot, FieldName ) -> Maybe FieldValue
getFieldLatest (Register register) ( slot, name ) =
    let
        changesToThisField =
            List.filterMap thisFieldOnly register.changeHistory

        thisFieldOnly : FieldChange -> Maybe FieldValue
        thisFieldOnly (FieldChange change) =
            case Tuple.first change.field == slot of
                -- only the slot needs to match
                -- TODO check string as fallback?
                True ->
                    Just change.changedTo

                False ->
                    Nothing
    in
    List.head changesToThisField


{-| A sample of a Replicated Record at a given point in time - such as right now.
contains only the latest (as of the desired time) update to each field.
-}
type alias Snapshot =
    Dict FieldIdentifier FieldValue


{-| Take a snapshot of the record object, since all we care about is the latest value of each field.
-}
latest : Register -> Snapshot
latest (Register { changeHistory }) =
    -- TODO OPTIMIZE by stopping once we've found something for all fields (if possible)
    let
        toKeyValuePair (FieldChange fieldEvent) =
            ( fieldEvent.field, fieldEvent.changedTo )
    in
    -- redundant keys in the list should overwrite previous ones, so
    -- TODO make sure list is in oldest to newest order
    -- TODO ideally we'd start from newest and iteratively Dict.insert only unseen keys?
    Dict.fromList (List.map toKeyValuePair changeHistory)



--{-| A snapshot of what the Replicated Record looked like at some point in the past.
---}
--asOf : Moment -> RegisterObject -> Snapshot
--asOf cutoff (RegisterObject recordObject) =
--    let
--        isPrior (FieldChange fieldEvent) =
--            let
--                ( eventTime, eventOrigin ) =
--                    fieldEvent.stamp
--            in
--            Moment.isSameOrEarlier eventTime cutoff
--
--        cutoffHistory =
--            List.filter isPrior recordObject.changeHistory
--    in
--    latest (RegisterObject { id = recordObject.id, changeHistory = cutoffHistory, included = recordObject.included })


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


encodeFieldIdentifier : FieldIdentifier -> JE.Value
encodeFieldIdentifier ( slot, name ) =
    JE.string (String.fromInt slot ++ "_" ++ name)


decodeFieldIdentifier : JD.Decoder FieldIdentifier
decodeFieldIdentifier =
    let
        customDecoderFunction inputString =
            let
                splitUp =
                    String.split "_" inputString

                firstNumber =
                    Maybe.andThen String.toInt (List.head splitUp)

                errMsg =
                    "Could not determine the slot (integer ID) of this field: " ++ inputString
            in
            Result.fromMaybe errMsg firstNumber
    in
    JD.andThen
        (\a ->
            case customDecoderFunction a of
                Ok slot ->
                    JD.succeed ( slot, "imported" )

                Err err ->
                    JD.fail err
        )
        JD.string


type alias FieldName =
    String


type alias FieldSlot =
    Int


type alias FieldValue =
    String


type alias RegisterPayload =
    ( FieldIdentifier, FieldValue )


decodePayload : JD.Decoder RegisterPayload
decodePayload =
    JD.index 0 decodeFieldIdentifier
        |> JD.andThen
            (\aVal ->
                JD.index 1 JD.string
                    |> JD.andThen (\bVal -> JD.succeed ( aVal, bVal ))
            )


encodePayload : RegisterPayload -> JE.Value
encodePayload ( fieldID, fieldValue ) =
    JE.list identity [ encodeFieldIdentifier fieldID, JE.string fieldValue ]



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
--
--type alias UserExample =
--    { personID : Int
--    , name : String
--    , address : String
--    }
--
--buildExampleObject : Record -> UserExample
--buildExampleObject object =
--    { person = get object 1 S.int 0
--    , name = get object 2 S.string ""
--    }
--
--exampleCodec : RS.Codec e UserExample
--exampleCodec =
--    record UserExample
--        |> field ( 1, "personID" ) .personID RS.int 17
--        |> field ( 2, "name" ) .name RS.string "John Doe"
--        |> field ( 3, "address" ) .address RS.string "Nowhere"
--        |> obsolete []
--        |> finishRecord


type alias RecordDict =
    Dict FieldIdentifier FieldValue



--decodeFromDict : Codec e RecordDict
--decodeFromDict =
--    RS.dict fieldIdentifierCodec RS.string
--- DOING IT MY WAY -- RIPPED FROM SERIALIZE LIBRARY
--{-| A partially built Codec for a record.
---}
--type PartialRecord errs full remaining
--    = PartialRecord
--        { encoder : full -> List Bytes.Encode.Encoder
--        , decoder : Bytes.Decode.Decoder (Result (RS.Error errs) remaining)
--        , jsonEncoders : List ( String, full -> JE.Value )
--        , jsonArrayDecoder : Json.Decode.Decoder (Result (RS.Error errs) remaining)
--        , fieldIndex : Int
--        }
--
--
--record : remaining -> PartialRecord errs full remaining
--record remainingConstructor =
--    PartialRecord
--        { encoder = \_ -> []
--        , decoder = Bytes.Decode.succeed (Ok remainingConstructor)
--        , jsonEncoders = []
--        , jsonArrayDecoder = Json.Decode.succeed (Ok remainingConstructor)
--        , fieldIndex = 0
--        }
--
--
--field : FieldIdentifier -> (full -> fieldType) -> Codec errs fieldType -> fieldType -> PartialRecord errs full (fieldType -> remaining) -> PartialRecord errs full remaining
--field ( fieldSlot, fieldName ) fieldGetter fieldValueCodec fieldDefault (PartialRecord recordCodecSoFar) =
--    let
--        jsonObjectFieldKey =
--            -- For now, just stick number and name together.
--            String.fromInt fieldSlot ++ fieldName
--
--        addToPartialBytesEncoderList existingRecord =
--            -- Tack on the new encoder to the big list of all the encoders
--            (RS.getEncoder fieldValueCodec <| fieldGetter existingRecord) :: recordCodecSoFar.encoder existingRecord
--
--        addToPartialJsonEncoderList =
--            -- Tack on the new encoder to the big list of all the encoders
--            ( jsonObjectFieldKey, RS.getJsonEncoder fieldValueCodec << fieldGetter ) :: recordCodecSoFar.jsonEncoders
--
--        combineIfBothSucceed decoderA decoderB =
--            case ( decoderA, decoderB ) of
--                ( Ok aDecodedValue, Ok bDecodedValue ) ->
--                    -- is A being applied to B?
--                    Ok (aDecodedValue bDecodedValue)
--
--                ( Err a_error, _ ) ->
--                    Err a_error
--
--                ( _, Err b_error ) ->
--                    Err b_error
--
--        fieldJsonObjectDecoder =
--            -- Getting JSON Object field seems more efficient than finding our field in an array because the elm kernel uses JS direct access, object["fieldname"], under the hood. That's better than `index` because Elm won't let us use Strings for that or even numbers out of order. Plus it's more human-readable JSON!
--            Json.Decode.field jsonObjectFieldKey (RS.getJsonDecoder fieldValueCodec)
--    in
--    PartialRecord
--        { encoder = addToPartialBytesEncoderList
--        , decoder =
--            Bytes.Decode.map2
--                combineIfBothSucceed
--                recordCodecSoFar.decoder
--                (RS.getBytesDecoder fieldValueCodec)
--        , jsonEncoders = addToPartialJsonEncoderList
--        , jsonArrayDecoder =
--            Json.Decode.map2
--                combineIfBothSucceed
--                recordCodecSoFar.jsonArrayDecoder
--                fieldJsonObjectDecoder
--        , fieldIndex = recordCodecSoFar.fieldIndex + 1
--        }
--
--
--{-| Finish creating a codec for a record.
---}
--finishRecord : PartialRecord errs full full -> Codec errs full
--finishRecord (PartialRecord allFieldsCodec) =
--    let
--        encodeAsJsonObject fullRecord =
--            let
--                passFullRecordToFieldEncoder ( fieldKey, fieldEncoder ) =
--                    ( fieldKey, fieldEncoder fullRecord )
--            in
--            JE.object (List.map passFullRecordToFieldEncoder allFieldsCodec.jsonEncoders)
--
--        encodeAsDictList fullRecord =
--            JE.list (encodeEntryInDictList fullRecord) allFieldsCodec.jsonEncoders
--
--        encodeEntryInDictList fullRecord ( fieldKey, entryValueEncoder ) =
--            JE.list identity [ JE.string fieldKey, entryValueEncoder fullRecord ]
--    in
--    RS.Codec
--        { encoder = allFieldsCodec.encoder >> List.reverse >> Bytes.Encode.sequence
--        , decoder = allFieldsCodec.decoder
--        , jsonEncoder = encodeAsJsonObject
--        , jsonDecoder = allFieldsCodec.jsonArrayDecoder
--        }


{-| Does nothing but remind you not to reuse historical slots
-}
obsolete : List FieldIdentifier -> anything -> anything
obsolete reservedList input =
    input


type alias RW yourtype =
    { get : yourtype
    , set : yourtype -> PreOp
    }


changeField : OpID.ObjectID -> FieldIdentifier -> String -> PreOp
changeField objectID fieldIdentifier newValueEncoded =
    let
        newPayload =
            JE.encode 0 <| encodePayload ( fieldIdentifier, newValueEncoded )
    in
    Op.pre reducerID objectID newPayload


buildRW : OpID.ObjectID -> FieldIdentifier -> (a -> String) -> a -> RW a
buildRW objectID fieldIdentifier stringifier thing =
    { get = thing
    , set = \new -> changeField objectID fieldIdentifier (stringifier new)
    }
