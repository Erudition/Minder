module SmartTime.Moment exposing (ElmTime, Epoch(..), Moment, TimeScale(..), Zone, compare, difference, fromElmInt, fromElmTime, fromJsTime, fromSmartInt, fromUnixTime, future, here, linearFromUTC, moment, now, past, toElmTime, toInt, toSmartInt, utc, zero)

import SmartTime.Duration as Duration exposing (Duration)
import Task as Job
import Time as ElmTime



-- SHH, throughout this library we secretely we just use a Duration (which unboxes to a simple Int) under the hood, rather than an (Epoch, Duration) pair. But that's just to reduce overhead! We assume the same Epoch everywhere when storing these values, but our API does not need to know this. Oh, and the Moment should then unbox to a pure Int as well - (this is exactly how elm/time does it too, I checked) so it's just as efficient. Otherwise I would have just made Moment a type alias for Posix, which it used to be (for easy compatibility with the ecosystem).


type Moment
    = Moment Duration


{-| Get the `Moment` of the, um, moment... that this task is run.
-}
now : Job.Task x Moment
now =
    Job.map fromElmTime ElmTime.now


type alias Zone =
    ElmTime.Zone


utc : ElmTime.Zone
utc =
    ElmTime.utc


{-| Get the current Time Zone, based on the the UTC offset given to us by Javascript. Provided here so you can ditch your `Time` imports entirely if you want.
-}
here : Job.Task x Zone
here =
    ElmTime.here


type alias ElmTime =
    ElmTime.Posix


{-| Create a Moment. A Moment is an `Epoch` and some `Duration` -- the amount of time since that Epoch -- which gives us a globally fixed point in time. You can shift this moment forward or backward by adding other `Duration` values to it.
-}
moment : TimeScale -> Epoch -> Duration -> Moment
moment scale epoch duration =
    case ( scale, epoch ) of
        ( _, _ ) ->
            --TODO
            Moment (Duration.map linearFromUTC duration)


linearFromUTC : Int -> Int
linearFromUTC int =
    int


utcFromLinear : Int -> Int
utcFromLinear int =
    int


{-| Shift a `Moment` into its future by some amount of time (`Duration`).
Obviously it doesn't make much sense to "add" a `Moment` to another `Moment`, but you often want to add some time to one.

Rather than dealing with negative durations, look to `past` for shifting into the past.

-}
future : Moment -> Duration -> Moment
future (Moment time) duration =
    Moment <| Duration.add time duration


{-| Shift a `Moment` into its past by some amount of time (`Duration`).

This way you don't have to deal with negative durations.

-}
past : Moment -> Duration -> Moment
past (Moment time) duration =
    Moment <| Duration.subtract time duration


{-| Compare a `Moment` to another, the same way you can compare integers.
-}
compare (Moment time1) (Moment time2) =
    Basics.compare (Duration.inMs time1) (Duration.inMs time2)


difference (Moment time1) (Moment time2) =
    Duration.difference time1 time2


{-| As _all_ numbers in Javascript are double precision _floating point_ numbers (following the international IEEE 754 standard), that includes its internal representation of time -- yes, this means it will lose accuracy as we move into the future! (Any "integer" over 15 digits loses accuracy, so `9999999999999999 == 10000000000000000`.)

If for some reason you have one of these numbers (`Float` number of milliseconds since the UTC Epoch), this function will turn it into a Moment for you. However, it's more common to use Javascript's `new Date().getTime();`, which means you have an integer instead (in which case just use `moment (Milliseconds intHere) UTCEpoch` to get a moment, or `fromElmTime`.)

-}
fromJsTime : Float -> Moment
fromJsTime floatMsUtc =
    moment CoordinatedUniversal UnixEpoch (Duration.fromInt (round floatMsUtc))


{-| Turn an Elm time (from the core `Time` library) into a Moment. If you already have the raw Int, just run `fromElmInt` on it instead.

Since 0.19 Elm has a single type for UTC time, called `Posix`. In reality "POSIX" isn't a way of telling time, it's a description of how an operating system should work (like Unix and Gnu/Linux). It does mention a standard for representing UTC (which is actually a way of telling time), but that's already got a slightly nicer nickname ("Unix Time") and is _not_ stored as milliseconds since the epoch (like the Elm `Posix`). Rather, it counts _seconds_ since that epoch. (If sub-second accuracy is needed, it is expressed with decimal fractions.)

If you actually want a conversion from real "POSIX" time (rather than the elm type that bears the name), check out `fromUnixTime`.

-}
fromElmTime : ElmTime -> Moment
fromElmTime intMsUtc =
    fromElmInt <| ElmTime.posixToMillis intMsUtc


toElmTime : Moment -> ElmTime
toElmTime (Moment dur) =
    ElmTime.millisToPosix <| utcFromLinear (Duration.inMs dur)


