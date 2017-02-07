module Reference.ScrolledPanel exposing (..)

import Components.Reference
import Icons

import Ui.ScrolledPanel

import Html exposing (text)

view : Html.Html msg
view =
  let
    demo =
      Ui.ScrolledPanel.view []
        [ text
            """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean
            a pharetra felis, ac rutrum velit. Nullam id rutrum dolor, non
            commodo mi. Nam congue semper lacinia. Proin suscipit ultrices
            congue. Aliquam tempus porttitor dui, ut luctus orci. Nulla
            facilisis fermentum magna nec egestas. Vestibulum ultricies eget
            massa vel venenatis. Aliquam mollis congue fermentum. Fusce id
            magna eget lectus ullamcorper mollis. Vestibulum dignissim imperdiet
            tortor, quis vulputate orci condimentum sit amet. Donec interdum
            nibh orci, ut sagittis libero dignissim nec.Fusce vehicula nibh in
            nulla aliquam, quis ultrices justo porttitor. Donec pretium dolor
            porttitor condimentum vulputate. Morbi sed sodales quam.
            Suspendisse potenti. Nam non hendrerit orci. Integer et odio
            porta sapien malesuada commodo vitae aliquet erat. Nunc tincidunt
            facilisis turpis. Interdum et malesuada fames ac ante ipsum
            primis in faucibus.
            """
        ]
  in
    Components.Reference.view demo (text "")
