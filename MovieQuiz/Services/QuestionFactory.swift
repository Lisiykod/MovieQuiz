//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 12.07.2024.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    
    // переменная, чтобы не дублировать вопрос
    private static let questionText: String = "Рейтинг этого фильма больше чем 6?"
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: questionText, correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: questionText, correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: questionText , correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: questionText, correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: questionText, correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: questionText, correctAnswer: true),
        QuizQuestion(image: "Old", text: questionText, correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: questionText, correctAnswer: false),
        QuizQuestion(image: "Tesla", text: questionText, correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: questionText, correctAnswer: false)
    ]
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
}
