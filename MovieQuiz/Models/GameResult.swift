//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Александр Дудченко on 16.10.2024.
//

import Foundation

struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date
    // Метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
