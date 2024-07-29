import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private  weak var yesButton: UIButton!
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // количество выводимых вопросов
    private let questionsAmount: Int = 10
    // переменные для отображения вопросов
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    // переменные для отображения результата
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // переменная с индексом текущего вопроса
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // переменные для настройки шрифтов
    private let mediumFont: String = "YSDisplay-Medium"
    private let boldFont: String = "YSDisplay-Bold"
    private let mediumFontSize: CGFloat = 20.0
    private let boldFontSize: CGFloat = 23.0
    
    // переменная для состояния кнопки
    private var buttonIsEnable: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFonts()
        initialSetup()
        questionFactory?.requestNextQuestion()
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
            self?.show(quiz: viewModel)
        }
        
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorret: givenAnswer == currentQuestion.correctAnswer)
        buttonIsEnable = false
        changeStateButton(isEnabled: buttonIsEnable)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorret: givenAnswer == currentQuestion.correctAnswer)
        buttonIsEnable = false
        changeStateButton(isEnabled: buttonIsEnable)
    }
    
    //MARK: - Private functions
    // настраиваем шрифты
    private func setupFonts() {
        noButton.titleLabel?.font = UIFont(name: mediumFont, size: mediumFontSize)
        yesButton.titleLabel?.font = UIFont(name: mediumFont, size: mediumFontSize)
        questionTitleLabel.font = UIFont(name: mediumFont, size: mediumFontSize)
        textLabel.font = UIFont(name: boldFont, size: boldFontSize)
        counterLabel.font = UIFont(name: mediumFont, size: mediumFontSize)
    }
    
    // метод для конвертации моковских вопросов во вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // метод для вывода вопроса на экран
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // метод для раскрашивания рамки
    private func showAnswerResult(isCorret: Bool) {
        // считаем количество правильных ответов
        if isCorret {
            correctAnswers += 1
        }
        
        // даем разрешение на рисование рамки
        imageView.layer.masksToBounds = true
        // толщина рамки
        imageView.layer.borderWidth = 8
        // меняем цвет рамки
        imageView.layer.borderColor = isCorret ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // скругляем углы
        imageView.layer.cornerRadius = 20
        
        // показываем вопрос с задержкой в секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
        }
    }
    
    // метод, который показывает или следующий вопрос, или результат квиза
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            // идем в состояние "результат квиза"
            var text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n"
            if let statisticService = statisticService {
                // сохраняем результаты
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                text += """
                        Количество сыгранных квизов: \(statisticService.gamesCount)
                        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                       """
            }
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            // идем в состояние "следующий вопрос"
            self.questionFactory?.requestNextQuestion()
        }
        // убираем рамку с ответом на новом вопросе
        imageView.layer.borderWidth = 0
        
        // делаем кнопки доступными
        self.buttonIsEnable = true
        self.changeStateButton(isEnabled: buttonIsEnable)
    }
    
    // метод для показа результатов раунда квиза
    private func show(quiz result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            // сбрасываем значения на начальные
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            // заново показываем первый вопрос
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.present(alert: alertModel)
    }
    
    // выключаем кнопки (до показа следующего вопроса)
    private func changeStateButton(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // метод для настройки связи с делегатами и сервисом статистики
    private func initialSetup() {
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
        
        statisticService = StatisticService()
    }
    
    // метод для показа индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    // метод для скрытия индикатора загрузки
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    // метод для показа алерта, если загрузка не удалась
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            // сбрасываем значения на начальные
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            // заново показываем первый вопрос
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.present(alert: model)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
