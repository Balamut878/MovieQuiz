//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Александр Дудченко on 10.11.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = true
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = false
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
