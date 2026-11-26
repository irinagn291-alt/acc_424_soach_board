import XCTest
final class ZbJourney:XCTestCase {
 var app:XCUIApplication!
 override func setUpWithError()throws{continueAfterFailure=false;app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)","-AppleLocale","en_US"];app.launch()}
 func tab(_ title:String){let t=app.tabBars.buttons[title];if t.exists{t.tap()}else{app.buttons[title].firstMatch.tap()}}
 func reveal(_ id:String)->XCUIElement{let b=app.buttons[id];for _ in 0..<5{let groups=app.scrollViews.containing(.button,identifier:id);if groups.count>0{let g=groups.element(boundBy:groups.count-1);if b.isHittable && g.frame.insetBy(dx:-1,dy:-1).contains(b.frame){break};g.swipeLeft()}else{if b.isHittable{break};scrollDown()}};return b}
 func scrollDown(){app.coordinate(withNormalizedOffset:CGVector(dx:0.985,dy:0.78)).press(forDuration:0.1,thenDragTo:app.coordinate(withNormalizedOffset:CGVector(dx:0.985,dy:0.3)))}
 func counts()->[Int]{((app.descendants(matching:.any)["pitch"].firstMatch.value as? String) ?? "").components(separatedBy:CharacterSet.decimalDigits.inverted).compactMap{Int($0)}}

 func shot(_ title:String){let a=XCTAttachment(screenshot:app.screenshot());a.name=title;a.lifetime = .keepAlways;add(a)}
 func test01EditAndPersist()throws{
  XCTAssertTrue(app.descendants(matching:.any)["pitch"].firstMatch.waitForExistence(timeout:15));shot("01-board")
  app.buttons["boardMenu"].tap();app.buttons["Tactic details"].tap()
  let title=app.textFields["tacticName"];XCTAssertTrue(title.waitForExistence(timeout:5));title.tap();title.press(forDuration:1.1);if app.menuItems["Select All"].exists{app.menuItems["Select All"].tap()};title.typeText(String(repeating:XCUIKeyboardKey.delete.rawValue,count:80)+"Touchline pattern")
  app.buttons["saveDetails"].tap();XCTAssertTrue(app.staticTexts["Touchline pattern"].waitForExistence(timeout:4))
  let original=counts();XCTAssertEqual(original.count,2)
  app.buttons["tool-home"].tap();let board=app.descendants(matching:.any)["pitch"].firstMatch;board.coordinate(withNormalizedOffset:CGVector(dx:0.55,dy:0.5)).tap()
  XCTAssertEqual(counts().first,original.first.map{$0+1});let prior=counts()
  reveal("tool-arrow").tap();XCTAssertTrue(app.buttons["tool-arrow"].isSelected);board.coordinate(withNormalizedOffset:CGVector(dx:0.4,dy:0.5)).press(forDuration:0.1,thenDragTo:board.coordinate(withNormalizedOffset:CGVector(dx:0.7,dy:0.3)))
  XCTAssertEqual(counts().first,prior.first);XCTAssertEqual(counts().last,prior.last.map{$0+1})
  let frames=app.descendants(matching:.any)["frameSummary"].firstMatch.label.components(separatedBy:CharacterSet.decimalDigits.inverted).compactMap{Int($0)}.last ?? 0;XCTAssertGreaterThan(frames,0)
  scrollDown();reveal("addFrame").tap();XCTAssertTrue(app.buttons["frame-\(frames)"].exists)
  app.buttons["playSequence"].tap();shot("02-sequence");app.buttons["playSequence"].tap()
  app.terminate();app.launch();XCTAssertTrue(app.staticTexts["Touchline pattern"].waitForExistence(timeout:10))
 }
 func test02Training()throws{
  tab("Training");app.buttons["newTraining"].tap()
  let f=app.textFields["trainingTitle"];XCTAssertTrue(f.waitForExistence(timeout:5));f.tap();f.typeText("Movement session")
  app.buttons["saveTraining"].tap();XCTAssertTrue(app.staticTexts["Movement session"].firstMatch.waitForExistence(timeout:5));shot("03-training")
  app.terminate();app.launch();tab("Training");XCTAssertTrue(app.staticTexts["Movement session"].firstMatch.waitForExistence(timeout:10))
 }
 func test03SportsLibraryAndOffline()throws{
  app.buttons["sportMenu"].tap();app.buttons.matching(NSPredicate(format:"label == %@ AND identifier != %@","Basketball","sportMenu")).firstMatch.tap();shot("04-basketball")
  tab("Library");app.swipeUp();shot("05-library")
  tab("Team & settings");app.buttons["syncTeam"].tap();XCTAssertTrue(app.staticTexts["cloudStatus"].waitForExistence(timeout:5));let message=app.staticTexts["cloudStatus"].label;XCTAssertTrue(message.contains("Sign in to iCloud") || message.contains("No connection") || message.contains("unavailable"));shot("06-offline-team")
 }
 func test04PDF()throws{
  app.buttons["boardMenu"].tap();app.buttons["Export PDF"].tap();XCTAssertTrue(app.buttons["Close"].waitForExistence(timeout:10) || app.otherElements["ActivityListView"].exists || app.buttons["Copy"].exists);shot("07-pdf-sharing")
 }
 func test05Widgets()throws{
  tab("Team & settings")
  let link=app.buttons["Widget previews"]
  for _ in 0..<6 {if link.isHittable{break};app.swipeUp()}
  XCTAssertTrue(link.exists);link.tap();XCTAssertTrue(app.staticTexts["Small"].waitForExistence(timeout:5));shot("08-widget-small-medium")
  app.swipeUp();shot("09-widget-large-lock")
 }
 func test06NotificationDenial()throws{
  tab("Team & settings");let enable=app.buttons["enableReminders"]
  for _ in 0..<4 {if enable.isHittable{break};app.swipeUp()}
  XCTAssertTrue(enable.exists);enable.tap()
  let spring=XCUIApplication(bundleIdentifier:"com.apple.springboard")
  let deny=spring.buttons.matching(NSPredicate(format:"label CONTAINS[c] %@", "Don")).firstMatch
  if deny.waitForExistence(timeout:4){deny.tap()}else{let b=app.alerts.buttons.matching(NSPredicate(format:"label CONTAINS[c] %@", "Don")).firstMatch;if b.exists{b.tap()}}
  let ok=app.alerts.buttons["OK"];if ok.waitForExistence(timeout:3){ok.tap()}
  shot("10-notification-denial");tab("Training");XCTAssertTrue(app.staticTexts["Movement session"].firstMatch.waitForExistence(timeout:5))
 }

