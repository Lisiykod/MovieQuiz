//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 16.07.2024.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    // счетчик сыгранных игр
    var gameCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // лучшая игра
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.BestGame.correct.rawValue)
            let total = storage.integer(forKey: Keys.BestGame.total.rawValue)
            let data = storage.object(forKey: Keys.BestGame.date.rawValue) as? Date ?? Date()
            let best = GameResult(correct: correct, total: total, game: data)
            return best
        }
        set {
            storage.set(newValue.correct, forKey: Keys.BestGame.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.BestGame.total.rawValue)
            storage.set(newValue.game, forKey: Keys.BestGame.date.rawValue)
        }
    }
    
    // средняя точность
    var totalAccuracy: Double {
        if gameCount != 0 && correctAnswers != 0 {
            return (Double(correctAnswers)/(Double(bestGame.total * gameCount))) * 100
        } else {
            return 0
        }
    }
    
    // ключи для данных 
    private enum Keys: String {
        case gamesCount
        case correctAnswers
        case totalAnswers
        
        enum BestGame: String {
            case correct
            case total
            case date
        }
    }
    
    private let storage: UserDefaults = .standard
    
    // количество правильных ответов
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    // метод для сохранения результатов
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        gameCount += 1
        let newGame = GameResult(correct: count, total: amount, game: Date())
        if  newGame.isBetterThan(another: bestGame) || newGame.isEqual(another: bestGame) {
            bestGame = newGame
        }
    }
    
}
