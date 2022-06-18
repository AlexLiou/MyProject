//
//  AssetTests.swift
//  MyProjectTests
//
//  Created by Alex Liou on 6/16/22.
//

import XCTest
@testable import MyProject
/*
 shortcut Ctrl+Opt+Cmd+G to run only the previous test.
 */
class AssetTests: XCTestCase {


    /// Checks if our asset catalog contains all the colors our code expects. Uses UIColor as it is an optional
    /// and we can check for nil. If we use SwiftUI Color, then if the color doesn't exist, we'll get a silent log in debug.
    func testColorsExist() {
        for color in Project.colors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }

    /// Checks whether the Award.allAwards property is empty or not as an empty JSON will create hell when we attempt to change
    /// it or the Award structure.
    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}
