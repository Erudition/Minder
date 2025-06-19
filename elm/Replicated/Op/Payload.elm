module Replicated.Op.Payload exposing (..)

import Json.Encode as JE
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Replicated.Op.Atom as Atom exposing (Atom)


type alias Payload =
    List Atom


toJsonValue : Nonempty Atom -> JE.Value
toJsonValue (Nonempty head tail) =
    case tail of
        [] ->
            Atom.toJsonValue head

        multiple ->
            JE.list identity (List.map Atom.toJsonValue (head :: multiple))
