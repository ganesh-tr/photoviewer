//
//  PhotoviewerUITests.swift
//  PhotoviewerUITests
//
//  Created by Ganesh TR on 11/05/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import XCTest

class PhotoviewerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testExample() throws {
        let imageListNavigationBar = app.navigationBars["Image List"]
        let editElement = imageListNavigationBar.buttons["Edit"]
        editElement.tap()
        let doneElement = imageListNavigationBar.buttons["Done"]
        XCTAssertTrue(doneElement.exists )
        doneElement.tap()
    }
    
    func testFilterButton() {
        let filterButton = app.navigationBars["Image List"].buttons["Filter Image"]
        filterButton.tap()
        let filterSheet = app.sheets["Filter Image"]
        XCTAssertTrue(filterSheet.exists )
        let elementsQuery = filterSheet.scrollViews.otherElements
        let favouriteElement = elementsQuery.buttons["Favourite"]
        XCTAssertTrue(favouriteElement.exists )
        favouriteElement.tap()
        filterButton.tap()
        let removeFilterElement = elementsQuery.buttons["Remove Filter"]
        XCTAssertTrue(removeFilterElement.exists )
        removeFilterElement.tap()
    }
}
