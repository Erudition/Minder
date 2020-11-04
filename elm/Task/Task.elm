module Task.Task exposing (Change(..), Class, ClassID, Entry, FullClass, FullInstance, FullSession, Instance, InstanceID, buildFullInstanceDict, completed, decodeChange, decodeClass, decodeEntry, decodeInstance, encodeChange, encodeClass, encodeInstance, getFullSessions, instanceProgress, makeFullClass, makeFullInstance, newClass, newInstance, normalizeTitle, prioritize)

--import Json.Decode as Decode exposing (..)

import Activity.Activity exposing (ActivityID)
import ID
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Extra as List
import List.Nonempty exposing (Nonempty, map)
import Maybe.Extra
import Porting exposing (..)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Clock as Clock
import SmartTime.Human.Duration exposing (HumanDuration(..))
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import SmartTime.Moment as Moment exposing (..)
import Task.Progress as Progress exposing (..)


{-| A TaskClass is an exact specific task, in general, without a time. If you took a shower yesterday, and you take a shower tomorrow, those are two separate TaskInstances - but they are instances of the same TaskClass ("take a shower").
This way, the same task can be assigned multiple times in life (either automatic recurrence, or by manually adding a new instance) and the program is aware they are the same thing.

Tasks that are only similar, e.g. "take a bath", should be separate TaskClasses.

-}
type alias Class =
    { title : String -- Class
    , id : ClassID -- Class and Instance
    , activity : Maybe ActivityID

    --, template : TaskTemplate
    , completionUnits : Progress.Unit
    , minEffort : Duration -- Class. can always revise
    , predictedEffort : Duration -- Class. can always revise
    , maxEffort : Duration -- Class. can always revise

    --, tags : List TagId -- Class
    , defaultExternalDeadline : List RelativeTiming
    , defaultStartBy : List RelativeTiming --  THESE ARE NORMALLY SPECIFIED AT THE INSTANCE LEVEL
    , defaultFinishBy : List RelativeTiming
    , defaultRelevanceStarts : List RelativeTiming
    , defaultRelevanceEnds : List RelativeTiming
    , importance : Float -- Class

    -- future: default Session strategy
    }


decodeClass : Decode.Decoder Class
decodeClass =
    decode Class
        |> Pipeline.required "title" Decode.string
        |> Pipeline.required "id" decodeClassID
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


encodeClass : Class -> Encode.Value
encodeClass taskClass =
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
        ]


newClass : String -> Int -> Class
newClass givenTitle newID =
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
    }


{-| Definition of a single task.
Working rules:

  - there should be no fields for storing data that can be fully derived from other fields [consistency]
  - combine related fields into a single one with a tuple value [minimalism]

-- One particular time that the specific thing will be done, that can be scheduled
-- A class could have NO instances yet - they're calculated on the fly

-}
type alias Instance =
    { class : ClassID
    , id : InstanceID
    , completion : Progress.Portion
    , externalDeadline : Maybe FuzzyMoment -- *
    , startBy : Maybe FuzzyMoment -- *
    , finishBy : Maybe FuzzyMoment -- *
    , plannedSessions : List Session
    , relevanceStarts : Maybe FuzzyMoment -- *
    , relevanceEnds : Maybe FuzzyMoment -- * (*)=An absolute FuzzyMoment if specified, otherwise generated by relative rules from class
    }


decodeInstance : Decode.Decoder Instance
decodeInstance =
    decode Instance
        |> Pipeline.required "class" decodeClassID
        |> Pipeline.required "id" decodeInstanceID
        |> Pipeline.required "completion" Decode.int
        |> Pipeline.required "externalDeadline" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "startBy" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "finishBy" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "plannedSessions" (Decode.list decodeSession)
        |> Pipeline.required "relevanceStarts" (Decode.nullable decodeTaskMoment)
        |> Pipeline.required "relevanceEnds" (Decode.nullable decodeTaskMoment)


