@echo off

@REM cd ~\Projects\Minder\

node_modules\elm\bin\elm make --output=www\elm-gui.js elm\Main.elm
node_modules\elm\bin\elm make --output=www\elm-browserless.js elm\Browserless.elm
node_modules\elm\bin\elm make --output=www\elm-headless.js elm\Headless.elm

node_modules\.bin\elm-live.cmd elm\Main.elm --dir=www --pushstate  -- --output=www\elm-gui.js