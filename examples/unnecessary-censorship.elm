module Main exposing (..)

import Canvas exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Task


type Model
    = GotCanvas Canvas
    | Loading


init =
    ( Loading, Task.attempt ImageLoaded <| loadImage "churchill.jpg" )


type Msg
    = NoOp
    | ImageLoaded (Result Error Canvas)


update msg model =
    case msg of
        ImageLoaded (Ok result) ->
            ( GotCanvas result, Cmd.none )

        ImageLoaded (Err e) ->
            ( Loading, Cmd.none )

        _ ->
            ( model, Cmd.none )


view model =
    case model of
        Loading ->
            div []
                []

        GotCanvas canvas ->
            (pixelate canvas <| initialize <| Size 616 800) |> toHtml []


pixelate : Canvas -> Canvas -> Canvas
pixelate image canvas =
    let
        scale =
            draw (Scaled (Point 0 0) (Size 30 40) |> DrawImage image) canvas

        drawOp =
            batch
                [ Scaled (Point 0 0) (Size 616 800)
                    |> DrawImage image
                , BeginPath
                , Rect (Point 70 10) (Size 80 120)
                , Clip
                , CropScaled (Point 0 0) (Size 30 40) (Point 0 0) (Size 616 800)
                    |> DrawImage scale
                ]
    in
    draw drawOp canvas


main =
    Html.program { init = init, view = view, update = update, subscriptions = always Sub.none }
