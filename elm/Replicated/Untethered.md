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
            |> writableField ( 2, "activity" ) .activity (Codec.maybe ID.codec) Nothing
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
