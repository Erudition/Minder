module Replicated.Codec.RegisterField.Shared exposing (..)


type alias FieldIdentifier =
    ( FieldSlot, FieldName )


type alias FieldName =
    String


type alias FieldSlot =
    Int


type alias FieldValue =
    String


type FieldFallback parentSeed fieldSeed fieldType
    = HardcodedDefault fieldType
    | PlaceholderDefault fieldSeed
    | InitWithParentSeed (parentSeed -> fieldSeed)
    | DefaultFromParentSeed (parentSeed -> fieldType)
    | DefaultAndInitWithParentSeed fieldType (parentSeed -> fieldSeed)
