module Replicated.Change.Location exposing (Location, nest, nestSingle, new, newSingle, none, toComparable, toString, wrap)


type Location
    = AncestryBackwards (List Layer)


type Layer
    = NestSingle String
    | NestMultiple String Int


newSingle : String -> Location
newSingle reasonForNew =
    AncestryBackwards [ NestSingle reasonForNew ]


new : String -> Int -> Location
new reasonForNew index =
    AncestryBackwards [ NestMultiple reasonForNew index ]


nestSingle : Location -> String -> Location
nestSingle (AncestryBackwards backwardsLayerList) layerName =
    AncestryBackwards (NestSingle layerName :: backwardsLayerList)


nest : Location -> String -> Int -> Location
nest (AncestryBackwards backwardsLayerList) layerName layerIndex =
    AncestryBackwards (NestMultiple layerName layerIndex :: backwardsLayerList)


toString : Location -> String
toString (AncestryBackwards backwardsLayers) =
    let
        forwardsLayers =
            List.reverse backwardsLayers

        cleanedList =
            case forwardsLayers of
                (NestSingle rootLayer) :: (NestSingle secondLayer) :: otherLayers ->
                    NestSingle (rootLayer ++ "(" ++ secondLayer ++ ")") :: otherLayers

                _ ->
                    forwardsLayers

        finalListString =
            List.map layerToString cleanedList
                |> String.join " ‣ "
    in
    "〖" ++ finalListString ++ "〗"


toComparable : Location -> List Int
toComparable (AncestryBackwards backwardsLayers) =
    List.reverse backwardsLayers
        |> List.map layerToInt


{-| Local helper
-}
layerToString : Layer -> String
layerToString layer =
    case layer of
        NestSingle layerName ->
            layerName

        NestMultiple layerName layerIndex ->
            layerName ++ "#" ++ String.fromInt layerIndex


{-| Local helper
-}
layerToInt : Layer -> Int
layerToInt layer =
    case layer of
        NestSingle _ ->
            0

        NestMultiple _ layerIndex ->
            layerIndex


{-| for new pointers only! Wraps the first location in the second location's layers.
-}
wrap : Location -> Location -> String -> Location
wrap (AncestryBackwards backwardsLayerListOld) (AncestryBackwards backwardsLayerListNew) middleItem =
    case backwardsLayerListNew of
        (NestMultiple childName childIndex) :: restOfNewLocationWrapper ->
            AncestryBackwards ((NestMultiple (childName ++ "(" ++ middleItem ++ ")") childIndex :: restOfNewLocationWrapper) ++ backwardsLayerListOld)

        _ ->
            AncestryBackwards (backwardsLayerListNew ++ NestSingle middleItem :: backwardsLayerListOld)


{-| Internal helper to only be used when a new context is created.
-}
none : Location
none =
    AncestryBackwards []
