//
//  ProjectTests.swift
//  MyProjectTests
//
//  Created by Alex Liou on 6/17/22.
//

//
//  ProjectTests.swift
//  MyProjectTests
//
//  Created by Alex Liou on 6/16/22.
//

import XCTest
import CoreData
@testable import MyProject

class ProjectTests: MyProjectTests {
    /// Create 10 projects with 10 items in each, then check if we have 10 projects and 100 items in Core Data storage.
    func testCreatingProjectsAndItems() {
        let targetCount = 10

        for _ in 0..<targetCount {
            let project = Project(context: managedObjectContext)

            for _ in 0..<targetCount {
                let item = Item(context: managedObjectContext)
                item.project = project
            }
        }

        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), targetCount)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), targetCount * targetCount)
    }

    /// Tests if our cascade delete system is working.
    func testDeletingProjectCascadeDeletesItems() throws {
        try dataController.createSampleData()

        let request = NSFetchRequest<Project>(entityName: "Project")
        let projects = try managedObjectContext.fetch(request)

        dataController.delete(projects[0])
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 4)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 40)
    }

}
