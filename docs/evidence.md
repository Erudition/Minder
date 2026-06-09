# Evidence: How Minder Knows What You're Doing

> This document describes the Evidence system — the sensor signal types that Minder uses to passively detect your current Activity without requiring manual input. For how Evidence fits into the broader Activity system, see [activities.md](activities.md).

---

## What Is Evidence?

**Evidence** is a piece of sensor data that suggests a particular Activity is happening. Each Activity in Minder can have a list of associated Evidence types. When a sensor produces data matching an Activity's evidence profile, Minder can infer that Activity is in progress — without the user needing to start a timer or tap anything.

The goal: **Minder should know what you're doing most of the time, without asking.**

---

## Evidence Types

### UsingApp

```elm
UsingApp AppDescriptor (Maybe Device)

type alias AppDescriptor =
    { package : String    -- e.g., "com.discord"
    , name : String       -- e.g., "Discord"
    }
```

The most straightforward evidence type. If a specific app is in the foreground on the user's phone or desktop, that strongly suggests a particular Activity:

| Foreground App | Inferred Activity |
|---|---|
| VS Code, IntelliJ | Work / Homework |
| Discord, Telegram, WhatsApp | Messaging |
| Netflix, YouTube | Series / Film Watching |
| Spotify, Apple Music | Music |
| Instagram, Twitter, Reddit | Social Media |
| Chrome (general browsing) | Browse |
| Duolingo, Anki | Learning |
| Zoom, Google Meet | Meeting / Call |

The optional `Device` field distinguishes *which* device the app is active on. This matters because using Discord on your work laptop during work hours is probably a quick message check (excused), but using it on your gaming PC at 11pm is probably socializing (leisure).

### StepCountPace

```elm
StepCountPace StepsPerMinute

type alias StepsPerMinute = Int
```

Pedometer-based evidence. The step rate per minute strongly correlates with physical Activity:

| Steps/Minute | Likely Activity |
|---|---|
| 0 | Sedentary (Sleep, Work, Meal, etc.) |
| 1-30 | Light movement (Pacing, Housekeeping) |
| 30-80 | Walking (Transit, Shopping) |
| 80-120 | Brisk walking / light exercise |
| 120+ | Running / vigorous Workout |

The step count alone can't distinguish *which* sedentary Activity is happening (sleeping and coding both have zero steps), but it can confirm or deny physical activities. If the schedule says you should be "Working out" but your step count is zero for 30 minutes, something's off.

---

## Planned Evidence Types

The current two evidence types (UsingApp and StepCountPace) are the minimum viable set. The architecture is extensible — new Evidence variants can be added to the union type as sensor integrations mature:

### Location

GPS coordinates or geofence triggers matching known locations:
- At the gym → Workout
- At the office → Work
- At the grocery store → Shopping
- At home → context-dependent (could be many Activities)

Location evidence is especially powerful combined with other signals. "At home + zero steps + 11pm" → probably Sleep. "At home + high steps + morning" → probably Housekeeping or Workout.

### Heart Rate

From a smartwatch or fitness tracker:
- Resting heart rate during the day → sedentary Activity, possibly napping
- Elevated heart rate → exercise or stress
- Heart rate patterns matching sleep stages → Sleep confirmation

### Phone Call State

The phone's call state is a strong, binary signal:
- Active voice call → "Call" Activity
- No call → not calling (obviously, but useful for ruling out)

### Screen State

Whether the phone screen is on or off, and for how long:
- Screen off for extended period → Sleep, or phone left behind
- Screen on with no touch → watching something (Film, Series)
- Rapid touch input → Messaging or Browse

### External Service Data

Data from purpose-built tracking tools:
- **ActivityWatch**: Desktop screen time broken down by application and window title. The most granular desktop evidence source — can distinguish "VS Code editing Minder project" from "VS Code editing homework."
- **Sleep trackers**: Fitbit, Oura Ring, Apple Watch — provide precise sleep/wake transitions with stage data (light, deep, REM).
- **Google Fit / Apple Health**: Aggregated fitness data including steps, active minutes, workouts, and heart rate.

---

## How Evidence Is Used

### Activity Inference Priority

Evidence feeds into the three-layer Activity inference described in [activities.md](activities.md):

1. **Explicit tracking** (highest priority): User manually started tracking a task/Activity.
2. **Sensor evidence** (medium priority): Evidence signals suggest an Activity. Multiple concurrent evidence types increase confidence.
3. **Schedule assumption** (lowest priority): The schedule says you should be doing X. No contradicting evidence found, so assume X.

When sensor evidence contradicts the schedule assumption, the system can:
- Update the Activity silently (if confidence is high)
- Prompt the user ("Looks like you're messaging — still working on the report?")
- Log the discrepancy for later analysis

### Confidence and Conflict Resolution

Multiple evidence types can point to different Activities simultaneously. For example:
- UsingApp says "Discord" → Messaging
- StepCountPace says "0 steps" → Sedentary (consistent with Messaging, but also consistent with Work)
- Location says "at office" → Work

The system needs a confidence model to resolve conflicts. Discord at the office during work hours with zero steps is most likely a brief messaging detour during Work — not a switch to a full Messaging session. This aligns with the Excused state in the Refocus system: the Activity is tentatively "Messaging" but within the excused window for Work.

### Condition Progression

Evidence that confirms an Activity also confirms condition progression for attributes that degrade along that Activity's dimension. If pedometer data confirms you're Driving (steps = 0, but GPS shows highway-speed movement), that confirms mile accumulation for the car's oil change condition — even if the user never explicitly said "I'm driving."

### Smart Alarm Timing

Evidence-confirmed Activities feed into the smart alarm system. If evidence shows you're currently in a Workout (high step count, elevated heart rate, at the gym), Minder knows not to fire task reminders until the workout ends. The alarm waits for the Activity transition before suggesting the next task.

---

## Privacy and Local-First Processing

All evidence processing happens **on-device.** Sensor data is never uploaded to a server. The user controls:
- Which evidence types are enabled (granular per-sensor permissions)
- Which Activities use which evidence types
- How aggressively the system infers (manual confirmation vs. automatic detection)
- Retention period for raw sensor data

This is fundamental to Minder's local-first architecture. The system needs intimate access to your sensor data to work well, and that data stays on your device.

---

## Summary

1. **Evidence is sensor data linked to Activities.** Each signal type (app usage, step count, location, etc.) provides passive detection of what you're doing.
2. **Two types are implemented:** UsingApp (foreground app + device) and StepCountPace (pedometer rate). More are planned.
3. **Evidence feeds the three-layer inference:** Explicit > sensor > schedule assumption.
4. **Multi-signal confidence resolves conflicts.** Multiple evidence types increase confidence or reveal contradictions.
5. **Evidence drives condition progression and smart alarms.** Confirmed Activities advance attribute degradation and inform alarm timing.
6. **All processing is local.** Privacy is structural, not policy.
