<!-- gf-brief source=520e0399d6bdba66bfa9bb913e20f54443b3bc32652f93d4eb7fa65afd9e9ac5 written=2026-11-26T03:43:08+03:00 -->
# Soach Board

## What it is

Soach Board is a tactical board and training planner for football, futsal, and basketball coaches. Coaches can draw and play back tactics, organize them into training sessions, and share copies or PDFs.

## Launch and onboarding

1. On first launch, the app opens directly to the “Board” tab under the title “Soach Board”. There is no onboarding screen, welcome button, or permission prompt.
2. The board shows “TACTICAL BOARD”, the sport control “Football”, and the starter tactic “Build from the back”. It opens at “FRAME 1/3” with “Saved on device”. The first frame already contains seven player markers, two opponent markers, a ball, and two drawings.
3. “Move” is selected, with the instruction “Drag a marker to move it.” The sequence is ready to preview with “Play sequence”. The tactic’s coaching note reads “Draw the press, then find the free player. Keep the supporting angles open.”
4. The four tabs are “Board”, “Library”, “Training”, and “Team & settings”. On a later ordinary cold launch, “Board” opens at frame 1 of the last selected tactic.

## Screens

### “Board”

The navigation title is “Soach Board”. The board shows the current tactic name, its field or court, a frame counter such as “FRAME 1/3”, and “Saved on device”. The sport control displays the active sport. Its options are “Football”, “Futsal”, and “Basketball”. Choosing one changes the field or court while retaining the tactic’s frames and their contents.

- “Move” selects a nearby marker and lets you drag it. The instruction is “Drag a marker to move it.”
- “Player”, “Opponent”, “Ball”, and “Cone” place the corresponding marker when you tap the field. “Erase” removes a nearby marker or drawing. These tools show “Tap the field to place or erase.”
- “Pass”, “Run”, and “Zone” draw a pass arrow, a run, or a rectangular zone when you drag on the field. They show “Drag on the field to draw.”
- The trash icon, labeled “Clear frame” for accessibility, opens “Clear this frame?”. The destructive “Clear frame” action removes every marker and drawing from the current frame and leaves the frame in the sequence.
- “PLAY SEQUENCE” contains numbered frame thumbnails. Tap a thumbnail to select that frame and stop playback. Its accessibility label is “Frame” followed by the number, such as “Frame 1”. The plus icon, “Add frame”, copies the selected frame, inserts the copy immediately after it, and selects the copy. The minus-square icon, “Delete frame”, removes the selected frame and selects the preceding frame or the new first frame.
- “Undo” and “Redo” are curved-arrow icons that step backward and forward through tactic edits.
- “Play sequence” starts from frame 1 and previews the frames in order. “Pause” stops playback on the current frame. The timing label is “2 sec / frame”. When Reduce Motion is enabled, it reads “Step preview” and the frames change without interpolated marker movement.
- “Markers” expands a list of numbered markers, such as “Player 1”, “Opponent 1”, “Cone 1”, or “Ball 1”. Tap a marker to select it and switch to “Move”. “Selected marker” shows “Delete”, which removes the selected marker, and directional icons labeled “Move left”, “Move right”, “Move up”, and “Move down”. For a player or opponent, the “Number” stepper changes the jersey number from 1 to 99. The coaching note appears below the marker controls when one is present.
- The unlabeled ellipsis menu offers “New tactic”, which creates and opens a blank “Untitled tactic” in the current sport, and “Duplicate”, which creates and opens a copy with “ · Copy” appended to its name.
- “Tactic details” opens a form titled “Tactic details” with “Tactic name” and “Coaching notes”. It says “Every change on the board is saved automatically on this device.” “Cancel” discards form edits. “Save” applies them and closes the form.
- “Export PDF” opens the system share sheet with a PDF containing one page per frame, labeled “Coaching sequence”, plus “Coaching notes” pages when there are notes. “Export tactic file” opens the share sheet with an importable copy of the current tactic. “Import tactic file” opens the system file picker and selects a valid imported tactic on the board.
- “Full screen” opens the same board and editing controls in a view titled “Tactical board”. “Done” returns to the regular board.

