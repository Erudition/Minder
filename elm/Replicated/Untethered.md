# UNTETHERED/REPLICATOR

Replicator is a library for building Elm apps with CRDTs ("reptypes")

- Build offline-first apps with Elm and cutting-edge CRDTs
- Eschew the cloud-dependent paradigm
- Synchronize instances anytime, even without internet
- Provide collaborative functionality* resilient to network outages
- Get access to a complete timeline of your user's changes
- Integrate infinite Undo functionality from the get-go -- for free
- Stop writing separate encoder, decoder, and init functions for each type
- Never worry about encoders and decoders being out of sync
- Have backwards-compatible serialization, all the way back to version 0
- Export a snapshot of your entire app, or specific chunks*, into JSON
- Save your app's data in a compact binary format for scalability*

* coming soon



## Records are read-only
After months getting wrapper-free Registers ("naked records") to work in the same way as the more flexible `Register` form, it has come time to accept that it simply cannot be done.

I spent a lot of time and came up with clever hacks to get them to work just like the Registers (records that are wrapped in a special Register type) because I REALLY wanted to maintain the convenience of not having a wrapper over every single record ever - so elm builders will feel right at home with at least *most* of their usual record types...

And, 90% of all possible cases are working! Getting, setting, encoding, decoding, nesting, initializing all work!

But thanks to testing I uncovered the remaining 10% (or whatever) of use cases that are possible only with the wrapper: *nested* initializing.

Long story short, since records have no wrapper (hence "naked"), there's nowhere to stuff their initial changes. Aka Changes you want to specify before you even initialize the object (saving to the node, giving it an ID).  In all other RepTypes, we have them tucked into the wrapper, to be applied right after initialization. Keeping them all self-contained like this was the big eureka a few months back, the refactor required to get them working inside Custom Type wrappers (like `Either record1 record2`). But with naked records having nowhere to tuck extra metadata (short of requiring people to add an extraneous field), initial changes don't work. The test keeps failing and I can't fix it.

That's fine if you never try it, but right now users can be lead into initializing a nested naked record (say, inside a list) with some upfront changes, and those changes disappear (the record gets initialized with defaults). I don't want to have to warn people not to try that, or even to have "gotchas" like that in the first place. Yet I can't come up with an alternative, short of adding yet another type variable to the `Codec` (a phantom type that's only there to block you from initializing naked records specifically). And I've wasted weeks now ruminating on the issue, blocking work on the things that matter.

So I have to stop putting off the inevitable and make a compromise. Records simply must be wrapped to be used as intended.

But! I realized I don't have to give naked records up entirely! Hooray! The smallest restriction I can make that keeps all behavior valid is to make them **read-only**. Alas, that means no `RW` fields allowed. If you want to make Changes to a record, you gotta switch over to a Reg record.

On the bright side, this also simplifies the infrastructure, performance, and cleans up all the hacks. And again, this compromise means I'm not actually giving up naked records entirely, like I feared I had to. Now they can stick around for records that will never change, or for en/decoding from flat JSON, etc. And their nested reptypes can still be changed as usual! All that matters is that we should be unable to call `Codec.initWithChanges` on them.

Another perk is that the two will be forwards- and backwards-compatible on the wire! If you wanna change a read-only record to be writable, just wrap it! If you have a writable Register that you never need to write to again, feel free to just change to a naked record Codec, and it will *just work*.

## Update: Naked records can't have initial changes
In the previous section I decided to make naked records "read-only" in order to prevent them from being changeable in a changer function (record -> List Change). But it turns out banning `RW` fields is not enough, as any of the nested objects can still be changed, meaning you can still go from a naked record to a Change by changing e.g. one of the replists in its fields. This was supposed to be a good thing, making them still useful with the only limitation being no `RW`s. But the nested Changes still have nowhere to go, and are lost upon initializing. This is silly, since the nested objects themselves *do* have the ability to hold their own pre-changes - the simply need to be initialized on their own.

