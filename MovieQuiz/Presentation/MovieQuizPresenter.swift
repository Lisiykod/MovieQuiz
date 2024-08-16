//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 10.08.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // количество выводимых вопросов
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    // переменная для отображения вопросов
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    // переменная с индексом текущего вопроса
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Public Methods
    // методы для определения правильного ответа
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // методы для изменения индекса текущего вопроса
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        // сбрасывает все значения
        currentQuestionIndex = 0
        correctAnswers = 0
        // заново показываем первый вопрос
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // метод, если требуется повторно загрузить данные
    func reloadData() {
        questionFactory?.loadData()
    }
    
    // метод для конвертации вопросов во вью модель для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // MARK: - QuestionFactoryDelegate
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
    
    // если данные успешно загружены
    func didLoadDataFromServer() {
        // скрываем индикатор загрузки
        viewController?.hideLoadingIndicator()
        // показываем следующий вопрос
        questionFactory?.requestNextQuestion()
    }
    
    // если пришла ошибка от сервера
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    //MARK: - Privates Methods
    
    // метод для формирования сообщения
    private func makeResultsMessage() -> String {
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
        return text
    }
    
    // метод, который показывает или следующий вопрос, или результат квиза
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            // идем в состояние "результат квиза"
            let text = makeResultsMessage()
            
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
    
    // метод для показа правильного ответа
    private func proceedWithAnswer(isCorrect: Bool) {
        // считаем количество правильных ответов
        didAnswer(isCorrect: isCorrect)
        
        // раскрашиваем рамку с ответом
        viewController?.highLightImageBorder(isCorrectAnswer: isCorrect)
        
        // показываем вопрос с задержкой в секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            
            // делаем кнопки доступными
            viewController?.enableButtons()
        }
    }
    
    // метод для подсчета правильного ответа
    private func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    // метод для проверки правильного ответа
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
