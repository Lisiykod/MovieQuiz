import UIKit

final class MovieQuizViewController: UIViewController {
    
    struct QuizQuestion {
        // название фильма, совпадающее с названием картинок из ассета
        let image: String
        // строка с вопросом
        let text: String
        // правильный ли ответ
        let correctAnswer: Bool
    }
    
    //ViewModel для состояния "Вопрос показан"
    struct QuizStepViewModel {
        // картинка с афишей фильма
        let image: UIImage
        // вопрос о рейтинге квиза
        let question: String
        // строка с порядковым номером этого вопроса (ex. "1/10")
        let questionNumber: String
    }
    
    // модель для состояния "Результат квиза"
    struct QuizResultsViewModel {
       // строка с заголовком алерта
        let title: String
       // строка с текстом сообщения
        let text: String
       // строка с текстом кнопки
        let buttonText: String
    }
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private  weak var yesButton: UIButton!
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    // переменные для настройки шрифтов
    private let mediumFont: String = "YSDisplay-Medium"
    private let boldFont: String = "YSDisplay-Bold"
    private let mediumFontSize: CGFloat = 20.0
    private let boldFontSize: CGFloat = 23.0
    
    // переменная, чтобы не дублировать вопрос
    private static let questionText: String = "Рейтинг этого фильма больше чем 6?"
    
    // переменная с индексом текущего вопроса
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFonts()
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorret: givenAnswer == currentQuestion.correctAnswer)
       disableButtons()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorret: givenAnswer == currentQuestion.correctAnswer)
        disableButtons()
    }
    
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextQuestionOrResult()
        }
    }
    
    // метод, который показывает или следующий вопрос, или результат квиза
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questions.count - 1 {
            // идем в состояние "результат квиза"
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            // идем в состояние "следующий вопрос"
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
        // убираем рамку с ответом на новом вопросе
        imageView.layer.borderWidth = 0
        
        // делаем кнопки доступными
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
    }
    
    // метод для показа результатов раунда квиза
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            // сбрасываем значения на начальные
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            // заново показываем первый вопрос
            let firstAnswer = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstAnswer)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // выключаем кнопки (до показа следующего вопроса)
    private func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
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
