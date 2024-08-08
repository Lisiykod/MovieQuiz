//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Olga Trofimova on 08.08.2024.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    // тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    // тест на взятие элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNil(value)
    }
}