### “Library”

“Library” has a system search field with the prompt “Find a tactic”. It searches saved tactic names and coaching notes. The “Sport” filter offers “All sports”, “Football”, “Futsal”, and “Basketball” and filters both saved tactics and exercise starters.

- “Saved tactics” lists the most recently revised tactics first, with a first-frame thumbnail, tactic name, sport, and frame count, such as “Football · 3 frames”. Tap a row to open the tactic on “Board” at frame 1.
- Long-press a saved tactic for “Duplicate” or “Delete”. “Duplicate” creates and selects a local copy while leaving “Library” visible. Swiping a row also reveals “Delete”. It opens “Delete this tactic?” with the message “It will also be removed from local training plans. Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again.” “Delete tactic” confirms the removal, including any links from training sessions.
- “Exercise starters” lists six named templates, each marked “Built-in exercise”. Tap one to add a fresh editable tactic and open it on “Board”. The footer says “Built-in exercises are starting points. Adapt the movements and intensity to your players.”
- The unlabeled plus menu offers “New tactic”, which opens a blank football “Untitled tactic” on “Board”, and “Import tactic file”, which opens the system file picker.

### “Training”

“Training” opens with “Make every session count.” and “Plan a week. Build a season.” Sessions appear in date order with their title, date and time, duration in “min”, optional season and notes, and attached tactics in numbered order.

- “Season” offers “All seasons” and any season names entered in saved sessions. “Show completed” includes completed sessions in the list.
- The plus icon, labeled “Plan training”, opens the new-session form. The empty state also has a visible “Plan training” button.
- The circle icon, labeled “Complete training”, marks a session complete. A completed session has a checked circle labeled “Mark incomplete”, which reverses that change.
- The pencil icon, labeled “Edit training”, opens the existing session. Swipe a session to reveal “Delete”, which removes it directly.
- Tap an attached tactic’s numbered row to open that tactic on “Board” at frame 1.

### “Plan training” and “Edit training”

The “Session” section contains “Training title”, “Date & time”, “Duration”, “Season name”, and “Session notes”. A new session starts about 24 hours ahead with “Duration: 60 min”. The duration stepper changes it in five-minute increments from 15 to 240 minutes.

- “Weekly sessions: 1” appears when creating a session. Its stepper allows 1 to 12 sessions, one week apart, with the same tactics. The footer says “Create a weekly plan with the same tactics. Each session can be edited separately.”
- “Tactics · tap in session order” lists saved tactics by name. Tap to attach a tactic or tap it again to remove it. Selected tactics display their position in the session.
- “Session order” appears after a tactic is attached. The up-arrow control labeled “Move up” moves an attached tactic one place earlier. It is available from the second row onward.
- “Cancel” closes the form and discards changes. “Save” creates or updates the session and returns to “Training”.

### “Team & settings”

- “Team library” says “Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again.” “Share a copy” opens the system share sheet for the current tactic. “Open a shared file” opens the system file picker and selects the imported tactic for the next visit to “Board”. The settings tab stays open.
- “Notifications” initially offers “Enable training reminders”. After permission is granted, “Training reminders” is an on/off switch. “Open system settings” opens the app’s iOS settings.
- “Privacy” repeats “Choose a file to open, or send a copy directly to someone. Changes stay on this device until you share again.” It also says “No camera, microphone, location, health or calendar access is needed.”
- “Widgets” links to “Widget previews” and says “Add Soach Board widgets to your Home Screen or Lock Screen. They use the last saved local board and training plan, with no network requests.”
- “Version” displays “1.2.6 (162)”. The footer says “Free. Offline. Built for the touchline.”

### “Widget previews”