Making the naked record Codec be a "flat"/symmetrical codec would mean you can only initialize it with a full copy of the codec itself. This would solve the immediate problem, since you'd be forced to do Codec.init (now called `Codec.new`) on the nested objects in order to specify a full record. It's inconvenient though, defeating the purpose of the library's built-in initializers feature. It also stops parent records from initializing them silently without a seed, which is a case where there are no issues as there are no upfront changes (and the more common case). Ideally the change would only affect the explicit initialization of the Codec, and when nested it can continue with defaults as normal.

So it's not actually necessary that naked records be read-only - it's only necessary that they cannot be initialized with changes (or at least those changes must be stored elsewhere). Meaning `RW` fields can come back to naked Registers! Cool!

But we need a way to let parent Registers still initialize their naked-codec fields without a seed - yet always requiring a seed from the end user (the seed being a full literal of the record).


## Contexts
Are Contexts really necessary? turns out they can't fully identify their children uniquely without assuming the user only uses each once - which we can't enforce, and sometimes is the only option without awkwardly adding unique numbers or strings just for differentiating new objects (or contexts). Meanwhile the encoder pass doesn't have this problem, can uniquely identify everything. The only reason pre-encoded objects need valid unique pointers is so they can be referenced elsewhere (workaround?) and for sub changes.

Workarounds for external references:
- have a `Codec.newUnique` for objects that need to be referenced elsewhere, taking a user-supplied string they will need to make sure is unique among all changes in the current frame - use this as the pointer, and newUnique returns an ID that can be used then

Workarounds for newWithChanges producing global changes with the pre-encoded pointer (not unique) instead of the encoder-designated pointer
- manually recurse among subchanges, swapping old pointers with the new one. Difficult with pointers/changes possibly nested in various deep places.

Benefits of Contexts
- means that the output of Codec.new cannot be used just anywhere, which would allow changes to be made (to a potentially ill-specified object) in arbitrary places, instead we force that all changes must be in the newWithChanges list. Do we need this? not unless there's a benefit

-IDEA: add type variable to Context. Can't force it to be used only once, but can make sure it's used on the type the parent expects (child type). Most importantly, in a custom type, it must first pass through the custom type codec. TODO test passing through custom type codec. TODO what ways can a context still be reused.
-IDEA: Node encode custom types as flat enumerations with records - each piece of the variant is a reg field. merging is done already, 

## Change library design goals
- allow object creation and changes only for objects that will be attached to the tree somewhere
- disallow cycles by default, but model can form any DAG


# Changes to objects while they're still placeholders
Ideally we would allow all changes to all objects regardless of save state, but that requires the objects to already be ready to go, as far as making generic changes to them anywhere - it requires them to have a fully unique pointer. 
Since it seems that having a fully unique pointer is hard to guarantee, perhaps impossible in some places (nested in custom types) without threading Contexts everywhere, we could also just try to restrict Change making on all placeholder objects in general.
Then we allow a limited subset of changes to the placeholder objects, that make sense and don't require Changes, like starting a RepList with a plain list of seed values.

- what if we relied on encoders for all pointers, but still required contexts for all init (must attach somewhere), but eliminated early change lists so there's nowhere to misplace external-object changes?


# Updating the replica when ops/changes come in
Decoding the whole model upon startup is inevitable, but at time of writing we also decode the whole model over again every time changes are made anywhere. When the model has 1000+ ops (tested with ~200 tasks and such) this causes the UI to hang for half a second or more! Elm is immutable so it will recreate every object in the model unless we specifically hand it the old ones and tell it what to change.

But how to change it surgically? Possible ideas:
1. Require every Codec to have both a getter and a setter (wrapped in parent setters) that operates on the whole model and changes only the specific object - then bundle this in the Change and update the model with these setters on every change (never decode again)
    - Really complicates Codecs to have to specify `\oldObject newValue -> {oldObject | changedField = newValue}` in every field of every Codec... 
    - worse, they will need yet another type variable for their parent, so the decoder can accept the parent's accessor function...
    - Also the Node, or what ever holds the Object dict, now needs a type variable for the userModel since the objects hold functions that act on it.
    - Still doesn't handle Ops coming in from outside systems, fall back to decoding whole model again? That would suck for collaborative editing, at a minimum
