# Soach Board

Native, universal iPhone and iPad tactics editor. Open `ChalkOrbit.xcodeproj` and use the shared `ChalkOrbit` scheme. Deployment target: iOS/iPadOS 17.4. No external packages.

## Using the app

- **Board:** select a sport. Add players, opponents, a ball or cones by tapping. Drag to draw passes, runs and zones. Use Move to reposition markers; select a marker to change its number, nudge it with accessible controls or delete it. Erase removes the nearest figure or line. Undo and redo apply to the current tactic.
- **Sequence:** select a frame, duplicate it with +, move players, then play the sequence. Player identities remain stable across frames. Reduce Motion switches to step previews. Up to 24 frames and 80 markers/lines per frame.
- **Library:** open saved tactics, search, filter by sport, duplicate or remove a tactic, or start from six clearly labelled bundled exercises. A new install opens a usable exercise with no fictional scheduled training.
- **Training:** create sessions, attach tactics in coaching order, record duration, notes and season, and create up to 12 weekly sessions. Each repeat can be edited independently. Mark sessions complete and filter by season.
- **Export:** the Board menu exports a PDF containing every frame plus all coaching notes, or a portable JSON tactic. Import JSON using Files or the Library menu. These actions work offline.
- **Team:** explicitly publish the current tactic to a private CloudKit record and invite specific teammates using Apple's sharing sheet. Invited teammates receive read-only copies, which they can duplicate to edit locally. Publish again to update an owned tactic; sync to receive changes. Manage and revoke participants through the same sheet. Remove My iCloud Tactics deletes the owner's shared zone and revokes its invitations; local copies remain.
- **Reminders:** enabled only after explaining their purpose. Future sessions receive a local reminder one day before, or one hour before for short-notice plans. Shared updates are announced after a successful foreground sync. Permission denial leaves the planner usable.
- **Widgets:** small/latest tactic, medium/next training and its tactic, large/next seven days plus the library, and three Lock Screen families. All use the saved App Group snapshot with no network requests. Team & settings includes previews of the actual widget views and current local data.

EN, DE, ES, IT, PT-BR and EL are bundled. Tactic names and notes entered by the user remain user content when the system language changes.

## Builds and QA

`Workshop` is the debug configuration; `FieldRelease` is optimized and excludes debug symbols to keep machine paths out of the delivered archive. The source contains five production Swift files plus one UI-test file.

Use `Tools/check_models.py` for host-side checks of the actual shared Swift data model. `Tools/check_storage.py` exercises the actual archive code against isolated QA files, with widget services disabled. `Tools/verify_source.py` audits localization completeness, project identity, entitlements and the final archive. See `REPORT.md` for the completed results and artifact paths.

Simulator work must run through the factory helper. From this project directory:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
python3 ../../../../gf/genesis/simulator_pool.py TEMPLATE_UDID bash QA/run_device.sh phone
```

The foreground script uses only `$GF_SIMULATOR_UDID`, exports XCTest screenshots, PDF files and local/App Group data, and pauses for visual review for up to ten minutes. When `QA/<label>/awaiting-review` appears, inspect the evidence and test status, then create `QA/<label>/reviewed` to accept the run or `QA/<label>/retry` to rebuild and repeat after a correction. These are local QA control files, not user approval requests. After phone review the script shuts down its owned phone and performs iPad QA through a nested factory helper while retaining the same activity lease. Creating `QA/confirm-phone` before tablet review adds a final fresh-phone pass labelled `phone-confirmation`. The factory handles disposable device creation and disposal. No pre-existing device is erased or deleted.

## Signing and CloudKit deployment

No App Store submission or paid service was requested. Choose your own Apple signing team in Xcode and register these dedicated identifiers:

- App: `com.coachboard.app-c977830d8707`
- Widget extension: `com.coachboard.app-c977830d8707.glance`
- App Group: `group.com.coachboard.app-c977830d8707`
- CloudKit container: `iCloud.com.coachboard.app-c977830d8707`

The development schema is one custom zone, `ChalkTeam`, with `Tactic` records: `payload` (Bytes) and `title` (String). Shares are standard `CKShare` records. There is no public database query or custom server. Deploy this schema to production before any distribution build. Apple requires an active iCloud account for each share participant and limits a share to 100 participants; storage and service availability are governed by Apple. Missing iCloud, network errors and quota errors produce a local status message.

Apple references checked 15 November 2026: [CloudKit](https://developer.apple.com/icloud/cloudkit/), [shared records](https://developer.apple.com/documentation/cloudkit/shared-records), [CKShare](https://developer.apple.com/documentation/cloudkit/ckshare), [UICloudSharingController](https://developer.apple.com/documentation/uikit/uicloudsharingcontroller), [WidgetKit families](https://developer.apple.com/documentation/widgetkit/widgetfamily), [SwiftUI scene delegate support](https://developer.apple.com/documentation/swiftui/uiapplicationdelegateadaptor), [accepting share invitations](https://developer.apple.com/documentation/coredata/accepting-share-invitations-in-a-swiftui-app), [system sharing presentation](https://developer.apple.com/documentation/uikit/uiactivityviewcontroller).

## Technical decisions

The project has one application target, one mandatory WidgetKit extension target and a UI-test target. A WidgetKit extension is required by the SDK; a single application target cannot register system widgets. The individual brief explicitly excludes Live Activities for this editor, so no ActivityKit entitlement or activity is falsely declared. Push entitlement and `remote-notification` background mode are declared as required by the brief, while user alerts are local and no APNs sender is implemented or promised. There are no unused sensitive-permission declarations.

There is no developer account system, public content feed, tracking, advertising, purchase flow or third-party dependency. Optional private CloudKit invitations use Apple accounts and Apple's participant controls, including removal/revocation. Data is saved atomically on device with a previous-valid-file recovery copy. The app does not send training plans to the developer.
