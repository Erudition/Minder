# Activities: The Hidden Backbone

> This document describes Minder's Activity system — what seems on the surface like a simple time-tracking category, but is actually the connective tissue that powers smart alarms, sensor-based tracking, condition progression, and the Refocus attention management loop.

---

## What Is an Activity?

An **Activity** is a category of labor — the *kind of work* you're doing, independent of *why* you're doing it or *what specific task* it serves. Cleaning, coding, driving, eating, sleeping, exercising — these are Activities.

Activities are orthogonal to both the task system and the Cares system:
- **Task layer:** *What specific thing* you're doing (e.g., "Clean the kitchen")
- **Care layer:** *What you're doing it for* (e.g., "My home")
- **Activity layer:** *What kind of work it is* (e.g., "Cleaning")

You might do the Activity "Cleaning" for multiple Cares (cleaning the kitchen → My Home; cleaning the car → My Car). A single Care might involve many Activities (My Car → Cleaning, Paperwork, Mechanical work, Driving). And a single task might involve multiple Activities over its duration (a road trip involves Driving, Eating, Navigating, Resting).

---

## Why Activities Seem Boring

On the surface, the Activities screen looks like a basic time tracker. Pick an activity, start a timer, stop when you're done. Most users don't care enough about time-tracking data to manually track their activity switches all day — especially when the results are so general (how much time did I spend "Messaging"?) and not task-specific.

This is by design. **Activities are not primarily a user-facing feature.** They're the sensor backbone that powers almost every other system in Minder.

---

## What Activities Actually Do

### 1. Automatic Time Tracking

When you track a task, Minder automatically tracks the corresponding Activity. You don't need to separately say "I'm doing Cleaning now" — starting the "Clean the kitchen" assignment automatically logs Cleaning as the active Activity. The Activity tracking is a side effect of task tracking, not a separate manual step.

### 2. Smart Alarm Context

Activities inform the smart alarm system (see [scheduling.md](scheduling.md)). Minder won't interrupt you mid-workout to remind you about taxes, because it knows (from the Activity state) that you're exercising. It won't fire a "pick up dry cleaning" reminder while you're driving, because Driving is the active Activity and the reminder needs you to be on foot near a dry cleaner.

The Activity state answers the question: **"Is the user available for this particular task right now?"**

### 3. Sensor-Based Activity Detection (Evidence)

This is where Activities become truly powerful. Each Activity can have associated **Evidence** — sensor signals that indicate the Activity is happening:

```elm
type Evidence
    = UsingApp AppDescriptor (Maybe Device)
    | StepCountPace StepsPerMinute
```

Currently two evidence types are implemented:

- **UsingApp**: Which app is in the foreground, on which device. If Discord is active, you're probably in "Messaging" or "Call." If VS Code is active, you're probably "Working" or doing "Homework." If Netflix is active, you're watching "Series."
- **StepCountPace**: The pedometer's step rate. High step count = "Walking" or "Workout." Zero steps for an extended period = sedentary Activity (Coding, Sleeping, etc.).

Future evidence types could include:
- **Location**: GPS coordinates matching known locations (at the gym → Workout; at the office → Work; at home → varies)
- **Heart rate**: Elevated heart rate → likely exercising. Resting heart rate during the day → possibly napping.
- **Phone activity**: Active call → "Call" Activity. Rapid typing → "Messaging."
- **Screen time data**: From tools like ActivityWatch, which track foreground app usage on desktop
- **Sleep tracker**: Confirms Sleep activity, marks actual sleep/wake transitions
- **Calendar integration**: Meeting scheduled → "Meeting" Activity expected

### 4. Activity Inference (The Secret Purpose)

The "secret" of Activities is that Minder uses them to **estimate what you're doing when you haven't explicitly told it.** This works through three mechanisms:

**a) Task-derived tracking:** When you start tracking a task, Minder records the associated Activity. No manual Activity selection needed.

**b) Sensor-derived inference:** When sensor evidence (step count, foreground app, location) matches an Activity's evidence profile, Minder can infer the Activity without the user doing anything. Your phone's pedometer shows 120 steps/minute? You're walking. Your phone shows you launched the YouTube app? You're probably watching something.

**c) Plan-derived assumption:** When the schedule says you should be working on "Write quarterly report" from 2-4pm, and that time passes without any sensor evidence contradicting it, Minder assumes you're doing what you planned. The Activity is "Working" until evidence suggests otherwise.

This three-layer inference (explicit tracking > sensor evidence > schedule assumption) means Minder always has a best guess for what you're currently doing, which feeds into:
- The Refocus system's Traction/Distraction detection
- Smart alarm timing
- Condition progression tracking (if "Driving" is active, accumulate miles)
- Duration estimation refinement (actual time spent on Activity X)

### 5. Condition Progression Tracking

Activities are the mechanism by which non-time-based condition dimensions progress (see [conditions.md](conditions.md)). If your car's oil degrades with miles driven, and "Driving" is the Activity that accumulates miles, then every time the Driving Activity is tracked, the oil change condition advances.

