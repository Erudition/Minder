module SmartTime.Moment exposing (ElmTime, Epoch, Moment, TimeScale(..), compare, difference, every, fromElmInt, fromElmTime, fromJsTime, fromSmartInt, fromUnixTime, future, linearFromUTC, moment, now, past, toElmTime, toInt, toSmartInt, toUnixTime, toUnixTimeInt, zero)

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


type alias ElmTime =
    ElmTime.Posix


{-| Get the current time periodically. How often though? Well, you provide a `Duration` and that is how often you get a new time!

Want to hardcode this value? Yup, thought so. In that case use `Clock.every` instead, and you can just use `HumanDuration`s directly!

(Not for efficient animation. Use the [`elm/animation-frame`][af]
package instead.)
[af]: /packages/elm/animation-frame/latest

-}
every : Duration -> (Moment -> msg) -> Sub msg
every interval tagger =
    let
        convertedTagger : ElmTime -> msg
        convertedTagger elmTime =
            tagger (fromElmTime elmTime)
    in
    ElmTime.every (toFloat <| Duration.inMs interval) convertedTagger


{-| Create a Moment. A Moment is an `Epoch` and some `Duration` -- the amount of time since that Epoch -- which gives us a globally fixed point in time. You can shift this moment forward or backward by adding other `Duration` values to it.
-}
moment : TimeScale -> Epoch -> Duration -> Moment
moment scale epoch duration =
    case ( scale, epoch ) of
        ( _, _ ) ->
            --TODO
            Moment (Duration.map linearFromUTC duration)


linearFromUTC : number -> number
linearFromUTC num =
    num


utcFromLinear : number -> number
utcFromLinear num =
    num


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

Works just like a normal `compare`, returning their `Order` in time:
If the first moment is later than the second, returns `GT`.
If the first moment is earlier than the second, returns `LT`.
If the moments define the same instant in time, returns `EQ`.

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
    moment CoordinatedUniversal unixEpoch (Duration.fromInt (round floatMsUtc))


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
    moment CoordinatedUniversal unixEpoch (Duration.fromInt intMsUtc)


{-| Turn a Unix time value into a Moment.

On "Unix-like" operating systems, the standard way of keeping time (as defined by a spec called POSIX) is with a single number of _seconds since the epoch_ as defined by the Universal Time standard (UTC) before leap second adjustments. Note that this differs from Elm's inbuilt time library (0.19+), which actually stores _milliseconds_ since the Unix/UTC epoch, despite having a type name of `Posix`. But this library can convert from this faux-Posix time too - check out `fromElmTime`.

Otherwise, use this if you have a real Unix timestamp. This library doesn't have a function named "fromPosix", so we can avoid this ambiguity. Just don't say the functionality wasn't there!

But how do Unix-like systems represent fractions of a second? With the numbers after the decimal point! Therefore, this function accepts a `Float` value. But do note that while your Gnu/Linux machine probably goes all the way down to the microsecond, the smallest Elm can handle is the millisecond - so only three decimal places of your input will be accurately recorded.

-}
fromUnixTime : Float -> Moment
fromUnixTime float =
    moment CoordinatedUniversal unixEpoch (Duration.fromInt (round (float * 1000)))


toUnixTime : Moment -> Float
toUnixTime (Moment dur) =
    utcFromLinear (Duration.inSeconds dur)


toUnixTimeInt : Moment -> Int
toUnixTimeInt mo =
    truncate <| toUnixTime mo


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



-- WIBBLY WOBBLY TIMEY WIMEY


{-| Remember how a `Moment` can be defined simply by a distance in time (`Duration`) from some fixed point? Well we call that fixed point an `Epoch` - some widely-agreed-upon stake in the ground, so we can all sensibly talk about moments in time in the same fram of reference.

This library can transparently change between these frames of reference, but chances are this isn't something you'll need to worry about unless you're creating a `Moment` from scratch (via `moment`) or passing them in or out from other systems or libraries or languages.

-}
type alias Epoch =
    Moment


