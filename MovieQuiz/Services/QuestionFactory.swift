//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 12.07.2024.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    // переменная, чтобы не дублировать вопрос
//    private static let questionText: String = "Рейтинг этого фильма больше чем 6?"

    // переменная в которой будем хранить фильмы
    private var movies: [MostPopularMovie] = []
    
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(image: "The Godfather", text: questionText, correctAnswer: true),
//        QuizQuestion(image: "The Dark Knight", text: questionText, correctAnswer: true),
//        QuizQuestion(image: "Kill Bill", text: questionText , correctAnswer: true),
//        QuizQuestion(image: "The Avengers", text: questionText, correctAnswer: true),
//        QuizQuestion(image: "Deadpool", text: questionText, correctAnswer: true),
//        QuizQuestion(image: "The Green Knight", text: questionText, correctAnswer: true),
//        QuizQuestion(image: "Old", text: questionText, correctAnswer: false),
//        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: questionText, correctAnswer: false),
//        QuizQuestion(image: "Tesla", text: questionText, correctAnswer: false),
//        QuizQuestion(image: "Vivarium", text: questionText, correctAnswer: false)
//    ]
    
    
    init(moviesLoader: MoviesLoading) {
        self.moviesLoader = moviesLoader
    }
    
    // метод для инициирования загрузки данных
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    // сохраняем фильм
                    self.movies = mostPopularMovies.items
                    // сообщаем, что данные загрузились
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            // по умолчанию данные будут пустые
            var imageData = Data()
            
            // создаем картинку из url
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let raiting = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше 7?"
            let correctAnswer = raiting > 7
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }

    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
     
}