2. Object "subscriptions": Same setters as the first idea, but store them in the node objects. When Ops come in for a particular object, run those setters on the model to surgically update the appropriate values.
    - same downsides regarding everyone having to specify a setter
    - works with naked registers, since the subscription is generated once at decode time
3. When decoding the model, allow passing in the existing object, the decoder will reference-equality check the node object it's built from, and if it's the same (no new ops) it returns the original item instead of running the decoder.
    - if object didn't change, but contains children which did, how do we tell the children to check themselves? Then how do we update the object with only the changed children?
    - naked registers must be removed (else we re-decode them every time) because they can't remember their own objectIDs
4. Each Codec gets a function which takes in the new ops/objects, and personally checks if it's affected by them.
    - allows us to in-place update the objects with only the new ops, not redecoding e.g. a whole huge list just to add one item
    - Running the check is cheaper than re-decoding, but we still need to do it for every thing on every branch of the model
    - somehow we need to run this function inside every RepType in a list
5. Redesign all reptypes to be a function of the node, and pass the node around the whole app at all times
    - requiring node everywhere is ewwww
    - does allow intuitive use of Html.lazy
    - makes back-in-time functionality trivial

## Conclusion
Despite requiring setters everywhere, option 2 seems to be the only one that works with any nested object, doesn't require changing the usage interface, and gives maximum performance benefits. 
Implementation plan:
    - give all Codecs an Accessor from bChiquet/elm-accessors
        - record codecs can just have this in place of the already-required getter, but defining Codecs will get a lot bulkier
        - use a 1:1 Accessor for each item in a collection
    - make all nodeDecoders return a `List ObjectEventSubscription` as well as their normal value. All nodeDecoders will now need to collect their children's subscriptions and include them in their own return list.
    - an ObjectEventSubscription is a function from model to model, but needs a Node input (in case new children need it for their decoders) and also includes a ObjectEventSubscription list in the output (new children may have their own subscriptions)


# Before
```
type alias ActionClassSkel =
    { title : String -- ActionClass
    , id : ActionClassID -- ActionClass and Instance
    , activity : Maybe ActivityID

    --, template : TaskTemplate
    , completionUnits : Progress.Unit
    , minEffort : Duration -- Class. can always revise
    , predictedEffort : Duration -- Class. can always revise
    , maxEffort : Duration -- Class. can always revise

    --, tags : List TagId -- ActionClass
    , defaultExternalDeadline : List RelativeTiming
    , defaultStartBy : List RelativeTiming --  THESE ARE NORMALLY SPECIFIED AT THE INSTANCE LEVEL
    , defaultFinishBy : List RelativeTiming
    , defaultRelevanceStarts : List RelativeTiming
    , defaultRelevanceEnds : List RelativeTiming
    , importance : Float -- ActionClass
    , extra : Dict String String

    -- future: default Session strategy
    }


decodeActionClassSkel : Decode.Decoder ActionClassSkel
decodeActionClassSkel =
    decode ActionClassSkel
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "id" decodeActionClassID
        |> Pipeline.required "activity" (Decode.nullable <| ID.decode)
        |> Pipeline.required "completionUnits" Progress.decodeUnit
        |> Pipeline.required "minEffort" decodeDuration
        |> Pipeline.required "predictedEffort" decodeDuration
        |> Pipeline.required "maxEffort" decodeDuration
        |> Pipeline.required "defaultExternalDeadline" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "defaultStartBy" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "defaultFinishBy" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "defaultRelevanceStarts" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "defaultRelevanceEnds" (Decode.list decodeRelativeTiming)
        |> Pipeline.required "importance" Decode.float
        |> Pipeline.optional "extra" (Decode.dict Decode.string) Dict.empty


encodeActionClassSkell : ActionClassSkel -> Encode.Value
encodeActionClassSkell taskClass =
    object <|
        [ ( "title", Encode.string taskClass.title )
        , ( "id", Encode.int taskClass.id )
        , ( "activity", Encode2.maybe ID.encode taskClass.activity )
        , ( "completionUnits", Progress.encodeUnit taskClass.completionUnits )
        , ( "minEffort", encodeDuration taskClass.minEffort )
        , ( "predictedEffort", encodeDuration taskClass.predictedEffort )
        , ( "maxEffort", encodeDuration taskClass.maxEffort )
        , ( "defaultExternalDeadline", Encode.list encodeRelativeTiming taskClass.defaultExternalDeadline )
        , ( "defaultStartBy", Encode.list encodeRelativeTiming taskClass.defaultStartBy )
        , ( "defaultFinishBy", Encode.list encodeRelativeTiming taskClass.defaultFinishBy )
        , ( "defaultRelevanceStarts", Encode.list encodeRelativeTiming taskClass.defaultRelevanceStarts )
        , ( "defaultRelevanceEnds", Encode.list encodeRelativeTiming taskClass.defaultRelevanceEnds )
        , ( "importance", Encode.float taskClass.importance )
        , ( "extra", Encode.dict identity Encode.string taskClass.extra )
        ]


newActionClassSkel : String -> Int -> ActionClassSkel
newActionClassSkel givenTitle newID =
    { title = givenTitle
    , id = newID
    , activity = Nothing
    , completionUnits = Progress.Percent
    , minEffort = Duration.zero
    , predictedEffort = Duration.zero
    , maxEffort = Duration.zero
    , defaultExternalDeadline = []
    , defaultStartBy = []
    , defaultFinishBy = []
    , defaultRelevanceStarts = []
    , defaultRelevanceEnds = []
    , importance = 1
    , extra = Dict.empty
    }
```

