//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Александр Дудченко on 05.11.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        
        app.terminate()
        app = nil
    }
    func testYesButton() {
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        
        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        
        XCTAssertFalse(firstPoster == secondPoster) // проверяем, что постеры разные
    }
}