This is how the scheduler can predict oil change timing from the schedule: if the schedule contains driving trips (tasks with the Driving Activity), Minder can sum the expected driving time, convert to estimated miles, and project when the oil condition will cross into "needs attention."

### 6. Excusability and Focus Management

Each Activity has an **excusable** property that determines how it interacts with the Refocus system (see below):

```elm
type Excusable
    = NeverExcused       -- e.g., DillyDally, Browsing — always a distraction
    | TemporarilyExcused DurationPerDuration  -- e.g., Messaging (7 min per 30 min)
    | IndefinitelyExcused  -- e.g., Sleep — take as long as you need
```

If you're supposed to be working on Task X but you switch to Messaging, Minder doesn't immediately nag you. It checks: is Messaging excusable? If yes, for how long? You get a grace period (e.g., 7 minutes out of every 30) before the system escalates to distraction warnings. This is the **Excused** state in the Refocus system.

### 7. Maximum Time Budgets

Each Activity has a **maxTime** property — a budget of how much time per period you intend to spend on it. "2 hours of Social Media per day" is a constraint that the scheduler respects. If you've used your Social Media budget for the day, the scheduler won't suggest Social Media tasks, and the Activity switches to "not excused" in the Refocus system.

---

## The Refocus System: Traction, Excused, Distraction, Free

The Refocus system (implemented in `Refocus.elm`) uses Activity data to manage attention in real-time. At any moment, you're in one of four states:

### Traction (Green 🟢)

You're working on the task that Minder determined is **What's Important Now (W.I.N.)**. The system shows:
- A green persistent notification with progress tracking
- Time-based progress reminders (half done, two-thirds done, three-quarters done)
- A "Time's up!" notification when the estimated duration expires

### Excused (Yellow 🟡)

You've switched away from the W.I.N. task to an Activity that is **excusable** (e.g., bathroom break, quick message). The system shows:
- A yellow notification with a countdown timer
- "Distraction taken care of?" prompts at 10, 20, and 30 minutes
- A final "Finish up! Only X left!" warning as the excused time runs out

### Distraction (Red 🔴)

You've either exceeded your excused time, or switched to a **never-excused** Activity while there's important work to do. The system shows:
- Red notifications with escalating urgency
- Escalating vibration patterns (more intense with each reminder)
- Up to 10 reminder attempts before "giving up"
- Random encouragement messages: "You have important goals to meet!", "Why not put this in your task list for later?"

### Free (No Color)

All prioritized tasks are done (or none are actionable right now). You're free. The notification is non-intrusive.

---

## Built-In Activity Templates

Minder ships with ~40 built-in Activity templates covering common life activities. These provide sensible defaults that the user can customize:

| Category | Activities |
|---|---|
| **Hygiene** | Apparel, Grooming, Shower, Toothbrush, Floss |
| **Transit** | Driving, Riding, Flight |
| **Communication** | Messaging, Call, Email |
| **Work** | Work, Meeting, Homework, Presentation, Course |
| **Self-care** | Meal, Workout, Sport, Sleep, Wakeup, Supplements, Meditate |
| **Home** | Chores, Housekeeping, Laundry, MealPrep |
| **Leisure** | Browse, Fiction, Series, FilmWatching, Cinema, Theatre, VideoGaming, Music, SocialMedia |
| **Planning** | Plan, Configure, Prepare, Bedward |
| **Social** | Parents, Lover, Children, Networking, Pet, Shopping |
| **Meta** | DillyDally (the default — "doing nothing"), Finance, Learning, BrainTrain, Create |

Each template defines:
- Multiple synonymous names (for matching and display)
- An icon (emoji or SVG)
- Excusability settings (NeverExcused, TemporarilyExcused with limits, IndefinitelyExcused)
- Maximum time budget per period
- Whether a task is optional (the Activity can be tracked without a specific task)
- Whether it's backgroundable (can run concurrent with another Activity)
- Evidence associations (which sensor signals indicate this Activity)

Users can hide unused templates, customize any field, or create entirely custom Activities.

---

## External Integration

Activities have an **externalIDs** field — a dictionary mapping external service names to their corresponding IDs. This enables sync with:
- **ActivityWatch**: Desktop app/screen time monitoring
- **Google Fit / Apple Health**: Step count, heart rate, sleep data
- **Calendar services**: Mapping calendar events to Activities
- **Other task apps**: Mapping Todoist labels or Marvin activities to Minder Activities

---

## Summary

1. **Activities are the sensor backbone.** They seem like a simple time tracker but power smart alarms, condition progression, and the Refocus attention loop.
2. **Evidence enables passive tracking.** Sensor signals (foreground app, step count, location) can automatically detect the current Activity without user input.
3. **Three-layer inference:** Explicit tracking > sensor evidence > schedule assumption. Minder always has a best guess.
4. **Excusability manages attention gracefully.** Brief detours are expected and tolerated; extended distractions escalate gradually.
5. **Activities bridge the task and condition systems.** Tracking "Driving" both logs time on a driving task AND advances the car's oil change condition.
6. **Built-in templates provide sensible defaults.** ~40 common Activities ship out of the box, all customizable.
