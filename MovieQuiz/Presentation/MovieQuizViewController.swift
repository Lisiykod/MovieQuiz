import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private  weak var yesButton: UIButton!
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // переменные для отображения вопросов
    private var movieLoader: MoviesLoading = MoviesLoader()
    private var presenter: MovieQuizPresenter?
    
    // переменные для отображения результата
    private var alertPresenter: AlertPresenterProtocol?
    
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
        activityIndicator.hidesWhenStopped = true
        setupFonts()
        initialSetup()
        showLoadingIndicator()
    }
        
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
        buttonIsEnable = false
        changeStateButton(isEnabled: buttonIsEnable)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
        buttonIsEnable = false
        changeStateButton(isEnabled: buttonIsEnable)
    }
    
    // MARK: - Public Methods
    
    // раскрашиваем рамку с ответом
    func highLightImageBorder(isCorrectAnswer: Bool) {
        // даем разрешение на рисование рамки
        imageView.layer.masksToBounds = true
        // толщина рамки
        imageView.layer.borderWidth = 8
        // меняем цвет рамки
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // скругляем углы
        imageView.layer.cornerRadius = 20
    }
        
    // делаем кнопки доступными
    func enableButtons() {
        self.buttonIsEnable = true
        self.changeStateButton(isEnabled: buttonIsEnable)
    }
    
    // метод для вывода вопроса на экран
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
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
                self.presenter?.restartGame()
            }
        alertPresenter?.present(alert: alertModel, id: "Game result")
    }
    
    // метод для показа индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    // метод для скрытия индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // метод для показа алерта, если загрузка не удалась
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(
            title: "Что-то пошло не так",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                showLoadingIndicator()
                // пробуем еще раз загрузить данные
                self.presenter?.reloadData()
                self.presenter?.restartGame()
            }
        alertPresenter?.present(alert: model, id: nil)
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
    
    // выключаем кнопки (до показа следующего вопроса)
    private func changeStateButton(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // метод для настройки связи с делегатом и презентером
    private func initialSetup() {
        presenter = MovieQuizPresenter(viewController: self)
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
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
