//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 27.07.2024.
//

import Foundation

// Отвечает за загрузку данных по URL
struct NetworkClient {
    private enum NetworError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        // создаем запрос
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // проверяем, пришла ли ошибка
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // проверяем, что нам пришел успешный код ответа
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworError.codeError))
                return
            }
            
            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}
    
