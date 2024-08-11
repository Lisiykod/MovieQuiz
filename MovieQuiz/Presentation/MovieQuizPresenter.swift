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
    var correctAnswers: Int = 0
    // переменная для отображения вопросов
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService? = StatisticService()
    weak var viewController: MovieQuizViewController?
    
    // переменная с индексом текущего вопроса
    private var currentQuestionIndex: Int = 0
    
    // MARK: - Public Methods
    // методы для определения правильного ответа
    func yesButtonClicked() {
       didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // метод для конвертации вопросов во вью модель для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // метод, чтобы отдать новый вопрос квиза
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        
    }
    
    // метод, который показывает или следующий вопрос, или результат квиза
    func showNextQuestionOrResult() {
        if self.isLastQuestion() {
            // идем в состояние "результат квиза"
            var text = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)\n"
            if let statisticService = statisticService {
                // сохраняем результаты
                statisticService.store(correct: correctAnswers, total: self.questionsAmount)
                text += """
                        Количество сыгранных квизов: \(statisticService.gamesCount)
                        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                       """
            }
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            // идем в состояние "следующий вопрос"
            questionFactory?.requestNextQuestion()
        }
    }
    
    // методы для изменения индекса текущего вопроса
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // метод для подсчета правильного ответа
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    //MARK: - Privates Methods
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
