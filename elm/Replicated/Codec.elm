module Replicated.Codec exposing
    ( string, bool, float, int, unit, bytes, byte
    , maybe, array, dict, set, pair, triple, result
    , record, field, finishRecord
    , CustomTypeCodec, customType, variant0, variant1, variant2, variant3, variant4, variant5, variant6, variant7, variant8, finishCustomType
    , map, mapValid, mapError
    , lazy
    , FieldIdentifier, FieldName, FieldSlot, FieldValue, NullCodec, PrimitiveCodec, SelfSeededCodec, SkelCodec, SmartJsonFieldEncoder, VariantTag, WrappedCodec, WrappedOrSkelCodec, WrappedSeededCodec, char, coreR, coreRW, decodeFromNode, fieldDb, fieldDict, fieldList, fieldRW, fieldRWM, fieldRec, fieldReg, fieldStore, finishRegister, finishSeededRecord, finishSeededRegister, id, list, makeOpaque, maybeR, new, newUnique, newWithChanges, newWithSeed, newWithSeedAndChanges, nonempty, obsolete, quickEnum, repDb, repDict, repList, repStore, seededR, seededRW, seedlessPair, todo
    )

{-|


# Serialization

You have three options when encoding data. You can represent the data either as json, bytes, or a string.
Here's some advice when choosing:

  - If performance is important, use `encodeToJson` and `decodeFromJson`
  - If space efficiency is important, use `encodeToBytes` and `decodeFromBytes`\*
  - `encodeToString` and `decodeFromString` are good for URL safe strings but otherwise one of the other choices is probably better.

\*`encodeToJson` is more compact when encoding integers with 6 or fewer digits. You may want to try both `encodeToBytes` and `encodeToJson` and see which is better for your use case.

@docs encodeToJson, decodeFromJson, encodeToBytes, decodeFromBytes, encodeToString, decodeFromURLSafeByteString


# Definition

@docs Codec, Error


# Primitives

@docs string, bool, float, int, unit, bytes, byte


# Data Structures

@docs maybe, primitiveList, array, dict, set, pair, triple, result, enum


# Records

@docs RecordCodec, record, field, finishRecord


# Custom Types

@docs CustomTypeCodec, customType, variant0, variant1, variant2, variant3, variant4, variant5, variant6, variant7, variant8, finishCustomType, VariantEncoder


# Mapping

@docs map, mapValid, mapError


# Stack unsafe

@docs lazy

-}

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
import Replicated.Change as Change exposing (Change, ChangeSet(..), Changer, ComplexAtom(..), Context, ObjectChange, Parent(..), Pointer(..))
import Replicated.Change.Location as Location exposing (Location)
import Replicated.Codec.Base as Base
import Replicated.Codec.Bytes.Decoder as BytesDecoder exposing (BytesDecoder)
import Replicated.Codec.Bytes.Encoder exposing (BytesEncoder)
import Replicated.Codec.CustomType
import Replicated.Codec.DataStructures.Immutable.SyncSafe
import Replicated.Codec.DataStructures.Immutable.SyncUnsafe
import Replicated.Codec.DataStructures.Mutable
import Replicated.Codec.Error as Error exposing (RepDecodeError(..))
import Replicated.Codec.Json.Decoder as JsonDecoder exposing (JsonDecoder)
import Replicated.Codec.Node.Decoder as NodeDecoder exposing (Inputs, NodeDecoder)
import Replicated.Codec.Node.Encoder as NodeEncoder exposing (NodeEncoder)
import Replicated.Codec.Primitives as Primitives
import Replicated.Codec.Register
import Replicated.Codec.RegisterField.Shared
import Replicated.Codec.RonPayloadDecoder as RonPayloadDecoder exposing (RonPayloadDecoder(..))
import Replicated.Collection as Object exposing (Object)
import Replicated.Node.Node as Node exposing (Node)
import Replicated.Op.ID as OpID exposing (InCounter, ObjectID, OpID, OutCounter)
import Replicated.Op.Op as Op exposing (Op)
import Replicated.Reducer.Register as Reg exposing (..)
import Replicated.Reducer.RepDb as RepDb exposing (RepDb)
import Replicated.Reducer.RepDict as RepDict exposing (RepDict, RepDictEntry(..))
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Replicated.Reducer.RepStore as RepStore exposing (RepStore)
import Set exposing (Set)
import SmartTime.Moment as Moment exposing (Moment)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))



-- Types of Codecs


{-| For types that cannot be initialized from nothing, nor from a list of changes - you need the whole value upfront. We use the value itself as the "seed".
-}
type alias SelfSeededCodec constraints thing =
    Base.SelfSeededCodec constraints thing


{-| A self-seeded codec with no special guarantees. Used as a building block for additional type constraints.
-}
type alias NullCodec thing =
    Base.NullCodec thing


{-| A self-seeded, primitive-only codec, like string or int.
-}
type alias PrimitiveCodec primitive =
    Base.PrimitiveCodec primitive


{-| Codec for unwrapped objects, like naked records.
-}
type alias SkelCodec skel =
    Base.SkelCodec skel


{-| Codec for wrapped objects, like replist or register, or unwrapped naked records.
-}
type alias WrappedOrSkelCodec s thing =
    Base.WrappedOrSkelCodec s thing


{-| Codec for wrapped objects, like replist or register, but not naked records.
-}
type alias WrappedCodec thing =
    Base.WrappedCodec thing


{-| Codec for wrapped objects that need an initial seed.
-}
type alias WrappedSeededCodec seed thing =
    Base.WrappedSeededCodec seed thing



-- Initializers ----------------------------------------


{-| Create something new, from its Codec!
Be sure to pass in a `Context`, which you can get from its parent.
-}
new : Codec (s -> List Change) o repType -> Context repType -> repType
new codec context =
    Base.new codec context


