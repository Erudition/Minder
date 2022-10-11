# UNTETHERED
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




* coming soon



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
