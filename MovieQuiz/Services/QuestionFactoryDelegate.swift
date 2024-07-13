//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 13.07.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
