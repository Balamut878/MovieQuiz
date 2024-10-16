//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Александр Дудченко on 16.10.2024.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    // Создаем свойство для работы с UserDefaults
    private let storage: UserDefaults = .standard
    // Перечисление для хранения ключей
    private enum Keys: String {
        case correct // Правильные ответы
        case total // Для общего количества вопросов
        case bestGame // Для сохранения лучшего результата игры
        case gamesCount // Для количества сыгранных игр
    }
    var totalAccuracy: Double {
        let correct = storage.integer(forKey: Keys.correct.rawValue)
        let total = storage.integer(forKey: Keys.total.rawValue)
        return total == 0 ? 0 : Double(correct) / Double(total) * 100
    }
    
    var gamesCount: Int {
        get {
            // Чтение значения из UserDefaults
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            // Запись значения UserDefaults
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            guard let data = storage.data(forKey: Keys.bestGame.rawValue),
                  let result = try? JSONDecoder().decode(GameResult.self, from: data) else {
                return GameResult(correct: 0, total: 0, date: Date())
            }
            return result
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                storage.set(encoded, forKey: Keys.bestGame.rawValue)
            }
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        // Обновляем количество правильных ответов и общего числа вопросов
        let correct = storage.integer(forKey: Keys.correct.rawValue) + count
        let total = storage.integer(forKey: Keys.total.rawValue) + amount
        storage.set(correct, forKey: Keys.correct.rawValue)
        storage.set(total, forKey: Keys.total.rawValue)
        
        // Обновляем количество игр
        gamesCount += 1
        
        // Сохраняем новый результат игры
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
    }
}
