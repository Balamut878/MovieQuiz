//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Александр Дудченко on 13.10.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {              
    func didReceiveNextQuestion(question: QuizQuestion?)
}
