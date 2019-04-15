module Trackable.Object exposing (Trackable)


-- type alias Trackable nameTags props =
--     List ( nameTags, props )
--
--
-- get : Trackable nameTag proptype -> nameTag -> propvalue
-- get object propNameTag =
--     List.head (List.filter (tagMatches propNameTag) object)
--
--
-- tagMatches : nameTag -> ( nameTag, prop ) -> Bool
-- tagMatches targetName ( inputName, _ ) =
--     targetName == inputName

-- type alias Trackable props =
--     List props

-- get : List ContactProperty -> ContactPropertyName v -> v
-- get = List.head (List.filter (tagMatches propNameTag) object)

attempt : ContactProperty -> ContactPropertyName a -> Bool
attempt prop (propName a) =
    case prop of
        propName a ->
            True
        _ ->
            False

-- EXAMPLE USAGE -------------------------------------------
-- The fake record:


-- type alias Contact =
--     Trackable ContactProperty


type ContactProperty
    = ContactName String
    | ContactPhone PhoneNumber
    | ContactBirthday Birthday
    | ContactAddress Address


type alias ContactPropertyName a =
    a -> ContactProperty



-- dummy types:


type alias PhoneNumber =
    Int


type alias Birthday =
    Int


type alias Address =
    { num : Int, street : String, town : String, zip : Int }
