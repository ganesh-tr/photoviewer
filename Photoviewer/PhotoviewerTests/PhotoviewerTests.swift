//
//  PhotoviewerTests.swift
//  PhotoviewerTests
//
//  Created by Ganesh TR on 10/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import XCTest
@testable import Photoviewer
class PhotoviewerTests: XCTestCase {
    
}

class PExtensionStringTests: XCTestCase {
    
// Test case for PExtensionString class

    func testFileURL() {
        let nameExtension = "Application/Documents/image.jpeg".fileURL
        XCTAssertEqual(nameExtension,URL(fileURLWithPath:"Application/Documents/image.jpeg"))
    }
    
    func testPathExtension() {
        var nameExtension = "image.jpg".pathExtension
        XCTAssertEqual(nameExtension,"jpg")
        nameExtension = "image".pathExtension
        XCTAssertEqual(nameExtension,"")
    }
    
    func testLastPathComponent() {
       let path =
        "/Users/ganeshtr/Library/Developer/CoreSimulator/Devices/Application/Documents/image.jpeg"
        XCTAssertEqual(path.lastPathComponent, "image.jpeg")
    }
    
    func testCustomNameDateFormat() {
        let customDate = "2020-04-18_14_49_10"
        let customNameDateFormat = String.stringFrom(date:customDate.toDate()!)
        XCTAssertEqual(customNameDateFormat,customDate)
    }
    
    func testCustomImageName() {
        let customDate = "2020-04-18_14_49_10".toDate()!
        let customImageName = String.customImageName(date:customDate)
        XCTAssertEqual(customImageName,"2020-04-18_14_49_10.jpg")
    }
    
}