{-| Handy alias for `(moment UTC UnixEpoch)` (though you may prefer that verbose version instead to make it clear what's going on).

If your time is still in Elm's native form, you want `fromElmTime` instead.

-}
fromElmInt : Int -> Moment
fromElmInt intMsUtc =
    moment CoordinatedUniversal UnixEpoch (Duration.fromInt intMsUtc)


{-| Turn a Unix time value into a Moment.

On "Unix-like" operating systems, the standard way of keeping time (as defined by a spec called POSIX) is with a single number of _seconds since the epoch_ as defined by the Universal Time standard (UTC) before leap second adjustments. Note that this differs from Elm's inbuilt time library (0.19+), which actually stores _milliseconds_ since the Unix/UTC epoch, despite having a type name of `Posix`. But this library can convert from this faux-Posix time too - check out `fromElmTime`.

Otherwise, use this if you have a real Unix timestamp. This library doesn't have a function named "fromPosix", so we can avoid this ambiguity. Just don't say the functionality wasn't there!

But how do Unix-like systems represent fractions of a second? With the numbers after the decimal point! Therefore, this function accepts a `Float` value. But do note that while your Gnu/Linux machine probably goes all the way down to the microsecond, the smallest Elm can handle is the millisecond - so only three decimal places of your input will be accurately recorded.

-}
fromUnixTime : Float -> Moment
fromUnixTime float =
    moment CoordinatedUniversal UnixEpoch (Duration.fromInt (round (float * 1000)))


{-| How far is this Moment from a particular `Epoch`?
-}
since : Moment -> Epoch -> Duration
since (Moment dur) epoch =
    dur



-- TODO


{-| Turn a Moment into a `Duration` since the given Epoch.
-}
toDuration : Moment -> TimeScale -> Epoch -> Duration
toDuration (Moment dur) timeScale epoch =
    dur



--TODO


{-| Turn a Moment into a raw Int so you can Encode it.
(Don't care about the format? Just use `toSmartInt`!)
The Int will be the number of milliseconds since the chosen `Epoch`, with corrections applied for your chosen `TimeScale`.
-}
toInt : Moment -> TimeScale -> Epoch -> Int
toInt (Moment dur) timeScale epoch =
    Duration.inMs dur



--TODO


{-| Turn a `Moment` into a raw `Int` so you can Encode it.
To decode it back to SmartTime, use `fromSmartInt`. These functions are recommended for Decoders/Encoders and storage of `Moment`s.

Synonymous with `toInt InternationalAtomic HumanEraStart`. If your exported number should be compatible with another system, look to those functions (e.g. `toUnixTime`) instead.

-}
toSmartInt : Moment -> Int
toSmartInt (Moment dur) =
    Duration.inMs dur


{-| Decode a raw `Int` (from SmartTime) into a `Moment`.
To get these values, use `toSmartInt`. These functions are recommended for Decoders/Encoders and storage of `Moment`s.

Creates a `Moment` just like `moment InternationalAtomic HumanEraStart`, with a `Duration` equal to the given number of milliseconds.

-}
fromSmartInt : Int -> Moment
fromSmartInt int =
    Moment (Duration.fromInt int)


type Epoch
    = UnixEpoch
    | HumanEraStart


{-| A few noteworthy timescales:

  - UT0: An old Universal Time based on looking at things in the sky from labs. The biggest shortcoming is failing to account for the fact that the earth's poles move, but hey, it was early.
  - UT1: This is the principal form of "Universal Time" (ambiguous though that may be), where the idea, as in ages past, is to locate the sun and line up our timekeeping with the solar day. Except it's hard to look at the sun, so we also look at stars and satellites, too. Then we just divide that by 86,400 to figure out how long a second is, since that's how many (60\_60\_24) there are in a day. Great idea in theory, but alas, our solar day speeds up and slows down all the time!
  - UT1R: is a smoothed version of UT1, filtering out periodic variations due to tides. We didn't like how much it was changing on us...
  - UT2: is another smoothed version of UT1, filtering out periodic seasonal variations. No one uses it anymore.
  - UTC: Forget moving around with the sun, we want to pick a single length of a second and stick with it! Except we still kinda like having our solar day line up... so let's shoot ourselves in the foot and make the length of a _day_ inconsistent! Yes, UTC is finally synced to the Atomic clock, so it always ticks every SI second. But, a day is not always 84,400 seconds anymore, because at any time there could be a "leap second", all so that we can get back within a second of UT1. Yes, really. Better yet, leap seconds do not even ensure that the sun culminates exactly at 12:00:00.000, as solar noon always deviates from it (up to 16 minutes) over the course of a single year!
  - TAI: Forget all that discontinuous nonsense, for real this time! TAI is just the Atomic clock scale - a pure, linear scale of SI seconds. No leap seconds, no adjustments, no surprises - in the future nor the past. Finally some sanity! UTC is based on atomic time, and would be the same exact scale since 1958 if not for the leap seconds (10 + 27 so far; we only get 6 months' notice on future leaps, some of which may be leaps _backwards_). PTP (Precise Time Protocol) is an uber-precise (sub-microsecond!) standard for distributing time to power grids (PUP accuracy: 1 μs) and such, and it also follows TAI.
  - GMT: Greenwich Mean Time is just the old name for Universal Time, from before 1935, when the term Universal Time was recommended by the International Astronomical Union as a more precise term (because GMT could refer to either an astronomical day starting at noon, or a civil day starting at midnight). But some still use this name for civil time - better to specify UT1 or UTC.
  - GPST: The GPS Time system is 19 seconds behind TAI, and uses a pure linear scale as well - and for good reason, as just one of those leap seconds would cause a GPS location error of up to 460 meters! Currently, GPST is 18 seconds ahead of UTC.
  - TT: Terrestrial Time is exactly 32.184s ahead of TAI for any moment after 1 January 1977 00:00:32.184, when we started applying correction for gravity slowing down/speeding up time (!) based on your elevation. As you may have guessed from the name, TT is often used for talking about timing of objects in space, from the point of view of our terrestrial selves.

-}
type TimeScale
    = CoordinatedUniversal
    | InternationalAtomic
    | GPS
    | Terrestrial


{-| Represents the beginning of the year 0 HE.
Just about anything recorded in civilization happened later than this, so it's a great default or "dummy" value for `Moment`.
-}
zero : Moment
zero =
    Moment Duration.zero
