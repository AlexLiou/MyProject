//
//  ExtensionTests.swift
//  MyProjectTests
//
//  Created by Alex Liou on 6/17/22.
//

import XCTest
import SwiftUI
@testable import MyProject

class ExtensionTests: XCTestCase {

    /// Tests if our array is sorted upon using the identity key path (\.self)
    func testSequenceKeyPathSortingSelf() {
        let items = [1, 4, 3, 2, 5]
        let sortedItems = items.sorted(by: \.self)
        XCTAssertEqual(sortedItems, [1,2,3,4,5], "The sorted numbers must be ascending.")
    }

    /// Tests if our custom comparator function works properly.
    func testSequenceKeyPathSortingCustom() {
        struct Example: Equatable {
            let value: String
        }

        let example1 = Example(value: "a")
        let example2 = Example(value: "b")
        let example3 = Example(value: "c")
        let array = [example1, example2, example3]

        let sortedItems = array.sorted(by: \.value) {
            $0 > $1
        }

        XCTAssertEqual(sortedItems, [example3, example2, example1], "Reverse sorting should yield c, b, a.")
    }

    /// Tests our bundle function locate, loads, and decodes JSON data in one call.
    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode([Award].self, from: "Awards.json")
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a non-empty array.")
    }

    /// Tests our bundle function can decode a String in JSON
    func testBundleDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode(String.self, from: "DecodableString.json")
        XCTAssertEqual(data, "The rain in Spain falls mainly on the Spainards.", "The string must match the content of DecodableString.json.")
    }

    /// Test our bundle function can decode a dictionary properly.
    func testBundleDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode([String: Int].self, from: "DecodableDictionary.json")
        XCTAssertEqual(data.count, 3, "There should be three items decoded from DecodableDictionary.json.")
        XCTAssertEqual(data["One"], 1, "The dictionary should contain Int to String mappings.")
    }

    /// Tests the modified Binding instances so they trigger a method when changed.
    func testBindingOnChange() {
        // Given
        var onChangeFunctionRun = false

        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }

        var storedValue = ""

        let binding = Binding(
            get: { storedValue },
            set: { storedValue = $0 }
        )

        let changedBinding = binding.onChange(exampleFunctionToCall)
        // When
        changedBinding.wrappedValue = "Test"
        // Then
        XCTAssertTrue(onChangeFunctionRun, "The onChange() function was not run.")
    }


}