The screen says “Widgets use your saved local data.” It shows four previews. The navigation back control returns to “Team & settings”. Installation happens through the system’s widget picker, where the widget is called “Soach Board” and described as “Your latest tactic and training plan, saved on this device.”

- “Small” shows “Latest tactic” with the most recently revised tactic’s first frame and name. Tapping the installed widget opens that tactic on “Board”.
- “Medium” shows “Next training” with the next incomplete session’s name, time, and duration. Its board thumbnail uses the first attached tactic or falls back to the latest tactic.
- “Large” shows “The week ahead” with up to three upcoming incomplete sessions in the next seven days, and “Tactic library” with up to three recently revised tactics.
- “Lock Screen” previews the rectangular widget, which shows “Training tomorrow” with the earliest incomplete session’s name and time, or “No training tomorrow” with “Open your training plan”. The installed widget also has inline and circular formats. The inline version shows the status and, when applicable, the time. The circular version shows the time or “—”.
- Tapping an installed medium, large, or Lock Screen widget opens “Training”.

## Features

- “Tactical board” layouts for “Football”, “Futsal”, and “Basketball”.
- “Player”, “Opponent”, “Ball”, and “Cone” markers, with drag movement, directional nudges, and editable player and opponent numbers.
- “Pass”, “Run”, and “Zone” drawings, plus “Erase”, “Clear frame”, “Undo”, and “Redo”.
- “Play sequence” with up to 24 frames, frame thumbnails, and reduced-motion “Step preview”.
- “Full screen” editing, “Tactic details”, and “Coaching notes”.
- “Saved tactics” with name and notes search, sport filtering, duplication, and deletion.
- Six editable “Exercise starters”.
- “Export PDF”, “Export tactic file”, “Import tactic file”, “Share a copy”, and “Open a shared file”.
- “Training” sessions with dates, durations, seasons, notes, ordered tactics, completion status, and up to 12 “Weekly sessions” per new plan.
- Optional “Training reminders” and Home Screen and Lock Screen widgets.

## Behaviours that can look like bugs

- A new “Untitled tactic” starts with one blank frame. “Play sequence” and “Delete frame” are disabled until there are at least two frames. Use “Add frame” to create a second. “Add frame” is disabled at 24 frames. Delete a frame to make room.
- A frame accepts up to 80 markers and 80 drawings. At the limit, a placement or drawing gesture adds nothing. Use “Erase” or “Clear frame” to make room. Field editing is paused during playback. Tap “Pause” or select a frame to edit again.
- “Undo” and “Redo” are disabled when their respective histories are empty. Opening a tactic clears both histories. A new edit after an undo clears the redo history. Up to 40 undo steps are retained during the current editing session.
- “Play sequence” always starts from frame 1, including after “Pause”. Playback runs through the sequence once and leaves the final frame selected.
- “Save” in “Tactic details” or the training form requires a name containing a non-whitespace character. Enter a “Tactic name” or “Training title” to continue. A session can be saved without attached tactics.
- A read-only team copy, if already present on the device, is marked “Team copy” in “Library” and “Team copy · duplicate to edit” on “Board”. The normal file import creates an editable local copy. For a read-only copy, use “Duplicate” from the board menu to edit. The board may also show “Duplicate to edit”, which is disabled while a marker is selected.
- “No matching tactics” appears with “Create a tactic or choose a built-in exercise below.” Clear “Find a tactic”, choose “All sports”, use “New tactic”, or tap an available starter. Tapping a starter again creates another saved tactic. Deleting the last saved tactic creates a blank “Untitled tactic”.
- “Your next training starts here” appears with “Add a session, attach tactics and repeat it across your season.” It also appears when filters hide all sessions. Tap “Plan training” to add a session, choose “All seasons”, or turn on “Show completed”. A session marked with “Complete training” disappears by default. Turn on “Show completed” to find it and use “Mark incomplete”.
- “Session order” appears only after a tactic is attached. The first row has no “Move up” control. “Weekly sessions” is available when creating a plan. Once created, the sessions are edited separately.
- Widgets may show “No upcoming training”, “Open your training plan”, or “No training tomorrow” until an eligible session is saved. When local board data is unavailable, the widget may show “Open Soach Board” and “Save a tactic to see it here.”
- App alerts are titled “Soach Board” and dismissed with “OK”. For an invalid import, the message is “This file is not a valid Soach Board tactic.” Choose a file exported as a tactic by the app. Files at or above 2,000,000 bytes are rejected. When a file was selected through “Library”, the app returns to “Board” even if validation fails, and the prior tactic stays selected.
- Reminder denial shows “Notifications are off. You can still use your training plan. Enable alerts in Settings.” Use “Open system settings” to allow notifications. If authorization fails with an error, the alert says “Notifications are unavailable. Your training plan is saved.”
- A save failure shows “Could not save. Keep the app open and free some device storage.” A recovery on launch shows “The saved file could not be read. A recovery copy was used when available.” PDF export failure shows “Could not export this tactic.” A tactic-file export error can display an iOS-provided message.