{-| Create a new object from its Codec, given a unique integer to differentiate it from other times you use this function on the same Codec in the same context.
If the Codecs are different, you can just use new. If they aren't, using new multiple times will create references to a single object rather than multiple distinct objects. So be sure to use a different number for each usage of newN.
-}
newUnique : Int -> Codec (s -> List Change) o repType -> Context repType -> repType
newUnique nth codec context =
    Base.newUnique nth codec context


{-| Create something new, from its Codec - but make some changes to it right from the start.
Like `new`, but also takes a `Changer`, a function that will generate changes.
-}
newWithChanges : WrappedCodec repType -> Context repType -> Changer repType -> repType
newWithChanges codec context changer =
    Base.newWithChanges codec context changer


{-| Create something new, from a Codec that requires an initial seed.
Like `new`, but also takes the seed value.
-}
newWithSeed : Codec s o repType -> Context repType -> s -> repType
newWithSeed codec context seed =
    Base.newWithSeed codec context seed


{-| Create something new, from a Codec that requires an initial seed, then immediately make changes to it.
-}
newWithSeedAndChanges : Codec ( s, Changer repType ) o repType -> Context repType -> s -> Changer repType -> repType
newWithSeedAndChanges codec context seed changer =
    Base.newWithSeedAndChanges codec context seed changer



-- DECODE


{-| Pass in the codec for the root object.
-}
decodeFromNode : WrappedOrSkelCodec s root -> Node -> Maybe root -> ( root, Maybe RepDecodeError )
decodeFromNode rootCodec node oldRootMaybe =
    let
        rootIDAsJsonString =
            node.root
                -- legacy decoder is Json so needs a valid Json string
                -- turn root ID into a Json list string
                |> Maybe.map (\i -> "[\"" ++ OpID.toString i ++ "\"]")
                |> Maybe.withDefault "\"[]\""

        fallback =
            case oldRootMaybe of
                Just oldRoot ->
                    oldRoot

                Nothing ->
                    new rootCodec (Change.startContext "fDFN")

        { decoder, obSubs } =
            getNodeDecoder rootCodec { node = node, parent = Change.genesisParent "dFN", cutoff = Nothing, position = Location.none, oldMaybe = oldRootMaybe, changedObjectIDs = [] }

        decodedRoot =
            case decoder of
                RonPayloadDecoderLegacy jdDecoder ->
                    -- run legacy JD Decoder on the artificial json string containing only the root ID
                    case JD.decodeString jdDecoder (prepRonAtomForLegacyDecoder rootIDAsJsonString) of
                        Ok unwrappedResult ->
                            unwrappedResult

                        Err jdError ->
                            -- error happened at the level of the outer result (legacy wrapper), flatten to RepDecodeError
                            Err <| JDError <| Debug.log "decodeFromNode: Json Decoder (legacy Result wrapper) error... " <| jdError

                RonPayloadDecoderNew ronPayloadDecoder ->
                    -- turn the root object ID into a fake ron payload with zero or one OpID atoms
                    ronPayloadDecoder (Maybe.Extra.toList (Maybe.map Op.IDPointerAtom node.root))
    in
    case decodedRoot of
        Ok success ->
            ( Log.logMessageOnly "Decoding Node again." success, Nothing )

        Err err ->
            ( Log.crashInDev ("decodeFromNode failed with error: " ++ Error.toString err) fallback, Just err )


{-| Run a `Codec` to turn a sequence of bytes into an Elm value.
-}
decodeFromBytes : PrimitiveCodec a -> Bytes.Bytes -> Result RepDecodeError a
decodeFromBytes codec bytes_ =
    let
        -- decoder =
        --     BD.unsignedInt8
        --         |> BD.andThen
        --             (\value ->
        --                 if value <= 0 then
        --                     Err (BadVersionNumber value) |> BD.succeed
        --                 else if value == version then
        --                     getBytesDecoder codec
        --                 else
        --                     Err SerializerOutOfDate |> BD.succeed
        --             )
        decoder =
            BD.unsignedInt8
                |> BD.andThen
                    (\value ->
                        getBytesDecoder codec
                    )
    in
    case BD.decode decoder bytes_ of
        Just value ->
            value

        Nothing ->
            Err BinaryDataCorrupted


{-| Run a `Codec` to turn a String encoded with `encodeToString` into an Elm value.
-}
decodeFromURLSafeByteString : PrimitiveCodec a -> String -> Result RepDecodeError a
decodeFromURLSafeByteString codec base64 =
    case decodeStringToBytes base64 of
        Just bytes_ ->
            decodeFromBytes codec bytes_

        Nothing ->
            Err BinaryDataCorrupted


{-| Run a `Codec` to turn a json value encoded with `encodeToJson` into an Elm value.
-}
decodeFromJson : Codec s o a -> JE.Value -> Result RepDecodeError a
decodeFromJson codec json =
    -- let
    --     decoder =
    --         JD.index 0 JD.int
    --             |> JD.andThen
    --                 (\value ->
    --                     if value <= 0 then
    --                         Err (BadVersionNumber value) |> JD.succeed
    --                     else if value == version then
    --                         JD.index 1 (getJsonDecoder codec)
    --                     else
    --                         Err SerializerOutOfDate |> JD.succeed
    --                 )
    -- in
    -- case JD.decodeValue decoder json of
    --     Ok value ->
    --         value
    --     Err jdError ->
    --         Err (JDError jdError)
    JD.decodeValue (getJsonDecoder codec) json


decodeStringToBytes : String -> Maybe Bytes.Bytes
decodeStringToBytes base64text =
    BytesDecoder.decodeStringToBytes base64text



-- ENCODE


{-| Convert an Elm value into a sequence of bytes.
-}
encodeToBytes : Codec s o a -> a -> Bytes.Bytes
encodeToBytes codec value =
    -- BE.sequence
    --     [ BE.unsignedInt8 version
    --     , value |> getBytesEncoder codec
    --     ]
    --     |> BE.encode
    BE.encode


