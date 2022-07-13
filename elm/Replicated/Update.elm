module Replicated.Update exposing
    ( Update, UpdateF
    , map, map2, map3, map4, map5, andMap, mapWith, mapCmd, mapBoth, dropCmd
    , piper, pipel, zero, piperK, pipelK
    , singleton, andThen, andThenK
    , command, effect_
    , sequence, flatten
    )

{-|


## Type

Modeling the `update` tuple as a Monad similar to `Writer`

@docs Update, UpdateF


## Mapping

@docs map, map2, map3, map4, map5, andMap, mapWith, mapCmd, mapBoth, dropCmd


## Piping

@docs piper, pipel, zero, piperK, pipelK


## Basics

@docs singleton, andThen, andThenK


## Write `Cmd`s

@docs Update, command, effect_


## Fancy non-sense

@docs sequence, flatten

-}

import Replicated.Change as Change exposing (Change)
import Tuple


type alias Environment e =
    { e | time : Bool }


type SuperModel state profile env
    = SuperModel state profile (Environment env)


{-| -}
type alias Update msg model =
    ( model, Cmd msg )


{-| -}
type alias UpdateF msg model =
    Update msg model -> Update msg model


{-| -}
piper : List (UpdateF msg model) -> UpdateF msg model
piper =
    List.foldr (<<) zero


{-| -}
pipel : List (UpdateF msg model) -> UpdateF msg model
pipel =
    List.foldl (>>) zero


{-| -}
zero : UpdateF msg model
zero =
    identity


{-| Transform the `Model`, the `Cmd` will be left untouched
-}
map : (a -> b) -> Update msg a -> Update msg b
map f ( model, cmd ) =
    ( f model, cmd )


{-| Transform the `Model` of and add a new `Cmd` to the queue
-}
mapWith : (a -> b) -> Cmd msg -> Update msg a -> Update msg b
mapWith f cmd ret =
    andMap ret ( f, cmd )


{-| Map an `Update` into a `Update` containing a `Model` function
-}
andMap : Update msg a -> Update msg (a -> b) -> Update msg b
andMap ( model, cmd_ ) ( f, cmd ) =
    ( f model, Cmd.batch [ cmd, cmd_ ] )


{-| Map over both the model and the msg type of the `Update`.
This is useful for easily embedding a `Update` in a Union Type.
For example
import Foo
type Msg = Foo Foo.Msg
type Model = FooModel Foo.Model
...
update : Msg -> Model -> Update Msg Model
update msg model =
case msg of
Foo foo -> Foo.update foo model.foo
|> mapBoth Foo FooModel
-}
mapBoth : (a -> b) -> (c -> d) -> Update a c -> Update b d
mapBoth f f_ ( model, cmd ) =
    ( f_ model, Cmd.map f cmd )


{-| Combine 2 `Update`s with a function
map2
(\\modelA modelB -> { modelA | foo = modelB.foo })
retA
retB
-}
map2 :
    (a -> b -> c)
    -> Update msg a
    -> Update msg b
    -> Update msg c
map2 f ( x, cmda ) ( y, cmdb ) =
    ( f x y, Cmd.batch [ cmda, cmdb ] )


{-| -}
map3 :
    (a -> b -> c -> d)
    -> Update msg a
    -> Update msg b
    -> Update msg c
    -> Update msg d
map3 f ( x, cmda ) ( y, cmdb ) ( z, cmdc ) =
    ( f x y z, Cmd.batch [ cmda, cmdb, cmdc ] )


{-| -}
map4 :
    (a -> b -> c -> d -> e)
    -> Update msg a
    -> Update msg b
    -> Update msg c
    -> Update msg d
    -> Update msg e
map4 f ( w, cmda ) ( x, cmdb ) ( y, cmdc ) ( z, cmdd ) =
    ( f w x y z, Cmd.batch [ cmda, cmdb, cmdc, cmdd ] )


{-| -}
map5 :
    (a -> b -> c -> d -> e -> f)
    -> Update msg a
    -> Update msg b
    -> Update msg c
    -> Update msg d
    -> Update msg e
    -> Update msg f