## Starter content and resume

A clean install saves one editable, three-frame football tactic, “Build from the back”. There are no seeded training sessions. “Exercise starters” offers the following three-frame templates, each with a coaching note.

| Sport | Starter | Coaching note |
|---|---|---|
| “Football” | “Build from the back” | “Draw the press, then find the free player. Keep the supporting angles open.” |
| “Football” | “Wide overload” | “Move the ball wide. Create a spare player near the touchline.” |
| “Football” | “Press and recover” | “Close the passing lane together. Recover into shape when the ball moves.” |
| “Futsal” | “Rotation triangle” | “Pass, follow and rotate. Keep one passing option on each side.” |
| “Basketball” | “Give and go” | “Pass to a teammate, cut into space, then receive the return pass.” |
| “Basketball” | “Screen and cut” | “Set a screen, change direction and cut toward the basket.” |

Board edits save automatically after each completed edit. The last selected tactic reopens at frame 1 after a cold launch. The selected frame, playback position, and undo history reset. “Tactic details” and training forms require “Save”. Unsubmitted form edits cannot be resumed after dismissal or relaunch.

## Permissions

The only permission prompt is for notifications. It appears when the user first taps “Enable training reminders” in “Team & settings”. iOS supplies the prompt text. There is no app-defined usage-description string.

With reminders enabled, the app schedules alerts for future incomplete sessions, normally one day before. If the session is less than a day away, it uses one hour before when that time is still in the future. An alert is titled “Training tomorrow” or “Training soon” and displays the session title. The app schedules reminders for up to the next 50 future incomplete sessions. Turning off “Training reminders” cancels pending reminders.

## Absent

- Login and app accounts.
- In-app purchases and subscriptions.
- Ads.
- Analytics.
- Account deletion flow.
- App Tracking Transparency prompt.
- A public feed or in-app posting. User-generated content does exist as local tactics, coaching notes, training sessions, and session notes that users can choose to share.

## Data and support

Tactics, training plans, reminder preferences, and widget data stay on the device. The app works offline. Sharing sends a copy through the destination the user chooses in the system share sheet. Imports become independent local copies, with no live team syncing or invitations. There is no on-screen “Contact” or “Support” control.

## Scanning and health

None.

## Platform

iPhone and iPad, with a minimum of iOS or iPadOS 17.4. Both support portrait and landscape in either direction. iPad also supports upside-down portrait. The app uses a dark appearance and places the board beside its editing controls on sufficiently wide landscape layouts.

There is no region gate or region-specific feature flow. Dates and times follow system formatting. The app localizes its interface in English, German, Spanish, Italian, Brazilian Portuguese, and Greek. The labels quoted here use the English interface.

## Category

Sports
