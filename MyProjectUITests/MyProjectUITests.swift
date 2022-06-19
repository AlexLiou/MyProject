//
//  MyProjectUITests.swift
//  MyProjectUITests
//
//  Created by Alex Liou on 6/17/22.
//

import XCTest

class MyProjectUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testAppHas4Tabs() throws {
        // UI tests must launch the application that they test.

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")
    }

    func testOpenTabsAddsProjects() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

        for tapCount in 1...5 {
            app.buttons["Add Project"].tap()
            XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) row(s) in the list.")
        }
    }

    func testAddingItemInsertsRows() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")

        app.buttons["Add New Item"].tap()
        XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
    }

    func testEditingProjectUpdatesCorrectly() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows intially.")

        app.buttons["Add Project"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")

        print(app.keys)
        app.buttons["Compose"].tap()
        app.textFields["Project name"].tap()

        /*
         XCTest actually provides a typeText() method that lets us insert free text strings,
         but honestly it’s pretty buggy – often it will only type a handful of the characters you want.
         The only guaranteed way to accurately type is to press individual keys manually,
         including switching between alphabetic and numeric keyboards by pressing what’s
         called the “more” button on the keyboard.
         */
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Open Projects"].tap()
//        print(app.textFields)
        XCTAssertTrue(app.staticTexts["New Project 2"].exists, "The new project name should be visible in the list.")
    }

    func testEditingItemUpdatesCorrectly() {
        // Go to Open Projects and add one project and one item.
        testAddingItemInsertsRows()

        app.buttons["New Item"].tap()

        app.textFields["Item name"].tap()
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()

        app.buttons["Open Projects"].tap()

        XCTAssertTrue(app.buttons["New Item 2"].exists, "The new item name should be visible in the list.")
    }

    func testAllAwardsShowLockedAlert() {
        app.buttons["Awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }

    /*
     1. Test that opening and closing projects moves them between tabs.
     2. Test that unlocking awards shows a differet alert.
     3. Test that swipe to delete works (use swipeLeft() rather than tap() to review it's
     delete button, then call tap() on that delete button).
     */
}
