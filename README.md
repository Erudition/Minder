[![Awesome Humane Tech](https://raw.githubusercontent.com/humanetech-community/awesome-humane-tech/main/humane-tech-badge.svg?sanitize=true)](https://github.com/humanetech-community/awesome-humane-tech)

# Minder
The ultimate assistant for ADHD. Keeps track of what you _should be doing_ and sends effective reminders (including zaps) if you're off task.

But how does Minder know what you _should be doing_?

## Docket
Todo list + Calendar + Time Tracker = Life Planner

- The original Elm project: an actual fork of Elm's TodoMVC example.
- Aiming to be the most powerful to-do list out there.
- Using traditional Elm HTML output and hosted here on Github Pages
- Not yet ready to be relied on by Minder :(


## Tasker
Minder is the formalization of a ton of Tasker scripts I had set up to accomplish the same task. I had been co-developing Minder with Docket, so I started to use Tasker's Javascript features to move more of Minder's logic into the Elm codebase.

## Todoist
As a temporary measure, I used Todoist to stand in for Docket until it's ready. It's proprietary, but it has an accessible API that I could even use in Tasker. Currently Todoist is still used for task management while Minder is being fleshed out.

## Capacitor
Eventually Tasker's imperative-ness and the bloat of the scripts got to be too much and I decided to create a full-blown app - but how? I wanted to use Elm, so naturally I looked at something like Cordova/PhoneGap, which displays web pages in native apps. I found a promising new kid on the block, Capacitor, and ended up using that instead. A large portion of the commit history is on the Capacitor version of the project.

## NativeScript
But Capacitor didn't really replace the Tasker functionality, like local notifications, triggering Pavlok Zaps, monitoring the apps the user spent time on for time tracking, etc. And of course using a webview is not a great start for performance, it's always better to go native.

However, giving up Capacitor seemed to mean giving up iOS/Android dual-compatibility until I found NativeScript. NativeScript would run JS in the full Android environment, meaning I could eventually implement all the Tasker features myself like any other native app. Awesome! Alas, I held off on it for a long time because of a big issue: My Elm-powered app would have an awesome logical foundation, but... no webview or HTML means Elm can't put anything on the screen!

Much later, seeing the power of NativeScript to easily handle my local notifications, I decided to just go for it. So I said goodbye to Capacitor for good, and even to the awkward Elm Integration with Tasker. I was now working strictly with Elm and NativeScript... and loving it. Native is great! Except I still have no solution for putting things on the screen. So I guess I'm going to learn to use NativeScript's XML-based view system for now, and have Elm in headless mode sending it all the data it needs to build the view. Ugh. One day I hope to hack the Elm VirtualDOM to work directly on the NS views though.



# Dev Journal

### 9/14/2019
- Needed to get viewmodel saved in a less hacky way than setting it to the "application settings storage" every time and re-decoding it from JSON. Finally figured out how to get global variables working, but Observables are really something else. After many hours of failed approaches I now have a single, global, Observable viewmodel that gets parsed (Decoded) from Elm but then is stored once in memory (since it doesn't need to be saved to disk) in pure JS. This is the very Observable object that NS wants to see, so I can use that instead and get rid of every `*-view-model.js` file in the repo now.
- But that "export" of data from Elm still needs to be triggered from elm somehow. I tried triggering it on every `update` ever (like `updateWithTime` and `updateWithStorage`), but it wasn't working, and we really only need it when the values are changed anyway. So now I have it trigger whenever the activity is changed! Still need a way to trigger it at launch though, without taking up the launch URL.
- Android notifs can only have one vibe pattern per channel? Fine, guess I'll have multiple channels then.
- Seems like "global" variables can't be read or changed from within the worker. For once that makes sense since the workers are supposed to be totally isolated. So I put the storing of the ViewModel update in the main thread (app.js) and just told the worker to let the main thread know. Works well.




== Using GitHub Under Protest ==

This project is currently hosted on GitHub.  This is not ideal; GitHub is a
proprietary, trade-secret system that is not Free, Libre, Open Souce Software
(FLO).  We are deeply concerned about using a proprietary system like GitHub
to develop our FOSS project. In the long term, we may make the move to Nest, powered by Pijul.
We urge you to read about the
[Give up GitHub](https://GiveUpGitHub.org) campaign from
[the Software Freedom Conservancy](https://sfconservancy.org) to understand
some of the reasons why GitHub is not a good place to host FLOSS projects.

Any use of this project's code by GitHub Copilot, past or present, is done
without our permission.  We do not consent to GitHub's use of this project's
code in Copilot.

![Logo of the GiveUpGitHub campaign](https://sfconservancy.org/img/GiveUpGitHub.png)