{-| Convert an Elm value into a string. This string contains only url safe characters, so you can do the following:

    import Serlialize as S

    myUrl =
        "www.mywebsite.com/?data=" ++ S.encodeToString S.float 1234

and not risk generating an invalid url.

-}
encodeToURLSafeByteString : Codec s o a -> a -> String
encodeToURLSafeByteString codec =
    encodeToBytes codec >> replaceBase64Chars


{-| Gives you the raw string, for debugging
-}
encodeToJsonString : Codec s o a -> a -> String
encodeToJsonString codec value =
    JE.encode 0 (getJsonEncoder codec value)


{-| Convert an Elm value into json data.
-}
encodeToJson : Codec s o a -> a -> JE.Value
encodeToJson codec value =
    -- JE.list
    --     identity
    --     [ JE.int version
    --     , value |> getJsonEncoder codec
    --     ]
    getJsonEncoder codec value


replaceBase64Chars : Bytes.Bytes -> String
replaceBase64Chars =
    BytesEncoder.replaceBase64Chars


{-| Start a new node
-}
startNodeFromRoot : Maybe Moment -> WrappedOrSkelCodec s a -> ( Node, List Op.ClosedChunk )
startNodeFromRoot maybeMoment rootCodec =
    let
        rootEncoderOutput =
            getSoloNodeEncoder rootCodec
                { node = Node.testNode
                , mode = { defaultEncodeMode | setDefaultsExplicitly = True }
                , thingToEncode = EncodeThis <| new rootCodec (Change.startContext "eD")
                , parent = Change.genesisParent "eD"
                , position = Location.none
                }

        rootPointer =
            rootEncoderOutput.nested.toReference

        startNode =
            (Node.startNewNode maybeMoment False []).newNode
    in
    if startNode.root == Nothing then
        case rootPointer of
            Change.ExistingObjectPointer existingID ->
                -- weird. why would it be existing already?
                ( { startNode | root = Just existingID.object }, [] )

            Change.PlaceholderPointer pendingID _ ->
                let
                    ( rootOpID, finalCounter ) =
                        OpID.generate (OpID.importCounter 0) startNode.identity False

                    rootInitOp =
                        Op.initObject pendingID.reducer rootOpID

                    nodeWithRoot =
                        Node.updateWithClosedOps startNode [ rootInitOp ]
                in
                ( { nodeWithRoot | root = Just rootOpID }, [ [ rootInitOp ] ] )

    else
        ( startNode, [] )


{-| Generates naked Changes from a Codec's default values. These are all the values that would normally be skipped, not encoded to Changes.
Useful for spitting out test data, and seeing the whole heirarchy of your types.
-}
encodeDefaults : Node -> WrappedOrSkelCodec s a -> ChangeSet
encodeDefaults node rootCodec =
    let
        rootEncoderOutput =
            getSoloNodeEncoder rootCodec
                { node = node
                , mode = { defaultEncodeMode | setDefaultsExplicitly = True }
                , thingToEncode = EncodeThis <| new rootCodec (Change.startContext "eD")
                , parent = Change.genesisParent "eD"
                , position = Location.none
                }
    in
    rootEncoderOutput.nested.changeSet


{-| Generates naked Changes from a Codec's default values. Passes in a test node, not for production
-}
encodeDefaultsForTesting : WrappedOrSkelCodec s a -> ChangeSet
encodeDefaultsForTesting rootCodec =
    encodeDefaults Node.testNode rootCodec


getEncodedPrimitive : ThingToEncode a -> a
getEncodedPrimitive thingToEncode =
    case thingToEncode of
        EncodeThis thing ->
            thing

        EncodeObjectOrThis _ thing ->
            Log.crashInDev "primitive encoder was passed an objectID to encode?" thing



-- PRIMITIVES


{-| Codec for serializing a `String`
-}
string : PrimitiveCodec String
string =
    Primitives.string


{-| An ID is a Pointer that's meant to be more user-facing. It has a type variable so it can be used for constraining a wrapped reptype for type safety, unlike a Pointer. It also can only be gotten from already Saved Objects, or objects that are about to be saved in the same frame as the ID reference, so we can guarantee that the ID points to something that exists, anywhere it's used. Placeholder Pointers will always be resolved to real object IDs by the time of serialization, so it's serialized as simply an object ID.
-}
id : PrimitiveCodec (ID userType)
id =
    Primitives.id


{-| Codec for serializing a `Bool`
-}
bool : PrimitiveCodec Bool
bool =
    Primitives.bool


{-| Codec for serializing an `Int`
-}
int : PrimitiveCodec Int
int =
    Primitives.int


{-| Codec for serializing a `Float`
-}
float : PrimitiveCodec Float
float =
    Primitives.float


{-| Codec for serializing a `Char`
-}
char : PrimitiveCodec Char
char =
    Primitives.char


{-| Codec for serializing `()` (aka `Unit`).
-}
unit : PrimitiveCodec ()
unit =
    Replicated.Codec.DataStructures.Immutable.SyncSafe.unit


