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
    var localManager : PLocalImageManager!
    
    override func setUp() {
        super.setUp()
        localManager = PLocalImageManager(fileManager: PTestFileManager(),
                                          userDefaults: PDocumentDirectoryTestUserDefaults.sharedInstance)
    }
    
    override func tearDown() {
        super.tearDown()
        localManager = nil
    }
    func testFreshLoadImagesFromDocumentDirectoryPath() {
        let expectations =
            expectation(description:
                """
                   Fresh Image load into document directory
                   from local bundle and runs the callback closure
                """)
        localManager.loadImages { (images) in
            XCTAssert(images.count > 0)
            expectations.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
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
        localManager.loadImages { (images) in
            XCTAssert(images.count > 0)
            expectations.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
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
        localManager.refreshImage(callBack: { (images) in
            XCTAssert(images.count > 0)
            expectations.fulfill()
        })
        waitForExpectations(timeout: 5) { error in
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
        localManager.refreshImage { [unowned self](images) in
            let fileManager = PFileManager()
            let filePath =
                fileManager.appendFileNameWithPath(fileManager.resourcePath()!, fileName: "a.jpeg")
            let image = UIImage(contentsOfFile: filePath)
            self.localManager.addImage(image: image!) { (image) in
                XCTAssertNotNil(image)
                expectations.fulfill()
            }
        }
        waitForExpectations(timeout: 5) { error in
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
        localManager.refreshImage { [unowned self](images) in
            if images.count > 0 {
                self.localManager.deleteImage(image: images[0]) {
                    XCTAssert(true)
                    expectations.fulfill()
                }
            } else {
                XCTAssert(false)
                expectations.fulfill()
            }
        }
        waitForExpectations(timeout: 5) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
}

class PImageFetchControllerTest : XCTestCase {
    var imageFetchController : PImageFetchController!
    var coreDataStack :CoreDataStack!
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack(modelName: "Photoviewer")
        imageFetchController = PImageFetchController(managedObjectContext:self.coreDataStack.managedContext,
                                                     delegate:nil,
                                                     fileManager:PTestFileManager(),
                                                     userDefaults:PTestCoreDataUserDefaults.sharedInstance,
                                                     cacheName:"PhTestImageCache")
    }
    
    override func tearDown() {
        super.tearDown()
        imageFetchController = nil
        coreDataStack = nil
    }

    func testDeleteAllImages() {
        let expectations =
            expectation(description:
                """
                   Delete all image from CoreData
                """)
        imageFetchController.deleteAllImages {
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 5)
        XCTAssert(true)
    }

    func testCopyImageFromLocalBundleToCoreData() {
        let expectations =
            expectation(description:
                """
                   Copy image from local bundle to CoreData
                """)
        var imageCount = 0
        PTestCoreDataUserDefaults.sharedInstance.resetLoadedImageFromLocalBundleKey()
        imageFetchController.copyImagesFromLocalBundle { (count) in
                imageCount = count
                expectations.fulfill()
        }
        wait(for: [expectations], timeout: 5)
        XCTAssertEqual(imageCount,2)
    }
    
    func testLoadImagesFromCoreData() {
        let expectations =
            expectation(description:
                """
                   Load images from CoreData
                """)
        var rowCount = 0
        imageFetchController.preformFetch { [unowned self](success) in
            rowCount = self.imageFetchController.numberOfRowsInSection(section: 0)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 5)
        XCTAssertEqual(rowCount,2)
    }
    
    func testPerformFilterWithFavourite()  {
        let expectations =
            expectation(description:
                """
                   Perform filter images from CoreData
                """)
        var rowCount = 0
        imageFetchController.performFilter(isFavourite: true) { [unowned self] in
            self.imageFetchController.preformFetch { [unowned self](success) in
                rowCount = self.imageFetchController.numberOfRowsInSection(section: 0)
                expectations.fulfill()
            }
        }
        wait(for: [expectations], timeout: 5)
        XCTAssertEqual(rowCount,0)
    }
    
    func testPerformFilterWithOutFavourite()  {
        let expectations =
            expectation(description:
                """
                   Perform filter images from CoreData
                """)
        var rowCount = 0
        imageFetchController.performFilter(isFavourite: false) { [unowned self] in
            self.imageFetchController.preformFetch { [unowned self](success) in
                rowCount = self.imageFetchController.numberOfRowsInSection(section: 0)
                expectations.fulfill()
            }
        }
        wait(for: [expectations], timeout: 5)
        XCTAssertEqual(rowCount,2)
    }
    
//    func testDeleteImageFromList() {
//        let expectations =
//            expectation(description:
//                """
//                   Perform filter images from CoreData
//                """)
//        var rowCount = 0
//            self.imageFetchController.preformFetch { [unowned self](success) in
//                rowCount = self.imageFetchController.numberOfRowsInSection(section: 0)
//                expectations.fulfill()
//                self.imageFetchController.deleteObjectAtIndexPath(IndexPath.init(row: 0, section: 0)) { (result) in
//                }
//            }
//        wait(for: [expectations], timeout: 5)
//        XCTAssertEqual(rowCount,1)
//    }
}

class SetUpAndTearDownExampleTestCase: XCTestCase {
    var nameTest: String!
    
    override class func setUp() { // 1.
        super.setUp()
        // This is the setUp() class method.
        // It is called before the first test method begins.
        // Set up any overall initial state here.
    }
    
    override func setUp() { // 2.
        super.setUp()
        self.nameTest = "instance setup"
        // This is the setUp() instance method.
        // It is called before each test method begins.
        // Set up any per-test state here.
    }
    
    func testMethod1() { // 3.
        
        // This is the first test method.
        // Your testing code goes here.
        addTeardownBlock { // 4.
            // Called when testMethod1() ends.
        }
    }
    
    func testMethod2() { // 5.
        // This is the second test method.
        // Your testing code goes here.
        addTeardownBlock { // 6.
            // Called when testMethod2() ends.
        }
        addTeardownBlock { // 7.
            // Called when testMethod2() ends.
        }
    }
    
    override func tearDown() { // 8.
        // This is the tearDown() instance method.
        // It is called after each test method completes.
        // Perform any per-test cleanup here.
        super.tearDown()
    }
    
    override class func tearDown() { // 9.
        // This is the tearDown() class method.
        // It is called after all test methods complete.
        // Perform any overall cleanup here.
        super.tearDown()
    }
    
}
