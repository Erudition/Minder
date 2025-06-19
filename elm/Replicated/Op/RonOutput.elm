module Replicated.Op.RonOutput exposing (..)

import Json.Encode as JE
import List.Extra
import Replicated.Op.Atom as Atom exposing (Atom)
import Replicated.Op.ID as OpID exposing (OpID)
import Replicated.Op.Op exposing (..)
import Replicated.Op.ReducerID as ReducerID exposing (ReducerID)


type RonFormat
    = ClosedOps
    | OpenOps
    | CompressedOps (Maybe Op)


opToString : RonFormat -> Op -> String
opToString format op =
    let
        reducerIDString =
            "*" ++ ReducerID.toString (reducerID op)

        objectIDString =
            "#" ++ OpID.toString (objectID op)

        opIDString =
            "@" ++ OpID.toString (id op)

        refString =
            ":" ++ referenceToString (reference op)

        encodePayloadAtom atom =
            JE.encode 0 atom

        emptyAtom =
            " "

        inclusionList =
            case format of
                ClosedOps ->
                    [ reducerIDString, objectIDString, opIDString, refString ]

                OpenOps ->
                    [ opIDString, refString ]

                CompressedOps Nothing ->
                    [ opIDString, refString ]

                CompressedOps (Just previousOp) ->
                    case ( OpID.isIncremental (id previousOp) (id op) && not (OpID.isDeletion (id op)), reference op == OpReference previousOp ) of
                        ( True, True ) ->
                            [ emptyAtom, emptyAtom ]

                        ( True, False ) ->
                            [ emptyAtom, refString ]

                        ( False, True ) ->
                            [ opIDString, emptyAtom ]

                        ( False, False ) ->
                            [ opIDString, emptyAtom ]
    in
    String.join "\t" (inclusionList ++ List.map Atom.toRonString (payload op))


type alias FrameString =
    String


closedChunksToFrameText : List ClosedChunk -> FrameString
closedChunksToFrameText chunkList =
    let
        perChunk opsInChunk =
            case opsInChunk of
                [] ->
                    Nothing

                _ ->
                    List.Extra.mapAccuml perOp Nothing opsInChunk
                        |> Tuple.second
                        |> String.join " ,\n"
                        |> (\s -> s ++ " ;\n\n")
                        |> Just

        perOp prevOpMaybe thisOp =
            ( Just thisOp, opToString (CompressedOps prevOpMaybe) thisOp )

        -- ( Just thisOp, closedOpToString (ClosedOps) thisOp )
    in
    case List.filterMap perChunk chunkList of
        [] ->
            ""

        readyChunks ->
            String.concat readyChunks
                |> (\s -> s ++ ".❃")
