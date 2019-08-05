cd ~/Projects/Elm/Docket/

elm make --output=www/elm-gui.js elm/Main.elm
elm make --output=www/elm-headless.js --optimize elm/Headless.elm

(echo "var XMLHttpRequest = require('node-http-xhr');" && cat www/elm-headless.js) > www/elm-headless.js.tmp && mv www/elm-headless.js.tmp www/elm-headless.js

node --interactive www/headless-launch.js $1

sed -i '1d' www/elm-headless.js
