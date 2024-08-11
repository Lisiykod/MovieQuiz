import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private  weak var yesButton: UIButton!
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // переменные для отображения вопросов
    private var questionFactory: QuestionFactoryProtocol?
    private var movieLoader: MoviesLoading = MoviesLoader()
    private let presenter: MovieQuizPresenter = MovieQuizPresenter()
    
    // переменные для отображения результата
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
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
        presenter.viewController = self
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    // метод, чтобы отдать новый вопрос квиза
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    // если данные успешно загружены
    func didLoadDataFromServer() {
        // скрываем индикатор загрузки
        activityIndicator.isHidden = true
        // показываем следующий вопрос
        questionFactory?.requestNextQuestion()
    }
    
    // если пришла ошибка от сервера
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        buttonIsEnable = false
        changeStateButton(isEnabled: buttonIsEnable)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        buttonIsEnable = false
        changeStateButton(isEnabled: buttonIsEnable)
    }
    
    // MARK: - Public Methods
    
    // метод для раскрашивания рамки
    func showAnswerResult(isCorrect: Bool) {
        // считаем количество правильных ответов
        presenter.didAnswer(isCorrect: isCorrect)
        
        // даем разрешение на рисование рамки
        imageView.layer.masksToBounds = true
        // толщина рамки
        imageView.layer.borderWidth = 8
        // меняем цвет рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // скругляем углы
        imageView.layer.cornerRadius = 20
        
        // показываем вопрос с задержкой в секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResult()
            // убираем рамку с ответом на новом вопросе
            imageView.layer.borderWidth = 0
            
            // делаем кнопки доступными
            self.buttonIsEnable = true
            self.changeStateButton(isEnabled: buttonIsEnable)
        }
    }
    
    //MARK: - Private Methods
    // настраиваем шрифты
    private func setupFonts() {
        noButton.titleLabel?.font = UIFont(name: mediumFont, size: mediumFontSize)
        yesButton.titleLabel?.font = UIFont(name: mediumFont, size: mediumFontSize)
        questionTitleLabel.font = UIFont(name: mediumFont, size: mediumFontSize)
        textLabel.font = UIFont(name: boldFont, size: boldFontSize)
        counterLabel.font = UIFont(name: mediumFont, size: mediumFontSize)
    }
    
    // метод для вывода вопроса на экран
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
       
    }
    
    // метод для показа результатов раунда квиза
    func show(quiz result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else { return }
                // сбрасываем значения на начальные
                self.presenter.restartGame()
                
                // заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            }
        alertPresenter?.present(alert: alertModel, id: "Game result")
    }
    
    // выключаем кнопки (до показа следующего вопроса)
    private func changeStateButton(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // метод для настройки связи с делегатами и сервисом статистики
    private func initialSetup() {
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader())
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
            title: "Что-то пошло не так",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                // сбрасываем значения на начальные
                self.presenter.restartGame()
                // пробуем еще раз загрузить данные
                showLoadingIndicator()
                questionFactory?.loadData()
                // заново показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            }
        alertPresenter?.present(alert: model, id: nil)
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
