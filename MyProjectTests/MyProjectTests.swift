//
//  MyProjectTests.swift
//  MyProjectTests
//
//  Created by Alex Liou on 6/16/22.
//

import CoreData
import XCTest
@testable import MyProject

class MyProjectTests: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
