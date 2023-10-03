module HashRouting exposing (transformToHashUrl)

import Url exposing (Url)


transformToHashUrl : Url -> Maybe Url
transformToHashUrl url =
    let
        protocol : String
        protocol =
            case url.protocol of
                Url.Http ->
                    "http://"

                Url.Https ->
                    "https://"

                Url.File ->
                    "file://"

                _ ->
                    "other-fixme://"

        host : String
        host =
            url.host

        port_ : String
        port_ =
            case url.port_ of
                Just int ->
                    ":" ++ String.fromInt int

                Nothing ->
                    ""

        fragment : String
        fragment =
            Maybe.withDefault "" url.fragment
    in
    [ protocol, host, port_, fragment ]
        |> String.concat
        |> Url.fromString
