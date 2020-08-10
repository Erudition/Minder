cd ~/Projects/Minder/

elm make --output=www/elm-gui.js  elm/Main.elm
elm make --output=www/elm-headless.js  elm/Headless.elm


elm-live elm/Main.elm --start-page=webapp.html --dir=www --pushstate  --  --output=www/elm-gui.js
