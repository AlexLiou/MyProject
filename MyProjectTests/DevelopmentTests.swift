//
//  DevelopmentTests.swift
//  MyProjectTests
//
//  Created by Alex Liou on 6/17/22.
//

import XCTest
import CoreData
@testable import MyProject

/*
 WARNING: When Xcode runs our test suite, it creates one instance of the XCTestCase class
 for each of our tests, then runs it back in a shared instance of the app. This is efficient to run
 , but comes with an important proviso: if you use a singleton like DataController.preview, that gets
 shared everywhere in all your tests.
 As a result, we need to be careful how we use them: if you modify the preview then attempt to run
 tests against specific parts of its state, you will hit problems. Write tests for any example
 objects you use in your previews, but don't try to make assertions about the preview data
 controller itself.
 */
class DevelopmentTests: MyProjectTests {

    /// Tests to make sure our sample code loads correctly.
    func testSampleDataCreationWorks() throws {
        try dataController.createSampleData()

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 5, "There should be 5 sample projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 50, "There should be 50 sample items.")
    }

    func testDeleteAllClearsEverything() throws {
        try dataController.createSampleData()
        dataController.deleteAll()

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 0, "There should be 0 sample projects.")
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 0, "There should be 0 sample items.")
    }

    /// Tests if our example project is closed by default
    func testExampleProjectIsClosed() {
        let project = Project.example
        XCTAssertTrue(project.closed, "The example project should be closed.")
    }

    /// Tests if example item is high priority by default.
    func testExampleItemIsHighPriority() {
        let item = Item.example
        XCTAssertEqual(item.priority, 3, "The example item should be high priority")
    }
}
