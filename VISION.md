Here is where I'm jotting some notes to make sure that the types of items that can be added to Minder are not only able to cover all types of "task", but are also orthogonal - there should be only one correct answer as to which type a certain task falls into.


# Maintainables

## Maintenance Tasks
"Maintainables" are the source of "maintenance tasks", which covers the use case for generic **recurring tasks** wherein
  - **There is no external deadline.** Waiting longer to do the task simply means *conditions get gradually worse*.
    - YES: Practice your Spanish-speaking skills.
      - The maintainable here is your skill, and the longer you wait, the rustier you get.
    - NO: Do Spanish class assignment 1A by Friday.
      - Even if your instructor accepts late work, it's late after Friday, and it's pointless after the course has concluded (expiration).
  - **There is no expiration.** You can neglect it indefinitely, yet at any point it's still doable.
    - YES: Wax your skis.
      - The maintainable being your skis, waxing them is one of many possible maintenance tasks.
    - NO: Apply for the 2030 Winter Olympics.
      - Deadlines aside, eventually the event itself will have passed.
  - **It may be "too soon".** Once you complete the maintenance task, there's a cool-down period during which it doesn't make sense to complete it again. (e.g. because it's ineffective.)
    - YES: Mow the lawn.
      - If you cut the grass again 1 hour later, it won't really get any shorter.
    - NO: Buy a lawnmower.
      - No matter when you do this, you will end up with 1 more lawnmower.
  - **As conditions worsen, importance may increase.** All else held equal, more-neglected tasks are strictly prioritized over the recently refreshed.
    - YES: Take a shower.
      - Sure, you could shower 8 hours after your last one, but you probably have better things to do. But if it's been a week...
    - NO: Play a game of Minetest.
      - It's not inherently more important just because you haven't done it in a while.
  - **Ideals may change.** You decide what conditions are considered acceptable, but the time windows used in past iterations (say, when you sported short hair) may differ from your current windows (e.g. now that you're keeping your hair longer) even if your tolerance didn't change.
    - YES: Get a haircut.
      - Been a while? You could be neglecting this, or you could be transitioning to a longer hairstyle.
    - NO: Pay credit card bill.
      - "Too early", "on time", "late", and "way too late" are strictly determined by your CC company, not you.


# Conditions
The conditions (of that which is maintained) can be categorized as such:
- Acceptable
  - **Fresh** (optional, too soon to refresh)
  - **Ideal** (optional)
  - **Okay**
- Unacceptable
  - **Poor** (optional)
  - **Critical** (optional)



## Examples
- Task: Cut your hair / Get a haircut / Shave head
  - Maintainable: Head hair
- Task: Trim dead ends
  - Maintainable: Head hair > hair ends    (optional nestable entity > part)

## Hierarchy
- "things" can have parts and/or contents (or are monolithic)
- "containers" optionally hold things
  - ex. bookbag
  - ex. rooms
  - ex. car
- "entities" optionally have "parts", which are things
  - ex. "your body"
  - ex. car