encodeInstance : Instance -> Encode.Value
encodeInstance taskInstance =
    Encode.object <|
        [ ( "class", Encode.int taskInstance.class )
        , ( "id", Encode.int taskInstance.id )
        , ( "completion", Encode.int taskInstance.completion )
        , ( "externalDeadline", Encode2.maybe encodeTaskMoment taskInstance.externalDeadline )
        , ( "startBy", Encode2.maybe encodeTaskMoment taskInstance.startBy )
        , ( "finishBy", Encode2.maybe encodeTaskMoment taskInstance.finishBy )
        , ( "plannedSessions", Encode.list encodeSession taskInstance.plannedSessions )
        , ( "relevanceStarts", Encode2.maybe encodeTaskMoment taskInstance.relevanceStarts )
        , ( "relevanceEnds", Encode2.maybe encodeTaskMoment taskInstance.relevanceEnds )
        ]


newInstance : Int -> Class -> Instance
newInstance newID class =
    { class = class.id
    , id = newID
    , completion = 0
    , externalDeadline = Nothing
    , startBy = Nothing
    , finishBy = Nothing
    , plannedSessions = []
    , relevanceStarts = Nothing
    , relevanceEnds = Nothing
    }


decodeTaskMoment : Decoder FuzzyMoment
decodeTaskMoment =
    customDecoder Decode.string HumanMoment.fuzzyFromString


{-| TODO make encoder
-}
encodeTaskMoment : FuzzyMoment -> Encode.Value
encodeTaskMoment fuzzy =
    Encode.string <| HumanMoment.fuzzyToString fuzzy


type alias TagId =
    Int


{-| One time chunk during which a task is scheduled. Most tasks are done in one session, but this allows for breaking up longer tasks into sessions and scheduling those individually.

(when it starts, how long it lasts)

-}
type alias Session =
    ( FuzzyMoment, Duration )


decodeSession : Decoder Session
decodeSession =
    let
        decodeFuzzyMoment =
            Porting.customDecoder Decode.string HumanMoment.fuzzyFromString
    in
    Porting.arrayAsTuple2 decodeFuzzyMoment decodeDuration


encodeSession : Session -> Encode.Value
encodeSession plannedSession =
    Debug.todo "encode plannedSessions"


{-| possible activities that can be logged about a task.
Working rules:

  - names should just be '(exact name of field being changed)+Change' [consistency]
  - value always includes the full value it was changed to at the time, never the delta [consistency]

-}
type Change
    = Created Moment
    | CompletionChange Progress
    | TitleChange String
    | PredictedEffortChange Duration
    | ParentChange ClassID
    | TagsChange
    | DateChange (Maybe FuzzyMoment)


decodeChange : Decode.Decoder Change
decodeChange =
    decodeCustom
        [ ( "CompletionChange", subtype CompletionChange "progress" decodeProgress )
        , ( "Created", subtype Created "moment" decodeMoment )
        , ( "ParentChange", subtype ParentChange "taskId" Decode.int )
        , ( "PredictedEffortChange", subtype PredictedEffortChange "duration" decodeDuration )
        , ( "TagsChange", succeed TagsChange )
        , ( "TitleChange", subtype TitleChange "string" Decode.string )
        ]


encodeChange : Change -> Encode.Value
encodeChange theTaskChange =
    case theTaskChange of
        Created moment ->
            Encode.object [ ( "Created", encodeMoment moment ) ]

        CompletionChange progress ->
            Encode.object [ ( "CompletionChange", encodeProgress progress ) ]

        TitleChange string ->
            Encode.object [ ( "TitleChange", Encode.string string ) ]

        PredictedEffortChange duration ->
            Encode.object [ ( "PredictedEffortChange", encodeDuration duration ) ]

        ParentChange taskId ->
            Encode.object [ ( "ParentChange", Encode.int taskId ) ]

        TagsChange ->
            Encode.string "TagsChange"

        DateChange taskMoment ->
            Encode.object [ ( "DateChange", Encode2.maybe encodeTaskMoment taskMoment ) ]


type alias ClassID =
    Int


decodeClassID : Decoder ClassID
decodeClassID =
    Decode.int


encodeClassID : ClassID -> Encode.Value
encodeClassID taskClassID =
    Encode.int taskClassID


type alias InstanceID =
    Int


decodeInstanceID : Decoder InstanceID
decodeInstanceID =
    Decode.int


encodeInstanceID : InstanceID -> Encode.Value
encodeInstanceID taskInstanceID =
    Encode.int taskInstanceID


{-| Need to be able to specify multiple of these, as some may not apply.
-}
type RelativeTiming
    = FromDeadline Duration
    | FromToday Duration


decodeRelativeTiming : Decoder RelativeTiming
decodeRelativeTiming =
    Decode.map FromDeadline decodeDuration