# After
```
type alias ActionClassSkel =
    { title : RW String -- ActionClass
    , activity : RW (Maybe ActivityID)
    , completionUnits : RW Progress.Unit
    , minEffort : RW Duration -- Class. can always revise
    , predictedEffort : RW Duration -- Class. can always revise
    , maxEffort : RW Duration -- Class. can always revise
    , defaultExternalDeadline : RepList RelativeTiming
    , defaultStartBy : RepList RelativeTiming
    , defaultFinishBy : RepList RelativeTiming
    , defaultRelevanceStarts : RepList RelativeTiming
    , defaultRelevanceEnds : RepList RelativeTiming
    , importance : RW Float -- ActionClass
    , extra : RepDict String String
    }

    actionClassSkelCodec : Codec String ActionClassSkel
    actionClassSkelCodec =
        Codec.record ActionClassSkel
            |> essentialWritable ( 1, "title" ) .title Codec.string
            |> writableField ( 2, "activity" ) .activity (Codec.maybe Codec.id) Nothing
            |> writableField ( 3, "completionUnits" ) .completionUnits Progress.unitCodec Progress.Percent
            |> writableField ( 4, "minEffort" ) .minEffort Codec.duration Duration.zero
            |> writableField ( 5, "predictedEffort" ) .predictedEffort Codec.duration Duration.zero
            |> writableField ( 6, "maxEffort" ) .maxEffort Codec.duration Duration.zero
            |> listField ( 7, "defaultExternalDeadline" ) .defaultExternalDeadline relativeTimingCodec
            |> listField ( 8, "defaultStartBy" ) .defaultStartBy relativeTimingCodec
            |> listField ( 9, "defaultFinishBy" ) .defaultFinishBy relativeTimingCodec
            |> listField ( 10, "defaultRelevanceStarts" ) .defaultRelevanceStarts relativeTimingCodec
            |> listField ( 11, "defaultRelevanceEnds" ) .defaultRelevanceEnds relativeTimingCodec
            |> writableField ( 12, "importance" ) .importance Codec.float 1
            |> dictField ( 13, "extra" ) .extra ( Codec.string, Codec.string )
            |> Codec.finishRecord  
```
