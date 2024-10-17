//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Александр Дудченко on 13.10.2024.
//

import Foundation

final class QuestionFactory:QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    private var shownQuestions: [QuizQuestion] = []
    func requestNextQuestion() {
        // Если все вопросы уже были показаны,перезапускаем игру, или сбрасываем массив показанных вопросов
        if shownQuestions.count == questions.count {
            shownQuestions.removeAll() // Очищаем список показанных вопросов, чтобы начать заново
        }
        // Ищем вопрос который еще не был показан
        var question: QuizQuestion?
        repeat {
            guard let index = (0..<questions.count).randomElement() else {
                delegate?.didReceiveNextQuestion(question: nil)
                return
            }
            question = questions[safe: index]
        } while shownQuestions.contains(where: { $0.image == question?.image }) // Повторяем если вопрос уже был показан
        if let validQuestion = question {
            shownQuestions.append(validQuestion) // Добавляем вопрос в список показанных
            delegate?.didReceiveNextQuestion(question: validQuestion)
        } else {
            delegate?.didReceiveNextQuestion(question: nil)
        }
    }
}