encodeRelativeTiming : RelativeTiming -> Encode.Value
encodeRelativeTiming relativeTaskTiming =
    case relativeTaskTiming of
        FromDeadline duration ->
            encodeDuration duration

        FromToday duration ->
            encodeDuration duration



-- TASK HELPER FUNCTIONS


completed : FullInstance -> Bool
completed spec =
    isMax ( spec.instance.completion, spec.class.completionUnits )


type alias WithSoonness t =
    { t | soonness : Duration }


prioritize : Moment -> HumanMoment.Zone -> List FullInstance -> List FullInstance
prioritize now zone taskList =
    let
        -- lowest values first
        compareProp prop a b =
            Basics.compare (prop a) (prop b)

        -- highest values first
        comparePropInverted prop a b =
            Basics.compare (prop b) (prop a)
    in
    -- deepSort [ compareSoonness zone, comparePropInverted .importance ] taskList
    deepSort [ compareSoonness zone ] taskList


normalizeTitle : String -> String
normalizeTitle newTaskTitle =
    -- TODO capitalize, and other such normalization
    String.trim newTaskTitle



-- List.sortWith (compareSoonness zone) <| List.sortBy .importance taskList


type alias CompareFunction a =
    a -> a -> Basics.Order


deepSort : List (CompareFunction a) -> List a -> List a
deepSort compareFuncs listToSort =
    let
        deepCompare funcs a b =
            case funcs of
                [] ->
                    -- No more comparisons to make, give up and say they're equal
                    EQ

                nextCompareFunc :: laterCompareFuncs ->
                    let
                        -- run next comparison
                        check =
                            nextCompareFunc a b
                    in
                    if check == EQ then
                        -- they still look equal, dig deeper
                        deepCompare laterCompareFuncs a b

                    else
                        -- we have a winner, we can stop digging
                        check
    in
    List.sortWith (deepCompare compareFuncs) listToSort


{-| TODO this could be a Moment.Fuzzy function
-}
compareSoonness : HumanMoment.Zone -> CompareFunction FullInstance
compareSoonness zone taskA taskB =
    case ( taskA.instance.externalDeadline, taskB.instance.externalDeadline ) of
        ( Just fuzzyMomentA, Just fuzzyMomentB ) ->
            HumanMoment.compareFuzzyLateness zone Clock.endOfDay fuzzyMomentA fuzzyMomentB

        ( Nothing, Nothing ) ->
            -- whenevers can't be compared
            EQ

        ( Just _, Nothing ) ->
            -- actual times always come before whenevers
            LT

        ( Nothing, Just _ ) ->
            -- whenevers always come after actual times
            GT


getRelevantInstancesOfClass : FuzzyMoment -> FuzzyMoment -> IntDict Class -> IntDict Instance -> List ( Class, Instance )
getRelevantInstancesOfClass fromWhen toWhen classes instances =
    let
        getInstances givenClass =
            -- find all matching instances - instances of the same class
            IntDict.filterValues (\ins -> ins.class == givenClass.id) instances

        pairThem class =
            List.map (Tuple.pair class) (IntDict.values (getInstances class))
    in
    List.concatMap pairThem (IntDict.values classes)


{-| A top-level entry in the task list. It could be a single atomic task, or it could be a composite task (group of tasks), which may contain further nested groups of tasks ad infinitum.
-}
type Entry
    = SingletonTask Class
    | OneoffContainer ConstrainedParent
    | RecurrenceContainer RecurringParent
    | NestedRecurrenceContainer UnconstrainedParent


decodeEntry : Decoder Entry
decodeEntry =
    let
        get id =
            case id of
                "SingletonTask" ->
                    Debug.todo "Cannot decode variant with params: SingletonTask"

                "OneoffContainer" ->
                    Debug.todo "Cannot decode variant with params: OneoffContainer"

                "RecurrenceContainer" ->
                    Debug.todo "Cannot decode variant with params: RecurrenceContainer"

                "NestedRecurrenceContainer" ->
                    Debug.todo "Cannot decode variant with params: NestedRecurrenceContainer"

                _ ->
                    fail ("unknown value for Entry: " ++ id)
    in
    Decode.string |> Decode.andThen get



