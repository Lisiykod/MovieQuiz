//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 10.08.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    // количество выводимых вопросов
    let questionsAmount: Int = 10
    // переменная с индексом текущего вопроса
    private var currentQuestionIndex: Int = 0
    
    // метод для конвертации вопросов во вью модель для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // методы для изменения индекса текущего вопроса
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
