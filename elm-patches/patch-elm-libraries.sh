# TODO only run if pathces are not already applied

rm -rf ~/.elm/0.19.1/packages/            # TODO how to get elm to re-compute only the selected packages without blowing them all away
cd elm-patches/dummyproject/              # CI env is empty so we use minimal elm.json for dummy project
rm -rf elm-stuff                          # get rid of cache in dummy project
lamdera make --output=/dev/null Dummy.elm # build dummy project and output to nowhere, so libraries are re-downloaded
cd ../..                                  # go back to project dir
make --directory ./elm-patches            # apply patches
rm -rf elm-stuff                          # get rid of cached elm builds so project will create fresh ones with patches