-- ...etc
{- type alias TaskTemplate =
   { title : String
   , completion : Progress
   , id : TaskTemplateID
   , minEffort : Duration
   , predictedEffort : Duration
   , maxEffort : Duration
   , tags : List TagId
   , activity : Maybe ActivityID -- Class
   , deadline : Maybe FuzzyMoment -- Class
   , plannedStart : Maybe FuzzyMoment -- PlannedSession
   , plannedFinish : Maybe FuzzyMoment -- PlannedSession
   , relevanceStarts : Maybe FuzzyMoment -- Class, but relative? & Instance, absolute
   , relevanceEnds : Maybe FuzzyMoment -- Class, but relative? & Instance, absolute
   , importance : Float -- Class
   }
-}


type alias ParentProperties =
    { title : Maybe String -- Can have no title if it's just a singleton task
    }


type RecurrenceRule
    = CalendarRepeat Int --TODO


{-| A "Parent" task is actually a container of subtasks. A RecurringParent contains tasks (or a single task!) that repeat, all at the same time and by the same pattern. Since it doesn't make sense for individual tasks to recur in a different way from their siblings, all recurrence behavior of tasks comes from this type of parent.

Parents that contain only a single task are transparently unwrapped to appear like single tasks - in this case, with recurrence applied. Since it doesn't make sense for a bundle of tasks that recur on some schedule to contain other bundles of tasks with their own schedule and instances, all children of RecurringParents are considered "Constrained" and cannot contain recurrence information. This ensures that only one ancestor of a task dictates its recurrence pattern.

-}
type alias RecurringParent =
    { properties : ParentProperties
    , recurrenceRules : List RecurrenceRule
    , children : Nonempty ConstrainedParent
    }


{-| An "Unconstrained" group of tasks has no recurrence rules, but one or more of its children may be containers that do (RecurringParents). UnconstrainedParents may contain infinitely nested UnconstrainedParents, until the level at which a RecurringParent appears.
-}
type alias UnconstrainedParent =
    { properties : ParentProperties
    , children : Nonempty UnconstrainedChild
    }


type UnconstrainedChild
    = RecursDeeper UnconstrainedParent
    | RecursHere RecurringParent


{-| A "constrained" group of tasks has already had its recurrence rules set by one of it's ancestors, or does not recur at all. Since a task can only be in one RecurrenceParent container, its children (ConstrainedParents) can not have recurrence rules of its own (nor can any of its descendants).

Like all parents, a ConstrainedParent can contain infinitely nested ConstrainedParents.

-}
type alias ConstrainedParent =
    { properties : ParentProperties
    , children : Nonempty ConstrainedChild
    }



{- every task must be wrapped in a parent, even if it's alone
   parents have instances, not tasks
   ...but then how to track the completion of the subtasks?
   by storing the subtask instances in a separate Dict, each tagged with the parent's instance ID.
    A failed lookup just means an incomplete task, defaults used for everything

   How can we let parents have parents?
   Well, we still only want one set of instances/recurrence in a given tree, so let's make "subparents" that still function as containers but have no recurrence rules or instances. Then any parent can contain either a subtask, or a subparent.

   ...Yeah, but the problem with that, is what if you want recurrence to happen at the level of one of the subparents? Say you have a project that is one-time but one of the sub-projects is supposed to repeat.

-}


type ConstrainedChild
    = Singleton Class
    | Nested ConstrainedParent


{-| A fully spec'ed-out version of a TaskClass
-}
type alias FullClass =
    { parents : List ParentProperties
    , class : Class
    }


makeFullClass : List ParentProperties -> Class -> FullClass
makeFullClass parentList class =
    { parents = parentList
    , class = class
    }


makeFullInstance : FullClass -> Instance -> FullInstance
makeFullInstance inheritedClass justInstance =
    { parents = inheritedClass.parents
    , class = inheritedClass.class
    , instance = justInstance
    }


