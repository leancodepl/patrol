//
//  SampleXCUITests.swift
//  SampleXCUITests
//
//  Created by Kalam Shah on 13/02/18.
//  Copyright © 2018 BrowserStack. All rights reserved.
//

import XCTest

class SampleXCUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAlert() {
        
        let app = XCUIApplication()
        
        //bring up the alert
        app.buttons["Alert"].tap()
        
        //verify that the alert has come
        XCTAssertEqual(app.alerts.element.label, "Alert")
        
        //dismiss the alert
        app.alerts.buttons["OK"].tap()
        
        //verify that the alert is dismissed
        XCTAssertEqual(app.alerts.count, 0)
    }
    
    func testText() {
        let app = XCUIApplication()
        
        //visit the text page
        app.buttons["Text"].tap()
        
        let enterText = "Hi Browserstack!!"
        //verify that the text field has come up
        XCTAssert(app.textFields["Enter a text"].exists)
        
        //write the text
        app.textFields["Enter a text"].tap()
        app.textFields["Enter a text"].typeText(enterText)
        app.typeText("\r")
        
        //verify that the text entered matches the text view
        XCTAssertEqual(app.staticTexts.element.label, enterText)
    }
}
