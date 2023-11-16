# TODO only run if pathces are not already applied

# TODO how to get elm to re-compute only the selected packages without blowing them all away
rm -rf ~/.elm/0.19.1/packages/ && \
elm make --output=/dev/null elm-patches/dummyproject/Dummy.elm && \
make --directory ./elm-patches && \
rm -rf elm-stuff