getEntries : List Entry -> List FullClass
getEntries entries =
    let
        traverseRoot entry =
            case entry of
                SingletonTask taskClass ->
                    [ makeFullClass [] taskClass ]

                OneoffContainer constrainedParent ->
                    traverseConstrainedParent (appendPropsIfMeaningful [] constrainedParent.properties) constrainedParent

                RecurrenceContainer recurringParent ->
                    traverseRecurringParent (appendPropsIfMeaningful [] recurringParent.properties) recurringParent

                NestedRecurrenceContainer unconstrainedParent ->
                    traverseUnconstrainedParent (appendPropsIfMeaningful [] unconstrainedParent.properties) unconstrainedParent

        -- flatten the hierarchy if a container serves no purpose
        appendPropsIfMeaningful oldList newParentProps =
            if newParentProps.title /= Nothing then
                newParentProps :: oldList

            else
                oldList

        traverseConstrainedParent accumulator constrainedParent =
            -- TODO do we need to collect props here
            List.concatMap (traverseConstrainedChild accumulator) (List.Nonempty.toList constrainedParent.children)

        traverseUnconstrainedParent accumulator unconstrainedParent =
            List.concatMap (traverseUnconstrainedChild accumulator) (List.Nonempty.toList unconstrainedParent.children)

        traverseRecurringParent accumulator recurringParent =
            List.concatMap (traverseConstrainedParent accumulator) (List.Nonempty.toList recurringParent.children)

        traverseConstrainedChild accumulator child =
            case child of
                Singleton taskClass ->
                    [ makeFullClass accumulator taskClass ]

                Nested constrainedParent ->
                    traverseConstrainedParent (appendPropsIfMeaningful accumulator constrainedParent.properties) constrainedParent

        traverseUnconstrainedChild accumulator child =
            case child of
                RecursDeeper unconstrainedParent ->
                    traverseUnconstrainedParent (appendPropsIfMeaningful accumulator unconstrainedParent.properties) unconstrainedParent

                RecursHere recurringParent ->
                    traverseRecurringParent (appendPropsIfMeaningful accumulator recurringParent.properties) recurringParent
    in
    List.concatMap traverseRoot entries


{-| A fully spec'ed-out version of a TaskInstance
-}
type alias FullInstance =
    { parents : List ParentProperties
    , class : Class
    , instance : Instance
    }


{-| A fully spec'ed-out version of a PlannedSession
-}
type alias FullSession =
    { parents : List ParentProperties
    , class : Class
    , instance : Instance
    , session : Session
    }


makeFullSession : FullInstance -> Session -> FullSession
makeFullSession inherited justSession =
    { parents = inherited.parents
    , class = inherited.class
    , instance = inherited.instance
    , session = justSession
    }


{-| Get planned sessions for a FullInstance and build a FullSession list.
-}
getFullSessions : FullInstance -> List FullSession
getFullSessions fullInstance =
    let
        ins =
            fullInstance.instance

        providedSessions =
            ins.plannedSessions

        generatedSessions =
            let
                sessionStart =
                    Maybe.Extra.or ins.finishBy ins.externalDeadline

                taskDuration =
                    fullInstance.class.maxEffort
            in
            case sessionStart of
                Just foundStart ->
                    [ ( foundStart, taskDuration ) ]

                Nothing ->
                    Debug.log "No sessionStart found" []

        attachSession =
            makeFullSession fullInstance
    in
    List.map attachSession providedSessions
        ++ List.map attachSession generatedSessions


{-| Convenience function for getting fully specced class list from appData lists.
-}
buildFullClassDict : ( List Entry, IntDict.IntDict Class ) -> IntDict.IntDict FullClass
buildFullClassDict ( entries, classes ) =
    -- TODO actually look in the entry list
    IntDict.mapValues (makeFullClass []) classes


{-| Convenience function for getting fully specced instance list from appData lists.
-}
buildFullInstanceDict : ( List Entry, IntDict.IntDict Class, IntDict.IntDict Instance ) -> IntDict.IntDict FullInstance
buildFullInstanceDict ( entries, classes, instances ) =
    let
        fullClasses =
            buildFullClassDict ( entries, classes )

        findClass taskClassID =
            IntDict.get taskClassID fullClasses

        fleshOutInstanceIfClassFound taskInstance =
            case findClass taskInstance.class of
                Nothing ->
                    Debug.log
                        ("Couldn't find a matching class (ID "
                            ++ String.fromInt taskInstance.class
                            ++ ") for instance ID "
                            ++ String.fromInt taskInstance.id
                        )
                        Nothing

                Just foundClass ->
                    Just <| makeFullInstance foundClass taskInstance
    in
    IntDict.filterMapValues fleshOutInstanceIfClassFound instances


instanceProgress : FullInstance -> Progress
instanceProgress fullInstance =
    ( fullInstance.instance.completion, fullInstance.class.completionUnits )
