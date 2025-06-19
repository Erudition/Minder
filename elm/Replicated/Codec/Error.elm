module Replicated.Codec.Error exposing (..)

import Array exposing (Array)
import Base64
import Bytes
import Bytes.Decode as BD
import Bytes.Encode as BE
import Console
import Css exposing (None)
import Dict exposing (Dict)
import Dict.Any as AnyDict exposing (AnyDict)
import Html exposing (input, th)
import ID exposing (ID)
import Json.Decode as JD
import Json.Encode as JE
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Log
import Maybe.Extra
import Regex exposing (Regex)
import Replicated.Change as Change exposing (Change, ChangeSet(..), Changer, ComplexAtom(..), Context, ObjectChange, Parent(..), Pointer(..))
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Codec.RegisterField.Shared exposing (..)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.ObjectGroup as Object exposing (ObjectGroup)
import Replicated.Op.ID as OpID exposing (InCounter, ObjectID, OpID, OutCounter)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Reducer.Register as Reg exposing (..)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.Reducer.RepStore as RepStore exposing (RepStore)
import Set exposing (Set)
import SmartTime.Human.Moment as HumanMoment
import SmartTime.Moment as Moment exposing (Moment)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))


{-| Possible errors that can occur when node-decoding. These are all the user-facing possibilies in the codec library.
-}
type RepDecodeError
    = Custom CustomError
    | BinaryDataCorrupted
    | ObjectNotFound OpID
    | JDError JD.Error
    | FailedToDecodeRegField FieldSlot FieldName String JD.Error
    | MissingRequiredField FieldSlot FieldName
    | NoMatchingVariant String
    | BadBoolean String
    | BadChar String
    | EmptyList
    | BadByteString String
    | BadIndex Int
    | WrongCutoff (Maybe Moment) Pointer -- TODO what exactly goes wrong with wrong-cutoff errors, may not be named correctly


type alias CustomError =
    String


toString : RepDecodeError -> String
toString codecError =
    case codecError of
        Custom errMsg ->
            errMsg

        BinaryDataCorrupted ->
            "Binary Data Corrupted"

        ObjectNotFound opID ->
            "Object Not Found: " ++ OpID.toString opID

        JDError jdError ->
            JD.errorToString jdError

        FailedToDecodeRegField fieldSlot fieldName valueString jdError ->
            "Failed to decode reg field " ++ String.fromInt fieldSlot ++ "(" ++ fieldName ++ ") value: " ++ valueString ++ " because \n" ++ JD.errorToString jdError

        NoMatchingVariant tag ->
            "No Matching Variant found for tag " ++ tag

        MissingRequiredField fieldSlot fieldName ->
            "Could not find field " ++ String.fromInt fieldSlot ++ " " ++ fieldName ++ " but it is required"

        BadBoolean givenData ->
            "I was trying to parse a boolean but what I found was " ++ givenData

        BadChar givenData ->
            "I was trying to parse a char but what I found was " ++ givenData

        BadIndex givenData ->
            "I was trying to parse an index within bounds but what I found was " ++ String.fromInt givenData

        BadByteString givenData ->
            "I was trying to parse a string of bytes but what I found was " ++ givenData

        EmptyList ->
            "I was trying to parse a nonempty list, but the list I found was empty."

        WrongCutoff cutoff pointer ->
            "Naked register cutoff function for object " ++ Debug.toString pointer ++ " with cutoff " ++ Maybe.withDefault "(No cutoff)" (Maybe.map HumanMoment.toStandardString cutoff)



-- WrongCutoff ->
--     "Naked register cutoff function failed."
-- mapErrorHelper : (e -> a) -> Result RepDecodeError b -> Result RepDecodeError b
-- mapErrorHelper mapFunc =
--     Result.mapError
--         (\error ->
--             case error of
--                 CustomError custom ->
--                     mapFunc custom |> CustomError
--                 SerializerOutOfDate ->
--                     SerializerOutOfDate
--                 ObjectNotFound opID ->
--                     ObjectNotFound opID
--                 JDError jsonDecodeError ->
--                     JDError jsonDecodeError
--                 FailedToDecodeRegField fieldSlot fieldName value jdError ->
--                     FailedToDecodeRegField fieldSlot fieldName value jdError
--                 NoMatchingVariant tag ->
--                     NoMatchingVariant tag
--                 BinaryDataCorrupted ->
--                     BinaryDataCorrupted
--                 BadVersionNumber num ->
--                     BadVersionNumber num
--                 MissingRequiredField fieldSlot fieldName ->
--                     MissingRequiredField fieldSlot fieldName
--                 BadBoolean givenData ->
--                     BadBoolean givenData
--                 BadChar givenData ->
--                     BadChar givenData
--                 EmptyList ->
--                     EmptyList
--                 BadByteString badData ->
--                     BadByteString badData
--                 BadIndex badData ->
--                     BadIndex badData
--          -- WrongCutoff ->
--          --     WrongCutoff
--         )
