module ID exposing
    ( ID(..), encode, decode
    , read, tag
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


type ID userType
    = ID Int


{-| Tag something with an ID!
-}
tag : Int -> ID userType
tag int =
    ID int


{-| Read an ID!
-}
read : ID userType -> Int
read (ID int) =
    int


{-| Encode an `ID`
Encode.encode 0 (ID.encode id)
-- ""hDFL0Cs2EqWJ4jc3kMtOrKdEUTWh"" : String
[ ("id", ID.encode id) ]
|> Encode.object
|> Encode.encode 0
-- {"id":"hDFL0Cs2EqWJ4jc3kMtOrKdEUTWh"} : String
-}
encode : ID x -> Encode.Value
encode (ID int) =
    Encode.int int


{-| Decode an `ID`
Decode.decodeString (Decode.field "id" ID.decoder) "{"id":"19"}"
-- Ok (ID "19") : Result String ID
-}
decode : Decoder (ID x)
decode =
    Decode.map ID Decode.int
