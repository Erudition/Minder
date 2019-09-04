# Docket
Todo list + Calendar + Time Tracker = Life Planner

- Current focus is time tracker.
- Auto-deploying with git hook.
- Deploying to Github pages.
- Integrating with Tasker.


# Dev Journal

### 9/14/2019
- Needed to get viewmodel saved in a less hacky way than setting it to the "application settings storage" every time and re-decoding it from JSON. Finally figured out how to get global variables working, but Observables are really something else. After many hours of failed approaches I now have a single, global, Observable viewmodel that gets parsed (Decoded) from Elm but then is stored once in memory (since it doesn't need to be saved to disk) in pure JS. This is the very Observable object that NS wants to see, so I can use that instead and get rid of every `*-view-model.js` file in the repo now.
- But that "export" of data from Elm still needs to be triggered from elm somehow. I tried triggering it on every `update` ever (like `updateWithTime` and `updateWithStorage`), but it wasn't working, and we really only need it when the values are changed anyway. So now I have it trigger whenever the activity is changed! Still need a way to trigger it at launch though, without taking up the launch URL.
- Android notifs can only have one vibe pattern per channel? Fine, guess I'll have multiple channels then.
- Seems like "global" variables can't be read or changed from within the worker. For once that makes sense since the workers are supposed to be totally isolated. So I put the storing of the ViewModel update in the main thread (app.js) and just told the worker to let the main thread know. Works well.
