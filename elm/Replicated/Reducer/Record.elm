module Replicated.Reducer.Record exposing (..)

import Dict exposing (Dict)
import Json.Encode exposing (Value)
import List.Nonempty exposing (Nonempty)
import Replicated.Atom exposing (..)
import Replicated.Identifier exposing (..)
import Replicated.Object as Object
import Replicated.Op as Op exposing (Op)
import Replicated.Value as Value exposing (Value)
import Serialize as S exposing (Codec)
import SmartTime.Moment as Moment exposing (Moment)


{-| Parsed out of an ObjectLog tree, when reducer is set to the LWW Record type of this module. Requires a creation op to exist - from which the `origin` field is filled. Any other Ops must be FieldEvents, though there may be none.
-}
type alias Record =
    { id : RonUUID -- taken from ObjectSpec
    , changeHistory : List FieldChange -- can be truncated by timestamp for a historical snapshot
    , included : Object.InclusionInfo
    }


type alias FieldChange =
    { stamp : EventStamp
    , field : FieldIdentifier
    , changedTo : FieldValue
    }


fromTree : Object.Tree -> Maybe Record
fromTree tree =
    case tree.root.reducer of
        SpecialNamed Hardcoded "LWWRecord" ->
            Just
                { id = tree.root.creation
                , changeHistory = List.filterMap toFieldChange tree.events
                , included = tree.included
                }

        _ ->
            Nothing



-- This is not a Record Object


toFieldChange : Object.Event -> Maybe FieldChange
toFieldChange ( eventDetails, payload ) =
    let
        payloadCodec =
            S.tuple fieldIdentifierCodec S.string

        interpretedPayload =
            Result.toMaybe <| Value.decode payloadCodec payload

        convert validPayload =
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
latest : Record -> Snapshot
latest { changeHistory } =
    -- TODO OPTIMIZE by stopping once we've found something for all fields (if possible)
    let
        toKeyValuePair fieldEvent =
            ( fieldEvent.field, fieldEvent.changedTo )
    in
    -- redundant keys in the list should overwrite previous ones, so
    -- TODO make sure list is in oldest to newest order
    -- TODO ideally we'd start from newest and iteratively Dict.insert only unseen keys?
    Dict.fromList (List.map toKeyValuePair changeHistory)


{-| A snapshot of what the Replicated Record looked like at some point in the past.
-}
asOf : Moment -> Record -> Snapshot
asOf cutoff recordObject =
    let
        isPrior fieldEvent =
            let
                ( eventTime, eventOrigin ) =
                    fieldEvent.stamp
            in
            Moment.isSameOrEarlier eventTime cutoff

        cutoffHistory =
            List.filter isPrior recordObject.changeHistory
    in
    latest (Record recordObject.id cutoffHistory recordObject.included)


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


fieldIdentifierCodec =
    S.tuple S.int S.string


type alias FieldName =
    String


type alias FieldSlot =
    Int


type alias FieldValue =
    String


type alias Field fieldtype =
    { slot : Int -- 0 to 255 so it can be in one byte
    , codec : Codec () fieldtype
    , backupCodecs : List (Codec () fieldtype)
    , default : fieldtype
    , history : FieldHistory
    }



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
    { person : Int
    , name : String
    }



--buildExampleObject : Record -> UserExample
--buildExampleObject object =
--    { person = get object 1 S.int 0
--    , name = get object 2 S.string ""
--    }


exampleCodec : S.Codec e UserExample
exampleCodec =
    S.record UserExample
        |> rField 1 .person S.int
        |> rField 2 .name S.string
        |> S.finishRecord


rField slotNumber =
    S.field
