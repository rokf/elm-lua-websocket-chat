module Main exposing (..)

import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import WebSocket
import Regex
import Array

type Msg = SendMsg | ReceivedMessage String | NewMessage String

type alias Model =
  {  server_address : Maybe String
  ,  message_text : String
  ,  messages : List (String, String)
  ,  uuid : Maybe String
  }

main =
  Html.program
  {  init = init
  ,  view = view
  ,  update = update
  ,  subscriptions = subscriptions
  }

initial_model : Model
initial_model =
  {  server_address = Just "ws://127.0.0.1:4000"
  ,  message_text = ""
  ,  messages = []
  ,  uuid = Nothing
  }

init : (Model, Cmd Msg)
init =
  (initial_model,Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen (Maybe.withDefault "" model.server_address) ReceivedMessage

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewMessage m ->
      ({model|message_text = m},Cmd.none)
    ReceivedMessage str ->
      -- MATCH WITH REGEX AND APPEND TO model.messages
      let
        regexres = Array.fromList <| Regex.split (Regex.AtMost 1) (Regex.regex ":") str
        first = Maybe.withDefault "" (Array.get 0 regexres)
        second = Maybe.withDefault "" (Array.get 1 regexres)
      in
        if first == "uuid" then
          ({ model|uuid = Just second },Cmd.none)
        else
          if List.length model.messages >= 13 then
            ({model|messages = ((Maybe.withDefault [] (List.tail model.messages)) ++ [(first,second)])}, Cmd.none)
          else
            ({model|messages = (model.messages ++ [(first,second)])}, Cmd.none)
    SendMsg ->
      ({model|message_text = ""}, WebSocket.send (Maybe.withDefault "" model.server_address) model.message_text)

tastyle =
  HA.style
  [  ("resize", "none")
  ]

msgView : (String,String) -> Html Msg
msgView (uid,msg) =
  let
    regexres = Array.fromList <| Regex.split (Regex.AtMost 1) (Regex.regex "-") uid
    first = Maybe.withDefault "" (Array.get 0 regexres)
  in
    Html.div [HA.class "flex-1 flex flex-row"]
    [  Html.p [HA.class "b pa1 ma0"] [ Html.text first ]
    ,  Html.p [HA.class "pa1 w-100 ma0"] [ Html.text msg ]
    ]

view : Model -> Html Msg
view model =
  Html.div [HA.class "mt3 mw6 container center flex flex-column"]
  [  Html.h1 [HA.class "f2 code lh-copy"]
      [  Html.text "WebSocket Client"  ]
  ,  Html.p [HA.class "code i mt0 tracked"]
      [  Html.text (Maybe.withDefault "" model.uuid)  ]
  ,  Html.div
      [  HA.class "ba mb3"
      ,  HA.style [("height", "400px")]
      ]
      (List.map msgView model.messages)
  ,  Html.div [HA.class "flex flex-row justify-start"]
      [  Html.input
          [  HA.class "input-reset ba b--black mr1 pa1 w-100"
          ,  HE.onInput NewMessage
          ,  HA.value model.message_text
          ,  HA.placeholder "message"
          ] []
      ,  Html.button
          [  HA.class "button-reset ba b--black pa1 ph3"
          ,  HE.onClick SendMsg
          ] [ Html.text "Send" ]
      ]
  ]