 func test07LocalizedScreens()throws{
  let languages=[("en","en_US","Board","Training"),("de","de_DE","Tafel","Training"),("es","es_ES","Pizarra","Entrenamiento"),("it","it_IT","Lavagna","Allenamento"),("pt-BR","pt_BR","Quadro","Treinos"),("el","el_GR","Πίνακας","Προπόνηση")]
  for (l,region,board,training) in languages{
   app.terminate();app.launchArguments=["-AppleLanguages","(\(l))","-AppleLocale",region];app.launch()
   let open=XCUIApplication(bundleIdentifier:"com.apple.springboard").alerts.buttons["Open"];if open.exists{open.tap();app.activate()}
   tab(board);XCTAssertTrue(app.descendants(matching:.any)["pitch"].firstMatch.waitForExistence(timeout:10));shot("Board-"+l)
   tab(training);XCTAssertTrue(app.staticTexts["Movement session"].firstMatch.waitForExistence(timeout:5));shot("Training-"+l)
  }
 }

 func test08AllDrawingTools()throws{
  app.buttons["boardMenu"].tap();app.buttons["New tactic"].tap()
  let board=app.descendants(matching:.any)["pitch"].firstMatch
  XCTAssertEqual(counts(),[0,0])
  for (tool,x,y) in [("home",0.3,0.3),("away",0.65,0.65),("ball",0.5,0.5),("cone",0.2,0.7)]{
   reveal("tool-"+tool).tap();XCTAssertTrue(app.buttons["tool-"+tool].isSelected);board.coordinate(withNormalizedOffset:CGVector(dx:x,dy:y)).tap()
  }
  XCTAssertEqual(counts(),[4,0])
  reveal("tool-run").tap();board.coordinate(withNormalizedOffset:CGVector(dx:0.3,dy:0.3)).press(forDuration:0.1,thenDragTo:board.coordinate(withNormalizedOffset:CGVector(dx:0.5,dy:0.3)))
  reveal("tool-zone").tap();board.coordinate(withNormalizedOffset:CGVector(dx:0.6,dy:0.3)).press(forDuration:0.1,thenDragTo:board.coordinate(withNormalizedOffset:CGVector(dx:0.8,dy:0.55)))
  XCTAssertEqual(counts(),[4,2]);shot("11-all-drawing-tools")
  reveal("tool-erase").tap();board.coordinate(withNormalizedOffset:CGVector(dx:0.2,dy:0.7)).tap();XCTAssertEqual(counts(),[3,2])
  app.buttons["Undo"].tap();XCTAssertEqual(counts(),[4,2]);app.buttons["Redo"].tap();XCTAssertEqual(counts(),[3,2])
  tab("Library");app.buttons.matching(NSPredicate(format:"label CONTAINS %@","Touchline pattern")).firstMatch.tap();XCTAssertTrue(board.waitForExistence(timeout:5))
 }

}
