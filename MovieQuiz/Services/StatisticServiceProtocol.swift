//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Александр Дудченко on 16.10.2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get set }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
