//
//  PhotoviewerTests.swift
//  PhotoviewerTests
//
//  Created by Ganesh TR on 10/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import XCTest
@testable import Photoviewer

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

class PLocalImageManagerTest : XCTestCase {
    
    func testFreshLoadImagesFromDocumentDirectoryPath() {
        let expectations =
            expectation(description:
                """
                   Fresh Image load into document directory
                   from local bundle and runs the callback closure
                """)
        PLocalImageManager.shareInstance.loadImages { (images) in
            XCTAssert(images.count > 0)
            expectations.fulfill()
        }
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testLoadImagesFromDocumentDirectoryPath() {
        let expectations =
            expectation(description:
                """
                   Load images from document directory
                   from local bundle and runs the callback closure
                """)
        PLocalImageManager.shareInstance.loadImages { (images) in
            XCTAssert(images.count > 0)
            expectations.fulfill()
        }
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }

    func testRefreshImageLoadInDocumentDirectory() {
        let expectations =
            expectation(description:
                """
                   Refresh Image load in document directory
                   from local bundle and runs the callback closure
                """)
        PLocalImageManager.shareInstance.refreshImage(callBack: { (images) in
            XCTAssert(images.count > 0)
            expectations.fulfill()
        })
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testAddImageToDocumentDirectory(){
        let expectations =
            expectation(description:
                """
                   Add image from local document directory path
                """)
        PLocalImageManager.shareInstance.refreshImage { (images) in
            let filePath =
                PFileManager.shareInstance.appendFileNameWithPath(PFileManager.shareInstance.resourcePath()!, fileName: "1.jpeg")
            let image = UIImage(contentsOfFile: filePath)
            PLocalImageManager.shareInstance.addImage(image: image!) { (image) in
                XCTAssertNotNil(image)
                expectations.fulfill()
            }
        }
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func testDeleteImageFromDocumentDirectoryPath() {
    
        let expectations =
            expectation(description:
                """
                   Delete image from local document directory path
                """)
        PLocalImageManager.shareInstance.refreshImage { (images) in
            if images.count > 0 {
                PLocalImageManager.shareInstance.deleteImage(image: images[0]) {
                    XCTAssert(true)
                    expectations.fulfill()
                }
            } else {
                XCTAssert(false)
                expectations.fulfill()
            }
        }
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
}