map5 f ( v, cmda ) ( w, cmdb ) ( x, cmdc ) ( y, cmdd ) ( z, cmde ) =
    ( f v w x y z, Cmd.batch [ cmda, cmdb, cmdc, cmdd, cmde ] )


{-| Create a `Update` from a given `Model`
-}
singleton : model -> Update msg model
singleton a =
    ( a, Cmd.none )


{-|

    foo : Model -> Update Msg Model
    foo ({ bar } as model) =
        -- forking logic
        if
            bar < 10
            -- that side effects may be added
        then
            ( model, getAjaxThing )
            -- that the model may be updated

        else
            ( { model | bar = model.bar - 2 }, Cmd.none )

They are now chainable with `andThen`...
resulting : Update msg { model | bar : Int }
resulting =
myUpdate
|> andThen foo
|> andThen foo
|> andThen foo
Here we changed up `foo` three times, but we can use any function of
type `(a -> Update msg b)`.
Commands will be accumulated automatically as is the case with all
functions in this library.

-}
andThen : (a -> Update msg b) -> Update msg a -> Update msg b
andThen f ( model, cmd ) =
    let
        ( model_, cmd_ ) =
            f model
    in
    ( model_, Cmd.batch [ cmd, cmd_ ] )


{-| Construct a new `Update` from parts
-}
update : model -> Cmd msg -> Update msg model
update a b =
    identity ( a, b )


{-| Add a `Cmd` to a `Update`, the `Model` is uneffected
-}
command : Cmd msg -> UpdateF msg model
command cmd ( model, cmd_ ) =
    ( model, Cmd.batch [ cmd, cmd_ ] )


{-| Add a `Cmd` to a `Update` based on its `Model`, the `Model` will not be effected
-}
effect_ : Respond msg model -> UpdateF msg model
effect_ f ( model, cmd ) =
    ( model, Cmd.batch [ cmd, f model ] )


{-| Map on the `Cmd`.
-}
mapCmd : (a -> b) -> Update a model -> Update b model
mapCmd f ( model, cmd ) =
    ( model, Cmd.map f cmd )


{-| Drop the current `Cmd` and replace with an empty thunk
-}
dropCmd : UpdateF msg model
dropCmd =
    singleton << Tuple.first


{-| -}
sequence : List (Update msg model) -> Update msg (List model)
sequence =
    let
        f ( model, cmd ) ( models, cmds ) =
            ( model :: models, Cmd.batch [ cmd, cmds ] )
    in
    List.foldr f ( [], Cmd.none )


{-| -}
flatten : Update msg (Update msg model) -> Update msg model
flatten =
    andThen identity


{-| Kleisli composition
-}
andThenK : (a -> Update x b) -> (b -> Update x c) -> (a -> Update x c)
andThenK x y a =
    x a |> andThen y


{-| Compose updaters from the left
-}
pipelK : List (a -> Update x a) -> (a -> Update x a)
pipelK =
    List.foldl andThenK singleton


{-| Compose updaters from the right
-}
piperK : List (a -> Update x a) -> (a -> Update x a)
piperK =
    List.foldr andThenK singleton



-- THE FOLLOWING WAS A SEPARATE "RESPOND" MODULE


{-| A function from a model to a Cmd.
Basically there are times where you want to
have a side effect on the world if the model
has a certain shape. `Respond` facilitates
this use case.
-}
type alias Respond msg a =
    a -> Cmd msg


{-| -}
appendRespond : Respond msg a -> Respond msg a -> Respond msg a
appendRespond f g a =
    Cmd.batch [ f a, g a ]


{-| -}
sumRespond : List (Respond msg a) -> Respond msg a
sumRespond rs a =
    List.map (\r -> r a) rs
        |> Cmd.batch


{-| -}
zeroRespond : Respond msg a
zeroRespond =
    always Cmd.none


{-| Add a function to the front
`b -> a >> a -> Cmd msg`
-}
comapRespond : (b -> a) -> Respond msg a -> Respond msg b
comapRespond =
    (>>)
