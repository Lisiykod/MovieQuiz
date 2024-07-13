//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 12.07.2024.
//

import UIKit

//ViewModel для состояния "Вопрос показан"
struct QuizStepViewModel {
    // картинка с афишей фильма
    let image: UIImage
    // вопрос о рейтинге квиза
    let question: String
    // строка с порядковым номером этого вопроса (ex. "1/10")
    let questionNumber: String
}
