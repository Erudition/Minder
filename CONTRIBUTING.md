# Contributing Rules & Style Guide
Rough draft.

## Pull Requests Style
Pull requests must compile without warnings and be `elm-format`ted.

* Do not include issue numbers in the PR title
* Include screenshots and animated GIFs in your pull request whenever possible.
* Run `elm-format` on your code before submitting, ideally have it run every save.
* Include a `{- Comment block detailing the function -}` above every new function.
* If it compiles but with warnings, get rid of them first, please.
* If it doesn't compile, we don't want it.

## Git Commit Messages Style

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable emoji:
    * :art: `:art:` when improving the format/structure of the code
    * :racehorse: `:racehorse:` when improving performance
    * :memo: `:memo:` when improving documentation
    * :penguin: `:penguin:` when fixing something on Gnu/Linux
    * :apple: `:apple:` when fixing something on macOS
    * :checkered_flag: `:checkered_flag:` when fixing something on Windows
    * :bug: `:bug:` when fixing a bug
    * :fire: `:fire:` when removing code or files
    * :white_check_mark: `:white_check_mark:` when adding tests
    * :lock: `:lock:` when dealing with security
    * :arrow_up: `:arrow_up:` when upgrading dependencies
    * :arrow_down: `:arrow_down:` when downgrading dependencies
    * :shirt: `:shirt:` when removing linter warnings

## Naming conventions

### Imports
* Import everything such that it would provide the shortest qualifiers, unless it completely conflicts with another module.
    * For example: `import Html.Styled.Attributes exposing (..)` and `import Html.Styled.Attributes exposing (..)`
        * This causes the ambiguity with the `checked` function, so the compiler will force you to qualify it as
            * `Css.checked` or
            * `Html.Styled.Attributes.checked`.
        * This is perfectly fine. Just pick the correct prefix and add it.
        * Most other functions do not conflict.
    * Counterexample: `import Json.Decode exposing (..)` and `import Json.Encode exposing (..)`
        * These modules have lots of functions of the same name.
        * Using most functions, such as `string`, would cause ambiguity errors
            * The compiler would force us to write either `Json.Encode.string` or `Json.Decode.string`
            * That's a lot of long qualifiers
        * Solution: `import Json.Decode as Decode exposing (..)` and `import Json.Encode as Encode exposing (..)`
            * Bam. Now we only ever need to type as much as `Decode.string` or `Encode.string`
