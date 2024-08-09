//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Olga Trofimova on 08.08.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        // специальная настройка для тестов: если один тест не прошёл,
                // то следующие тесты запускаться не будут
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        // находим первоначальный постер
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
    
        // находим кнопку "Да" и нажимаем её
        app.buttons["Yes"].tap()
        
        sleep(3)
        
        // еще раз находим постер
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        // находим лейбл
        let indexLabel = app.staticTexts["Index"]
        
        // проверяем, что постеры разные
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        // проверяем, что при этом меняется лейбл
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        // находим первоначальный постер
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        // находим кнопку "Нет" и нажимаем её
        app.buttons["No"].tap()
        
        sleep(3)
        
        // еще раз находим постер
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        // находим лейбл
        let indexLabel = app.staticTexts["Index"]
        
        // проверяем, что постеры разные
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        // проверяем, что при этом меняется лейбл
        XCTAssertEqual(indexLabel.label, "2/10")
       
    }
    
    func testGameResultAlert() {
        sleep(2)
        
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game result"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
    }
    
    func testAlertDismiss() {
        sleep(2)
        
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Game result"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    

}