{-| Codec for serializing [`Bytes`](https://package.elm-lang.org/packages/elm/bytes/latest/).
This is useful in combination with `mapValid` for encoding and decoding data using some specialized format.

    imageCodec : S.Codec String Image
    imageCodec =
        S.bytes
            |> S.mapValid
                (Image.decode >> Result.fromMaybe "Failed to decode PNG image.")
                Image.toPng

-}
bytes : PrimitiveCodec Bytes.Bytes
bytes =
    Replicated.Codec.DataStructures.Immutable.SyncSafe.bytes


{-| Codec for serializing an integer ranging from 0 to 255.
This is useful if you have a small integer you want to serialize and not use up a lot of space.

    type alias Color =
        { red : Int
        , green : Int
        , blue : Int
        }

    color : S.Codec e Color
    color =
        Color.record Color
            |> S.field .red byte
            |> S.field .green byte
            |> S.field .blue byte
            |> S.finishRecord

**Warning:** values greater than 255 or less than 0 will wrap around.
So if you encode -1 you'll get back 255 and if you encode 257 you'll get back 2.

-}
byte : PrimitiveCodec Int
byte =
    Replicated.Codec.DataStructures.Immutable.SyncSafe.byte



-- IMMUTABLE DATA STRUCTURES - SYNC-SAFE -------------------
-- the values within theses basic data structures cannot be individually changed, but they are typically used in cases where the entire data structure value gets replaced anyway, so they're sync-safe.


{-| Codec for serializing a `Maybe`

maybeIntCodec : Codec e (Maybe Int)
maybeIntCodec =
S.maybe S.int

-}
maybe : Codec s o a -> SelfSeededCodec {} (Maybe a)
maybe justCodec =
    Replicated.Codec.DataStructures.Immutable.SyncSafe.maybe justCodec


{-| Codec for serializing a tuple with 2 elements

    pointCodec : Codec e ( Float, Float ) ( Float, Float )
    pointCodec =
        Codec.tuple Codec.float Codec.float

-}
pair : Codec ia oa a -> Codec ib ob b -> NullCodec ( a, b )
pair codecFirst codecSecond =
    Replicated.Codec.DataStructures.Immutable.SyncSafe.pair codecFirst codecSecond


{-| Codec for serializing a tuple with 3 elements

    pointCodec : S.Codec e ( Float, Float, Float )
    pointCodec =
        S.tuple S.float S.float S.float

-}
triple : Codec ia oa a -> Codec ib ob b -> Codec ic oc c -> SelfSeededCodec {} ( a, b, c )
triple codecFirst codecSecond codecThird =
    Replicated.Codec.DataStructures.Immutable.SyncSafe.triple codecFirst codecSecond codecThird


{-| Codec for serializing a `Result`
-}
result : Codec sa oa error -> Codec sb ob value -> SelfSeededCodec {} (Result error value)
result errorCodec valueCodec =
    Replicated.Codec.DataStructures.Immutable.SyncSafe.result errorCodec valueCodec


{-| A fragile^ codec for serializing an item from a list of possible items.
Great for Custom Types where each variant has no arguments.

  - If you try to encode an item that isn't in the list then the first item is defaulted to.
  - The "quick" version will not serialize with human-readable tags
  - Only add new items to the end of the list.
  - ^Inserting new items in the middle of the list will corrupt old data.
  - ^Removing items will corrupt old data.
  - Prefer `enum` for a codec without these limitations.

```
type DaysOfWeek
    = Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday

daysOfWeekCodec : S.Codec e DaysOfWeek
daysOfWeekCodec =
    Codec.quickEnum Monday [ Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday ]
```

-}
quickEnum : a -> List a -> PrimitiveCodec a
quickEnum defaultItem items =
    Replicated.Codec.DataStructures.Immutable.SyncSafe.quickEnum defaultItem items



-- MUTABLE DATA STRUCTURES - SYNC-SAFE -------------------


{-| A replicated list
-}
repList : Codec memberSeed o memberType -> WrappedCodec (RepList memberType)
repList memberCodec =
    Replicated.Codec.DataStructures.Mutable.repList memberCodec


{-| A replicated set specifically for reptype members, with dictionary features such as getting a member by ID.
-}
repDb : Codec s SoloObject memberType -> WrappedCodec (RepDb memberType)
repDb memberCodec =
    Replicated.Codec.DataStructures.Mutable.repDb memberCodec


{-| A replicated dictionary.
-}
repDict : PrimitiveCodec k -> Codec vi o v -> WrappedCodec (RepDict k v)
repDict keyCodec valueCodec =
    Replicated.Codec.DataStructures.Mutable.repDict keyCodec valueCodec


{-| Codec for a replicated store. Accepts a key codec and a value codec.

  - The value type's codec can't have a creation changer, since there is no explicit creation in a store.
  - For the same reason, it can't have a seed.
    (Forcing the seed to be the key would work, but in practice that turns out not to be useful - you could customize the value's defaults based on the key, but you usually need outside information to do so, and this could be accomplished by wrapping `get` with your own accessor function that provides fallbacks for `Nothing` based on the key. It would also allow one to store the key in the value, which is a waste of resources.

-}
repStore : PrimitiveCodec k -> Codec (any -> List Change) o v -> WrappedCodec (RepStore k v)
repStore keyCodec valueCodec =
    Replicated.Codec.DataStructures.Mutable.repStore keyCodec valueCodec


{-| Codec for a tuple with individually changeable values.
Stored as a two-field Register.
Doesn't support seeded reptypes.
-}
seedlessPair : WrappedOrSkelCodec s1 a -> WrappedOrSkelCodec s2 b -> SkelCodec ( a, b )
seedlessPair codecFirst codecSecond =
    Replicated.Codec.DataStructures.Mutable.seedlessPair codecFirst codecSecond



-- IMMUTABLE DATA STRUCTURES - SYNC-UNSAFE -------------------


{-| Codec for an elm `List` primitive. Not sync-safe.
You will not be able to change the contents without replacing the entire list, and such changes will not merge nicely with concurrent changes, so consider using a `RepList` instead!
That said, useful for one-off lists, or Json serialization.
-}
list : Codec s o a -> Codec (List a) {} (List a)
list codec =
    Replicated.Codec.DataStructures.Immutable.SyncUnsafe.list codec


{-| Codec for a `Nonempty` List. Not sync-safe.
-}
nonempty : SelfSeededCodec o userType -> SelfSeededCodec {} (Nonempty userType)
nonempty wrappedCodec =
    Replicated.Codec.DataStructures.Immutable.SyncUnsafe.nonempty wrappedCodec


{-| Codec for serializing an `Array`. Not sync-safe.
-}
array : SelfSeededCodec o a -> SelfSeededCodec {} (Array a)
array codec =
    Replicated.Codec.DataStructures.Immutable.SyncUnsafe.array codec


{-| Codec for serializing a `Dict`

    type alias Name =
        String

    peoplesAgeCodec : S.Codec e (Dict Name Int)
    peoplesAgeCodec =
        S.dict S.string S.int

    Not sync-safe : use RepDict instead.

-}
dict : PrimitiveCodec comparable -> Codec s o a -> SelfSeededCodec {} (Dict comparable a)
dict keyCodec valueCodec =
    Replicated.Codec.DataStructures.Immutable.SyncUnsafe.dict keyCodec valueCodec


{-| Codec for serializing a `Set`. Not sync-safe.
-}
set : PrimitiveCodec comparable -> SelfSeededCodec {} (Set comparable)
set codec =
    Replicated.Codec.DataStructures.Immutable.SyncUnsafe.set codec



-- REGISTERS ------------------------


type alias FieldIdentifier =
    Replicated.Codec.RegisterField.Shared.FieldIdentifier


type alias FieldName =
    Replicated.Codec.RegisterField.Shared.FieldName


type alias FieldSlot =
    Replicated.Codec.RegisterField.Shared.FieldSlot


type alias FieldValue =
    Replicated.Codec.RegisterField.Shared.FieldValue


{-| Start the record codec for a Register.
Be sure to finish it off with a finisher function.
-}
record : remaining -> PartialRegister i full remaining
record remainingConstructor =
    Replicated.Codec.Register.record remainingConstructor


{-| Read a record field.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Your code will not be able to make changes to this field, only read the value set by other sources. Consider "writable" if you want a read+write field. You will need to prefix your field's type with `RW`.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the field in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
field : FieldIdentifier -> (full -> fieldType) -> Codec fieldType o fieldType -> fieldType -> PartialRegister i full (fieldType -> remaining) -> PartialRegister i full remaining
field ( fieldSlot, fieldName ) fieldGetter fieldCodec fieldDefault soFar =
    Replicated.Codec.Register.field ( fieldSlot, fieldName ) fieldGetter fieldCodec fieldDefault soFar


{-| Read a field containing a nested register, using an auto-generated default.

  - This field is read-only, which is good because you can use the nested register's native way of writing changes. For example, a nested record can have `RW` fields, you can `Change` it that way.
  - Auto-generating a default only works for seedless codecs - make sure your codec is of type `SkelCodec e MyType`, aka the seed is `()`. If you have a seeded object to put here, see `seededR` instead.

-}
fieldReg : FieldIdentifier -> (full -> fieldType) -> WrappedOrSkelCodec s fieldType -> PartialRegister i full (fieldType -> remaining) -> PartialRegister i full remaining
fieldReg ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar =
    Replicated.Codec.Register.fieldReg ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar


{-| Read a field containing a nested record, using an auto-generated default.

  - This field is read-only, which is good because you can use the nested register's native way of writing changes. For example, a nested record can have `RW` fields, you can `Change` it that way.
  - Naked records "skeletons" can only be initialized this way, or using full record literal syntax.

-}
fieldRec : FieldIdentifier -> (full -> fieldType) -> SkelCodec fieldType -> PartialRegister i full (fieldType -> remaining) -> PartialRegister i full remaining
fieldRec ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar =
    Replicated.Codec.Register.fieldRec ( fieldSlot, fieldName ) fieldGetter fieldCodec soFar


{-| Read a `Maybe something` field without adding the `maybe` codec. Default is Nothing.

  - If your field will more often be set to something else (e.g. `Just 0`), consider using `readable` with your `maybe`-wrapped codec instead and using the common value as the default. This will save space and bandwidth.

-}
maybeR : FieldIdentifier -> (full -> Maybe justFieldType) -> Codec o fieldSeed justFieldType -> PartialRegister i full (Maybe justFieldType -> remaining) -> PartialRegister i full remaining
maybeR fieldID fieldGetter fieldCodec recordBuilt =
    Replicated.Codec.Register.maybeR fieldID fieldGetter fieldCodec recordBuilt


{-| Read a `RepList` field without adding the `repList` codec. Default is an empty `RepList`.

  - Will not work with primitive `List` fields. For that, use the `immutableList` codec with `field`.
  - Default is an empty RepList. Want a different default? Use `field` with the `repList` codec.
  - If any items in the RepList are corrupted, they will be silently excluded.
  - If your field is not a `RepList` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repList` codec instead.

-}
fieldList : FieldIdentifier -> (full -> RepList memberType) -> Codec o memberSeed memberType -> PartialRegister i full (RepList memberType -> remaining) -> PartialRegister i full remaining
fieldList fieldID fieldGetter fieldCodec recordBuilt =
    Replicated.Codec.Register.fieldList fieldID fieldGetter fieldCodec recordBuilt


{-| Read a `RepDict` field without adding the `repDict` codec. Default is an empty `RepDict`. Instead of supplying a single codec for members, you provide a pair of codec in a tuple, e.g. `(string, bool)`.

  - Will not yet work with primitive `Dict` fields. For that, use the `immutableList` codec with `field`.
  - Default is an empty RepDict. Want a different default? Use `field` with the `repDict` codec.
  - If any items in the RepDict are corrupted, they will be silently excluded.
  - If your field is not a `RepDict` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repDict` codec instead.

-}
fieldDict : FieldIdentifier -> (full -> RepDict keyType valueType) -> ( PrimitiveCodec keyType, Codec valInit o valueType ) -> PartialRegister i full (RepDict keyType valueType -> remaining) -> PartialRegister i full remaining
fieldDict fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt =
    Replicated.Codec.Register.fieldDict fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt


{-| Read a `RepStore` field without adding the `repStore` codec. Default is an empty `RepStore`. Instead of supplying a single codec for members, you provide a pair of codec in a tuple, e.g. `(string, bool)`.

  - Default is an empty RepStore. Want a different default? Use `field` with the `repStore` codec.
  - If any items in the RepStore are corrupted, they will be silently excluded.
  - If your field is not a `RepStore` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repStore` codec instead.

-}
fieldStore : FieldIdentifier -> (full -> RepStore keyType valueType) -> ( PrimitiveCodec keyType, Codec (any -> List Change) o valueType ) -> PartialRegister i full (RepStore keyType valueType -> remaining) -> PartialRegister i full remaining
fieldStore fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt =
    Replicated.Codec.Register.fieldStore fieldID fieldGetter ( keyCodec, valueCodec ) recordBuilt


{-| Read a `RepDb` field without adding the `repDb` codec. Default is an empty `RepDb`.

  - If any items in the RepDb are corrupted, they will be silently excluded.
  - If your field is not a `RepDb` but a type that wraps one (or more), you will need to use `field` or `fieldRW` with the `repDb` codec instead.

-}
fieldDb : FieldIdentifier -> (full -> RepDb memberType) -> Codec memberSeed SoloObject memberType -> PartialRegister i full (RepDb memberType -> remaining) -> PartialRegister i full remaining
fieldDb fieldID fieldGetter fieldCodec recordBuilt =
    Replicated.Codec.Register.fieldDb fieldID fieldGetter fieldCodec recordBuilt


{-| Read a record field wrapped with `RW` and `Maybe`. This makes the field writable and optional.
Equivalent to using `fieldRW` with the `maybe` codec wrapper and a `Nothing` default value.

  - Due to the RW wrapper, you will need to add `.get` to the output whenever you want to access the field's latest value as usual. Read-only fields do not require this.
  - Thanks to the RW wrapper, you can add `.set` to the output anywhere in your program to produce a `Change`. These changes can then be saved, updating the stored value.

-}
fieldRWM : FieldIdentifier -> (full -> RWMaybe fieldType) -> Codec fieldSeed o fieldType -> PartialRegister i full (RWMaybe fieldType -> remaining) -> PartialRegister i full remaining
fieldRWM fieldIdentifier fieldGetter fieldCodec soFar =
    Replicated.Codec.Register.fieldRWM fieldIdentifier fieldGetter fieldCodec soFar


{-| Read a record field wrapped with `RW`. This makes the field writable.
The last argument specifies a default value, which is used when initializing the record for the first time.

  - Due to the RW wrapper, you will need to add `.get` to the output whenever you want to access the field's latest value as usual. Read-only fields do not require this.
  - Thanks to the RW wrapper, you can add `.set` to the output anywhere in your program to produce a `Change`. These changes can then be saved, updating the stored value.
  - Consider setting the default to the "most popular" value (e.g. "scaling factor" set to 1.0), as it will be omitted from the serialized data, saving space and bandwidth.
  - Consider setting the default to the "safest" value, as missing fields will be parsed as the default.
  - If you can't come up with a sensible default value (e.g. date of birth), consider wrapping the field in `Maybe` or `Result`, with e.g. `Nothing` or `Err Unset` as the default.
  - If there's no sensible default and this record is not useful with missing data unless you add another validation step ("Parse, Don't Validate"!), consider `readableRequired` as a last resort.

-}
fieldRW : FieldIdentifier -> (full -> RW fieldType) -> Codec fieldType o fieldType -> fieldType -> PartialRegister i full (RW fieldType -> remaining) -> PartialRegister i full remaining
fieldRW fieldIdentifier fieldGetter fieldCodec fieldDefault soFar =
    Replicated.Codec.Register.fieldRW fieldIdentifier fieldGetter fieldCodec fieldDefault soFar


{-| Read a field that is required, yet has no sensible default. Use sparingly.

  - Only add required fields BEFORE using in production for the first time.
  - NEVER add required fields after that, or old data may be seen as corrupt.
  - Useful for "Parse, Don't Validate" as you can use this to avoid extra validation later, e.g. `Maybe` wrappers on fields that should never be missing.
  - Will it be essential forever? Once you require a field, you can't make it optional later - omitted values from new clients will be seen as corrupt by old ones!
  - Consider if this field being set upfront is essential to this record. For graceful degradation, records missing essential fields will be omitted from any containing collections. If the field is in your root object, it may fail to parse entirely. (And that's exactly what you would want, if this field were truly essential.)

-}
coreR : FieldIdentifier -> (full -> fieldType) -> Codec fieldSeed o fieldType -> (parentSeed -> fieldSeed) -> PartialRegister parentSeed full (fieldType -> remaining) -> PartialRegister parentSeed full remaining
coreR fieldID fieldGetter fieldCodec seeder recordBuilt =
    Replicated.Codec.Register.coreR fieldID fieldGetter fieldCodec seeder recordBuilt


{-| Read and Write a core field. A core field is both required, AND has no sensible default. Prefer non-core fields when possible.

Including any core fields in your register will force you to pass in a "seed" any time you initialize it. The seed value contains whatever you need to initialize all the core fields. Registers that do not need seeds are more robust to serialization!

  - If this field is truly unique to the register upon initialization, does it really need to be writable? Consider using `coreR` instead, so your code can initialize the field with a seed but not accidentally modify it later.

-}
coreRW : FieldIdentifier -> (full -> RW fieldType) -> Codec fieldSeed o fieldType -> (parentSeed -> fieldSeed) -> PartialRegister parentSeed full (RW fieldType -> remaining) -> PartialRegister parentSeed full remaining
coreRW fieldID fieldGetter fieldCodec seeder recordBuilt =
    Replicated.Codec.Register.coreRW fieldID fieldGetter fieldCodec seeder recordBuilt


{-| Read a field that needs a seed.
Pass in a `(\parentSeed -> fieldSeed)` function, which gives you access to the parent's seed, if it has one. Otherwise, that's just `()` The return value will be used to seed the field.

  - Does your field actually need to be available as soon as the parent exists? If not, consider wrapping it in something like `Maybe` so you can give a it a default of `Nothing` and seed it when you actually need it. Then you don't need a seed from the parent.
  - You can use this to seed the field with a constant, ignoring the parent seed like `(\_ -> [1,2,3])` if you need that for some reason. But if a constant works, your field's type can probably be made seedless anyway. You can also just use a field default, rather than seeding, so your parent register can be seedless.

-}
seededR : FieldIdentifier -> (full -> fieldType) -> Codec fieldSeed o fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister parentSeed full (fieldType -> remaining) -> PartialRegister parentSeed full remaining
seededR fieldID fieldGetter fieldCodec default seeder recordBuilt =
    Replicated.Codec.Register.seededR fieldID fieldGetter fieldCodec default seeder recordBuilt


{-| Read/Write a field that needs a seed.
Pass in a `(\parentSeed -> fieldSeed)` function, which gives you access to the parent's seed, if it has one. Otherwise, that's just `()` The return value will be used to seed the field.

  - Does your field actually need to be available as soon as the parent exists? If not, consider wrapping it in something like `Maybe` so you can give a it a default of `Nothing` and seed it when you actually need it. Then you don't need a seed from the parent.
  - You can use this to seed the field with a constant, ignoring the parent seed like `(\_ -> [1,2,3])` if you need that for some reason. But if a constant works, your field's type can probably be made seedless anyway. You can also just use a field default, rather than seeding, so your parent register can be seedless.

-}
seededRW : FieldIdentifier -> (full -> RW fieldType) -> Codec fieldSeed o fieldType -> fieldType -> (parentSeed -> fieldSeed) -> PartialRegister parentSeed full (RW fieldType -> remaining) -> PartialRegister parentSeed full remaining
seededRW fieldID fieldGetter fieldCodec default seeder recordBuilt =
    Replicated.Codec.Register.seededRW fieldID fieldGetter fieldCodec default seeder recordBuilt



-- FINISHERS


{-| Finish creating a codec for a naked Register.
This is a Register, stripped of its wrapper.
Upgrade to a fully wrapped Register for features such as versioning and time travel.
-}
finishRecord : PartialRegister () full full -> SkelCodec full
finishRecord partialRegister =
    Replicated.Codec.Register.finishRecord partialRegister


{-| Finish creating a codec for a naked Register.
This is a Register, stripped of its wrapper.
-}
finishSeededRecord : PartialRegister s full full -> Codec s SoloObject full
finishSeededRecord partialRegister =
    Replicated.Codec.Register.finishSeededRecord partialRegister


{-| Finish creating a codec for a register.
-}
finishRegister : PartialRegister () full full -> WrappedCodec (Reg full)
finishRegister partialRegister =
    Replicated.Codec.Register.finishRegister partialRegister


{-| Finish creating a codec for a register that needs a seed.
-}
finishSeededRegister : PartialRegister s full full -> WrappedSeededCodec s (Reg full)
finishSeededRegister partialRegister =
    Replicated.Codec.Register.finishSeededRegister partialRegister


{-| Does nothing but remind you not to reuse historical slots
-}
obsolete : List FieldIdentifier -> anything -> anything
obsolete reservedList input =
    input



---- MAPPING


{-| Map from one codec to another codec

    import Serialize as S

    type UserId
        = UserId Int

    userIdCodec : S.Codec e UserId
    userIdCodec =
        S.int |> S.map UserId (\(UserId id) -> id)

Note that there's nothing preventing you from encoding Elm values that will map to some different value when you decode them.
I recommend writing tests for Codecs that use `map` to make sure you get back the same Elm value you put in.
[Here's some helper functions to get you started.](https://github.com/MartinSStewart/elm-geometry-serialize/blob/6f2244c28631ede1b864cb43541d1573dc628904/tests/Tests.elm#L49-L74)

-}
map : (a -> b) -> (b -> a) -> Codec a o a -> Codec b o b
map fromAtoB fromBtoA codec =
    Base.map fromAtoB fromBtoA codec


{-| Make a record Codec an opaque type by wrapping it with an opaque type constructor. Seed does not change type.
-}
makeOpaque : (a -> b) -> (b -> a) -> Codec i o a -> Codec i o b
makeOpaque fromAtoB fromBtoA codec =
    Base.makeOpaque fromAtoB fromBtoA codec


{-| Map from one codec to another codec in a way that can potentially fail when decoding.

    -- Email module is from https://package.elm-lang.org/packages/tricycle/elm-email/1.0.2/


    import Email
    import Serialize as S

    emailCodec : S.Codec String Float
    emailCodec =
        S.string
            |> S.mapValid
                (\text ->
                    case Email.fromString text of
                        Just email ->
                            Ok email

                        Nothing ->
                            Err "Invalid email"
                )
                Email.toString

Note that there's nothing preventing you from encoding Elm values that will produce Err when you decode them.
I recommend writing tests for Codecs that use `mapValid` to make sure you get back the same Elm value you put in.

-}
mapValid : (a -> Result e b) -> (b -> a) -> SelfSeededCodec o a -> SelfSeededCodec o b
mapValid fromBytes_ toBytes_ codec =
    Base.mapValid fromBytes_ toBytes_ codec


{-| Map errors generated by `mapValid`.
-}
mapError : (e1 -> e2) -> PrimitiveCodec a -> PrimitiveCodec a
mapError mapFunc codec =
    Base.mapError mapFunc codec



-- STACK UNSAFE


{-| Handle situations where you need to define a codec in terms of itself.

    type Peano
        = Peano (Maybe Peano)

    {-| The compiler will complain that this function causes an infinite loop.
    -}
    badPeanoCodec : Codec e Peano
    badPeanoCodec =
        maybe badPeanoCodec |> map Peano (\(Peano a) -> a)

    {-| Now the compiler is happy!
    -}
    goodPeanoCodec : Codec e Peano
    goodPeanoCodec =
        maybe (lazy (\() -> goodPeanoCodec)) |> map Peano (\(Peano a) -> a)

**Warning:** This is not stack safe.

In general if you have a type that contains itself, like with our the Peano example, then you're at risk of a stack overflow while decoding.
Even if you're translating your nested data into a list before encoding, you're at risk, because the function translating back after decoding can cause a stack overflow if the original value was nested deeply enough.
Be careful here, and test your codecs using elm-test with larger inputs than you ever expect to see in real life.

-}
lazy : (() -> Codec s o a) -> Codec s o a
lazy f =
    Base.lazy f


{-| When you haven't gotten to writing a Codec for this yet.
-}
todo : a -> PrimitiveCodec a
todo bogusValue =
    Replicated.Codec.Primitives.todo bogusValue



-- CUSTOM


type alias VariantTag =
    Replicated.Codec.CustomType.VariantTag


{-| A partially built codec for a custom type.
-}
type alias CustomTypeCodec a matcher v =
    Replicated.Codec.CustomType.CustomTypeCodec a matcher v


{-| Starts building a `Codec` for a custom type.
You need to pass a pattern matchering function, see the FAQ for details.

    import Serialize as S

    type Semaphore
        = Red Int String Bool
        | Yellow Float
        | Green

    semaphoreCodec : Codec e Semaphore
    semaphoreCodec =
        Codec.customType
            (\redEncoder yellowEncoder greenEncoder value ->
                case value of
                    Red i s b ->
                        redEncoder i s b

                    Yellow f ->
                        yellowEncoder f

                    Green ->
                        greenEncoder
            )
            |> Codec.variant3 ( 1, "Red" ) Red S.int S.string S.bool
            |> Codec.variant1 ( 2, "Yellow" ) Yellow S.float
            |> Codec.variant0 ( 3, "Green" ) Green
            |> Codec.finishCustomType

-}
customType : matcher -> CustomTypeCodec { youNeedAtLeastOneVariant : () } matcher value
customType matcher =
    Replicated.Codec.CustomType.customType matcher


{-| Define a variantBuilder with 0 parameters for a custom type.
-}
variant0 : VariantTag -> v -> CustomTypeCodec z (VariantEncoder -> a) v -> CustomTypeCodec () a v
variant0 tag ctor =
    Replicated.Codec.CustomType.variant0 tag ctor


{-| Define a variantBuilder with 1 parameters for a custom type.
-}
variant1 :
    VariantTag
    -> (a -> v)
    -> Codec ia oa a
    -> CustomTypeCodec z ((a -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant1 tag ctor codec1 =
    Replicated.Codec.CustomType.variant1 tag ctor codec1


{-| Define a variantBuilder with 2 parameters for a custom type.
-}
variant2 :
    VariantTag
    -> (a -> b -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> CustomTypeCodec z ((a -> b -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant2 tag ctor codec1 codec2 =
    Replicated.Codec.CustomType.variant2 tag ctor codec1 codec2


{-| Define a variantBuilder with 3 parameters for a custom type.
-}
variant3 :
    VariantTag
    -> (a -> b -> c -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> CustomTypeCodec z ((a -> b -> c -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant3 tag ctor codec1 codec2 codec3 =
    Replicated.Codec.CustomType.variant3 tag ctor codec1 codec2 codec3


{-| Define a variantBuilder with 4 parameters for a custom type.
-}
variant4 :
    VariantTag
    -> (a -> b -> c -> d -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> CustomTypeCodec z ((a -> b -> c -> d -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant4 tag ctor codec1 codec2 codec3 codec4 =
    Replicated.Codec.CustomType.variant4 tag ctor codec1 codec2 codec3 codec4


{-| Define a variantBuilder with 5 parameters for a custom type.
-}
variant5 :
    VariantTag
    -> (a -> b -> c -> d -> e -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> Codec ie oe e
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant5 tag ctor codec1 codec2 codec3 codec4 codec5 =
    Replicated.Codec.CustomType.variant5 tag ctor codec1 codec2 codec3 codec4 codec5


{-| Define a variantBuilder with 6 parameters for a custom type.
-}
variant6 :
    VariantTag
    -> (a -> b -> c -> d -> e -> f -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> Codec ie oe e
    -> Codec if_ of_ f
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> f -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant6 tag ctor codec1 codec2 codec3 codec4 codec5 codec6 =
    Replicated.Codec.CustomType.variant6 tag ctor codec1 codec2 codec3 codec4 codec5 codec6


{-| Define a variantBuilder with 7 parameters for a custom type.
-}
variant7 :
    VariantTag
    -> (a -> b -> c -> d -> e -> f -> g -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> Codec ie oe e
    -> Codec if_ of_ f
    -> Codec ig og g
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> f -> g -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant7 tag ctor codec1 codec2 codec3 codec4 codec5 codec6 codec7 =
    Replicated.Codec.CustomType.variant7 tag ctor codec1 codec2 codec3 codec4 codec5 codec6 codec7


{-| Define a variantBuilder with 8 parameters for a custom type.
-}
variant8 :
    VariantTag
    -> (a -> b -> c -> d -> e -> f -> g -> h -> v)
    -> Codec ia oa a
    -> Codec ib ob b
    -> Codec ic oc c
    -> Codec id od d
    -> Codec ie oe e
    -> Codec if_ of_ f
    -> Codec ig og g
    -> Codec ih o h
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> f -> g -> h -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant8 tag ctor codec1 codec2 codec3 codec4 codec5 codec6 codec7 codec8 =
    Replicated.Codec.CustomType.variant8 tag ctor codec1 codec2 codec3 codec4 codec5 codec6 codec7 codec8


{-| Finish creating a codec for a custom type.
-}
finishCustomType : CustomTypeCodec () (a -> VariantEncoder) a -> NullCodec a
finishCustomType codec =
    Replicated.Codec.CustomType.finishCustomType codec
