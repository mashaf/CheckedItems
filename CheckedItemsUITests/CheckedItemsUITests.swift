//
//  CheckedItemsUITests.swift
//  CheckedItemsUITests
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//

import XCTest

@testable import CheckedItems

let firstItemName = "test item 1"
let secondItemName = "test item 2"

var application: XCUIApplication = XCUIApplication()
var textFieldItemName = application/*@START_MENU_TOKEN@*/.textFields["Item's name"]/*[[".scrollViews.textFields[\"Item's name\"]",".textFields[\"Item's name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
var textFieldBoxesNumber = application/*@START_MENU_TOKEN@*/.textFields["Boxes"]/*[[".scrollViews.textFields[\"Boxes\"]",".textFields[\"Boxes\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
var textFieldDailyAmount = application.textFields["Daily amount"]
var textFieldStartAmount = application/*@START_MENU_TOKEN@*/.textFields["Amount at the begining"]/*[[".scrollViews.textFields[\"Amount at the begining\"]",".textFields[\"Amount at the begining\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
var textFieldStartDate = application.textFields["Start date of consuming"]

class CheckedItemsUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        addItem(firstItemName, boxes: "2", amount: "10", takePhoto: true)
        addItem(secondItemName, boxes: "1", amount: "15", takePhoto: false)
        addItem(firstItemName, boxes: "1", amount: "10", takePhoto: false)
        editTheItem(secondItemName)
        extendTheItem(secondItemName)
        deleteItem(firstItemName)
        deleteItem(secondItemName)
        
    }
    
    private func addItem(_ itemName: String, boxes: String, amount: String, takePhoto: Bool) {
        
        application.navigationBars["Navigation Controller"].buttons["Add"].tap()
        
        textFieldItemName.tap()
        textFieldItemName.typeText(itemName)

        textFieldBoxesNumber.tap()
        application/*@START_MENU_TOKEN@*/.keys["Delete"]/*[[".keyboards.keys[\"Delete\"]",".keys[\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        textFieldBoxesNumber.typeText(boxes)
        
        textFieldDailyAmount.tap()
        application.keys["1"].tap()
        
        textFieldStartAmount.tap()
        textFieldStartAmount.typeText(amount)
        
        if takePhoto {
            application/*@START_MENU_TOKEN@*/.scrollViews.containing(.image, identifier: "camera").element/*[[".scrollViews.containing(.button, identifier:\"Save\").element",".scrollViews.containing(.textField, identifier:\"Start date of consuming\").element",".scrollViews.containing(.staticText, identifier:\"Start date of consuming:\").element",".scrollViews.containing(.textField, identifier:\"Amount at the begining\").element",".scrollViews.containing(.staticText, identifier:\"Amount at the begining:\").element",".scrollViews.containing(.textField, identifier:\"Daily amount\").element",".scrollViews.containing(.staticText, identifier:\"Daily amount:\").element",".scrollViews.containing(.textField, identifier:\"Boxes\").element",".scrollViews.containing(.textField, identifier:\"Item's name\").element",".scrollViews.containing(.staticText, identifier:\"Count of items:\").element",".scrollViews.containing(.staticText, identifier:\"Name of item:\").element",".scrollViews.containing(.image, identifier:\"camera\").element"],[[[-1,11],[-1,10],[-1,9],[-1,8],[-1,7],[-1,6],[-1,5],[-1,4],[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            application.scrollViews.children(matching: .button).element(boundBy: 0).tap()
            XCUIDevice.shared.orientation = .landscapeLeft
            application/*@START_MENU_TOKEN@*/.buttons["PhotoCapture"]/*[[".buttons[\"Take Picture\"]",".buttons[\"PhotoCapture\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            XCUIDevice.shared.orientation = .portrait
            application.buttons["Use Photo"].tap()
        }
        
        tapSaveButton()
        
        if application.sheets[itemName].exists {
            application.sheets[itemName].buttons["Yes"].tap()
        }
    }
    
    private func extendTheItem(_ itemName: String) {
        application.tables.staticTexts[itemName].swipeLeft()
        application.tables.buttons["Extend item"].tap()
        application.keys["1"].tap()
        application.keys["0"].tap()
        tapSaveButton()
    }
    
    private func editTheItem(_ itemName: String) {
        application.tables.staticTexts[itemName].tap()
        textFieldStartAmount.tap()
        application/*@START_MENU_TOKEN@*/.keys["Delete"]/*[[".keyboards.keys[\"Delete\"]",".keys[\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        application/*@START_MENU_TOKEN@*/.keys["Delete"]/*[[".keyboards.keys[\"Delete\"]",".keys[\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        textFieldStartAmount.typeText("18")
        
        tapSaveButton()
    }
    
    private func deleteItem(_ itemName: String) {
        application.tables.staticTexts[itemName].swipeLeft()
        application.tables.buttons["Delete"].tap()
    }
    
    private func tapSaveButton() {
        if application.keyboards.count > 0 {
            application/*@START_MENU_TOKEN@*/.staticTexts["Daily amount:"]/*[[".scrollViews.staticTexts[\"Daily amount:\"]",".staticTexts[\"Daily amount:\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        application/*@START_MENU_TOKEN@*/.buttons["Save"]/*[[".scrollViews.buttons[\"Save\"]",".buttons[\"Save\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
    
}
