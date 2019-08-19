cd ~/Projects/Elm/Docket/

elm make --output=www/elm-gui.js --optimize elm/Main.elm
elm make --output=www/elm-headless.js --optimize elm/Headless.elm

# Add line to elm that makes it's HTTP transparently compatible with node
(echo "var XMLHttpRequest = require('node-http-xhr');" && cat www/elm-headless.js) > www/elm-headless.js.tmp && mv www/elm-headless.js.tmp www/elm-headless.js

# make a temp Minder dir if it doesn't exist
mkdir -p /tmp/Minder


# run node
node --interactive www/headless-launch.js $1

# remove that line from the compiled elm so it works with non-node
sed -i '1d' www/elm-headless.js