{-| The famous Unix Epoch is 00:00:00 Thursday, 1 January 1970. Unix-like systems (or POSIX systems - which is a lot of the world's infrastructure!) keep time relative to this moment, by counting the number of seconds (not miliseconds, like ElmTime) since then (albeit on a discontinuous UTC timescale).

At 03:33:20 UTC on Wednesday, 18 May 2033, the Unix time value will equal 2000000000 seconds. See you at the party?

Note: For some reason, some people unfamiliar with [any epoch other](https://www.wikiwand.com/en/Epoch_(computing)) than this one have misleadingly been calling Unix time "Epoch time". In reality, all timekeeping must be relative to some `Epoch`, and as you can see in this library, there's more than one possibility!

-}
unixEpoch : Epoch
unixEpoch =
    Moment (Duration.fromInt 0)


{-| Okay, so the Unix epoch is 00:00:00 Thursday, 1 January 1970. But that's UTC, and the UTC we use didn't exist until 1972! Wha??

The present form of UTC, with leap seconds, is defined only from 1 January 1972 onwards. That's why this `Epoch` is here. Prior to that, since 1 January 1961 there was an older form of UTC in which not only were there occasional time steps, which were by non-integer numbers of seconds, but also the UTC second was slightly longer than the SI second, and periodically changed to continuously approximate the Earth's rotation! Prior to 1961 there was no UTC, and prior to 1958 there was no widespread atomic timekeeping.

So, if you want your `Moment`s to always be precisely defined from system to system, use this Epoch, and you'll know that positive numbers avoid all of those problems. Any negative numbers should be understood to be an ambiguous and unspecified approximation.

-}
utcDefined : Epoch
utcDefined =
    future unixEpoch (Duration.fromInt 63072000000)


{-| Take the current year, and stick a 1 in front of it (`2019 CE -> 12019 HE`). That's the current year H.E. - Human Era - a pretty decent approximation of how long human civilization has been around! Easy, right?
That means that by using this as your `Epoch`, you can describe and reason about just about any event in human history _without resorting to negative numbers_! This library uses this epoch internally, so all of our `Moments` are positive.
-}
humanEraStart : Epoch
humanEraStart =
    Moment (Duration.fromInt 0)


{-| The moment <current-year> years ago. It's actually year 1 C.E. (common era), also called 1 A.D., not 0 A.D. (like [the video game](play0ad.com)) - and believe it or not, it directly follows year 1 B.C.E.! Why is there [no "year zero"](https://www.wikiwand.com/en/Year_zero)? Because Roman Numerals had no concept of "zero", let alone a symbol for it. But hey, imagine how many `IndexOutOfBounds` errors they would have avoided!

Fun fact: More time messiness - this is only an issue in the Gregorian calendar (year zero exists in all Buddhist and Hindu calendars), but just like the issue with leap seconds can cause errors when subtracting two moments to get the distance between them, the lack of year zero causes the same problem when subtracting two years (which contain that moment in time). For this reason astronomers force 1 BCE to be "year 0", and the years before that are simply _negative_. Purity and linearity is restored! Rest assured that this is what these libraries use, when applicable. (Unfortunately, this also means those years are off by one.)

    "The year which historians call 585 B.C. is actually the year −584. The astronomical counting of the negative years is the only one suitable for arithmetical purpose." — Jean Meeus, Astronomical Algorithms

Compatibility: ISO 8601:2004 has year zero (where it again coincides with the Gregorian year 1 BC), as it now uses astronomical year numbering (and previously ISO 8601:2000, but not ISO 8601:1988). However, years prior to 1583 (when the Gregorian calendar came out) are not automatically allowed by the standard. Instead "values in the range [0000] through [1582] shall only be used by mutual agreement of the partners in information interchange."

Note that year zero (1BC) is a full year, NOT an instant in time - this epoch refers to the end of that year, or the moment year 1 CE began and 1 BCE ended.

Some standards that use this Epoch: ISO 2014, RFC 3339, Rata Die
Some software that uses this epoch: Microsoft .NET, Go, REXX

-}
commonEraStart : Epoch
commonEraStart =
    Moment (Duration.fromInt 0)


{-| The year before `commonEraStart`, aka 1 B.C., aka the beginning of astronomical "year zero".

Note that year zero is a full year, NOT an instant in time - this epoch refers to the beginning of that year. For the end of that yer, check out `commonEraStart`, which is probably what you want anyway.

Some software that uses this epoch: MATLAB

-}
oneBCE : Epoch
oneBCE =
    Moment (Duration.fromInt 0)


{-| You can think of it as "the Windows Epoch": Jan 1, 1601.

Why 1601? 1601 was the first year of the 400-year Gregorian calendar cycle at the time Windows NT was made.

Some software that uses this epoch: NTFS, COBOL, Win32/Win64

-}
windowsNT : Epoch
windowsNT =
    Moment (Duration.fromInt 0)


{-| November 17, 1858, 00:00:00 UT, the zero of the Modified Julian Day (MJD) equivalent to Julian day 2400000.5.

A epoch used in VMS, United States Naval Observatory, DVB SI 16-bit day stamps, and other astronomy-related computations.

-}
astronomy : Epoch
astronomy =
    Moment (Duration.fromInt 0)


{-| December 30, 1899, the epoch used in Google Sheets, LibreOffice Calc, Microsoft COM DATE, Object Pascal, etc. to maintain compatibility with Microsoft Excel. Excel used the same date in the form of January 0, 1900 in turn to maintain compatibility with the even older Lotus 1-2-3, the IBM PC's first killer app.

Ah, legacy. While logically January 0, 1900 is equivalent to December 31, 1899, those systems did not allow users to specify the latter date. Since 1900 is incorrectly treated as a leap year in these systems, January 0, 1900 actually corresponds to the historical date of December 30, 1899.

Fun fact: Microsoft Excel also observes the fictional date of February 29, 1900 in order to maintain compatibility with older versions of Lotus 1-2-3. Lotus 1-2-3 observed the date due to an error; by the time the error was discovered, it was too late to fix it—"a change now would disrupt formulas which were written to accommodate this anomaly".

Oh, and there's another Epoch (not included) on the date December 31, 1899, used by Dyalog APL and Microsoft C/C++ 7.0 - chosen so that (date mod 7) would produce 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, and 6=Saturday. Microsoft’s last version of non-Visual C/C++ used this, but was subsequently reverted.

-}
spreadsheets : Epoch
spreadsheets =
    Moment (Duration.fromInt 0)


{-| January 1, 1900: The epoch used by the Network Time Protocol, Mathematica, IBM CICS, RISC OS, VME, the Michigan Terminal System, and even Common Lisp!

Note: It may be tempting to think of this as "the beginning of the 20th Century", but that would actually be 1901.

-}
nineteen00 : Epoch
nineteen00 =
    Moment (Duration.fromInt 0)


{-| The first leap year of the 20th century, January 1, 1904, is the epoch used by classic Mac OS, and sometimes Excel.

Used in: LabVIEW, Apple Inc.'s classic Mac OS, JMP Scripting Language, Palm OS, MP4, Microsoft Excel (optionally), IGOR Pro

-}
nineteen04 : Epoch
nineteen04 =
    Moment (Duration.fromInt 0)


{-| The start of 1980 is the `Epoch` used by FAT32, which is probably what your flash drive is formatted to, and other older file systems: IBM BIOS INT 1Ah, DOS, OS/2, FAT12, FAT16, FAT32, exFAT. Chose because the IBM PC with its BIOS as well as 86-DOS, MS-DOS and PC DOS with their FAT12 file system were developed and introduced between 1980 and 1981.
-}
oldFS : Epoch
oldFS =
    Moment (Duration.fromInt 0)


{-| The epoch used by Qualcomm BREW, GPS, and ATSC 32-bit time stamps.

GPS counts weeks for some reason, and a week is defined to start on Sunday, and since January 6 is the first Sunday of 1980, it is the first week.

-}
gpsEpoch : Epoch
gpsEpoch =
    Moment (Duration.fromInt 0)


{-| Y2K: January 1, 2000. Interfacing with Postgres? This one's for you.

The epoch used by AppleSingle, AppleDouble, PostgreSQL, ZigBee's UTCTime.
(ZigBee is the open standard protocol used to control your smarthome!)

-}
y2k : Epoch
y2k =
    Moment (Duration.fromInt 0)


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
