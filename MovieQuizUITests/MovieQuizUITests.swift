 //
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Александр Дудченко on 11.11.2024.
//

import XCTest
@testable import MovieQuiz

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
    
    @MainActor
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertFalse(firstPosterData == secondPosterData)
    }
    
    func testIndex() {
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["No"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertFalse(firstPosterData == secondPosterData)
    }
    func testFinalAlertAppears() {
        for _ in 1...10 {
            sleep(3)
            app.buttons["No"].tap()
        }
        
        sleep(3)
        
        let alert = app.alerts["Game results"]
        XCTAssertTrue(alert.exists, "Game results alert does not appear.")
        
        XCTAssertEqual(alert.label, "Этот раунд окончен!", "Alert title does not match.")
        
        let replayButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(replayButton.exists, "Replay button does not exist.")
    }
    func testAlertDismissAndCounterReset() {
        for _ in 1...10 {
            sleep(3)
            app.buttons["No"].tap()
        }
        
        sleep(3)
        let alert = app.alerts["Game results"]
        XCTAssertTrue(alert.exists, "Game results alert does not appear.")
        let replayButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(replayButton.exists, "Replay button does not exist.")
        replayButton.tap()
        
        sleep(3)
        XCTAssertFalse(alert.exists, "Alert should not exist after dismissing.")
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.exists, "Index label does not exist after dismissing alert.")
        XCTAssertEqual(indexLabel.label, "1/10", "Index label should be reset to 1/10.")
    }
}
