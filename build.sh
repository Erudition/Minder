cd ~/Projects/Minder/

./node_modules/.bin/elm make --output=www/elm-gui.js elm/Main.elm
./node_modules/.bin/elm make --output=www/elm-browserless.js elm/Browserless.elm
./node_modules/.bin/elm make --output=www/elm-headless.js elm/Headless.elm

./node_modules/.bin/elm-live elm/Main.elm --dir=www --pushstate --ssl -- --output=www/elm-gui.js
