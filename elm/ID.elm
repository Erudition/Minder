module ID exposing
    ( ID
    , fromObjectID, fromPointer, getObjectID, toInt, toPointer, toString
    )

{-| This package exposes a really simple type called `ID`.
type ID x
= ID String
Its for when your data has an id. Such as..
import ID exposing (ID)
type alias User =
{ id : ID ()
, email : String
}


### Why an `ID` and not a `String`?

The Elm compiler is totally okay with the following code snippet..
viewUser : String -> String -> Html Msg
viewUser email id =
-- first parameter is email
-- second parameter is id
view : Model -> Html Msg
view model =
div
[][ viewUser
-- woops! The parameters are mixed up
model.user.id
model.user.email
]
These mistake is really easy to make and they cause real problems, but if you just use an `ID` you can make them impossible.


### Whats the `x` in `ID x` for?

You understand the problem in the previous example right? Here is a very similar problem..
type ID
= ID String
updateUsersCatsFavoriteFood : ID -> ID -> ID -> Cmd Msg
updateUsersCatsFavoriteFood userID catID foodID =
-- ..
Theres absolutely nothing stopping a developer from mixing up a `catID` with a `userID` or a `foodID` with a `catID`.
Instead we can do..
type ID x
= ID String
updateUsersCatsFavoriteFood : ID User -> ID Cat -> ID Food -> Cmd Msg
updateUsersCatsFavoriteFood userID catID foodID =
-- ..
Now with `ID x`, it is impossible (again) to mix up a `ID User` with a `ID Cat`. They have different types. And the compiler will point out if you try and use a `ID User` where only a `ID Cat` works.


### Okay, there is one trade off

The following code is not possible due to a circular definition of `User`..
type alias User =
{ id : ID User }
Easy work arounds include..
type UserID
= UserID (ID User)
type alias User =
{ id : UserID }
and
type User
= User { id : ID User }
..but I would encourage you to build your architecture such that data _does not_ contain its own `ID x` to begin with. Instead, get used to operating on `(ID User, User)` pairs, and treat the left side as the single source of truth for that identifier.
( ID User, User )


# ID

@docs ID, encode, decode

-}

import Json.Decode.Exploration as Decode exposing (Decoder)
import Json.Encode as Encode
import Log
import Replicated.Change as Change exposing (Pointer)
import Replicated.Change.PendingID exposing (PendingID)
import Replicated.Op.ID as OpID exposing (OpID)
import Replicated.Op.ObjectHeader exposing (ObjectHeader)


type ID userType
    = IDFromExisting OpID.ObjectID
    | IDFromPlaceholder PendingID


{-| Tag a pointer, making it a type-constrained ID!
-}
fromPointer : Pointer -> ID userType
fromPointer pointer =
    case pointer of
        Change.ExistingObjectPointer existingID ->
            IDFromExisting existingID.operationID

        Change.PlaceholderPointer pendingID _ ->
            IDFromPlaceholder pendingID


{-| Tag an ObjectID, making it a type-constrained ID!
-}
fromObjectID : OpID.ObjectID -> ID userType
fromObjectID objectID =
    IDFromExisting objectID


{-| Read an ID!
-}
toPointer reducer givenID =
    case givenID of
        IDFromExisting objectID ->
            Change.ExistingObjectPointer (ObjectHeader objectID reducer )

        IDFromPlaceholder pendingID ->
            Change.PlaceholderPointer pendingID []


getObjectID givenID =
    case givenID of
        IDFromExisting objectID ->
            Just objectID

        IDFromPlaceholder _ ->
            Nothing


toString : ID userType -> String
toString givenID =
    case givenID of
        IDFromExisting objectID ->
            OpID.toString objectID

        IDFromPlaceholder _ ->
            Log.crashInDev "Supposed to be impossible: toString called on an ID when the wrapped pointer was for a placeholder. All IDs should represent existing Objects with ObjectIDs" "Placeholder Pointer: Object Not Yet Initialized"


toInt : ID userType -> Int
toInt givenID =
    case givenID of
        IDFromExisting objectID ->
            OpID.toInt objectID

        IDFromPlaceholder _ ->
            Log.crashInDev "Supposed to be impossible: toString called on an ID when the wrapped pointer was for a placeholder. All IDs should represent existing Objects with ObjectIDs" 42
