//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 29.07.2024.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    // клиент чтобы создавать запросы к серверу
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // Если мы не смоги преобразовать строку в URL, то приложение упадет с ошибкой
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_kiwxbi4y") else {
            preconditionFailure("Unable to construct mostPopularMovies")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) {result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
