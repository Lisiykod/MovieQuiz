//
//  MoviesLoaderTest.swift
//  MovieQuizTests
//
//  Created by Olga Trofimova on 08.08.2024.
//

import XCTest
@testable import MovieQuiz

class MoviesLoaderTest: XCTestCase {
    
    struct StubNetetworkClient: NetworkRouting {
        
        // Тестовая ошибка
        enum TestError: Error {
            case test
        }
        
        // Параметр для эмуляции либо ошибки сети, либо успешного ответа
        let emulateError: Bool
        
        func fetch(url: URL, handler: @escaping (Result<Data, any Error>) -> Void) {
            if emulateError {
                handler(.failure(TestError.test))
            } else {
                handler(.success(expectedResponse))
            }
        }
        
        private var expectedResponse: Data {
                    """
                    {
                       "errorMessage" : "",
                       "items" : [
                          {
                             "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                             "fullTitle" : "Prey (2022)",
                             "id" : "tt11866324",
                             "imDbRating" : "7.2",
                             "imDbRatingCount" : "93332",
                             "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                             "rank" : "1",
                             "rankUpDown" : "+23",
                             "title" : "Prey",
                             "year" : "2022"
                          },
                          {
                             "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                             "fullTitle" : "The Gray Man (2022)",
                             "id" : "tt1649418",
                             "imDbRating" : "6.5",
                             "imDbRatingCount" : "132890",
                             "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                             "rank" : "2",
                             "rankUpDown" : "-1",
                             "title" : "The Gray Man",
                             "year" : "2022"
                          }
                        ]
                      }
                    """.data(using: .utf8) ?? Data()
        }
        
    }
    
    func testSuccessLoading() throws {
        // Given
        // говорим, что хотим эмулировать успешную загрузку данных
        let stubNetworkClient = StubNetetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // добавляем ожидание, так как функция загрузки фильмов асинхронная
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                // сравниваем данные с тем, что мы предполагали
                expectation.fulfill()
            case .failure(_):
                // мы не ожидаем, что пришла ошибка
                // если она появится, то надо будет провалить тест:
                XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        // говорим, что хотим эмулировать ошибку
        let stubNetworkClient = StubNetetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // добавляем ожидание, так как функция загрузки фильмов асинхронная
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(_):
                XCTFail("Unexpected failure")
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
        
    }
}
