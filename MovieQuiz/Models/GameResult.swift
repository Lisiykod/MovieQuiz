//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 16.07.2024.
//

import Foundation

struct GameResult {
    //количество правильных ответов
    let correct: Int
    // количество вопросов квиза
    let total: Int
    // дата завершения раунда
    let game: Date
    
    // метод сравнения по количеству правильных ответов
    func isBetterThan(another: GameResult) -> Bool {
        correct > another.correct
    }
    
    // метод сравнения, если правильные ответы даны несколько раз подряд
    func isEqual(another: GameResult) -> Bool {
        correct == another.correct
    }
}
