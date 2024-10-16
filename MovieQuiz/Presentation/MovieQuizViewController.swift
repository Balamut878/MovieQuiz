
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var correctAnswers = 0
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticService()
        let factory = QuestionFactory()
        factory.setup(delegate: self)
        self.questionFactory = factory
        alertPresenter = AlertPresenter(viewcontroller: self)
        questionFactory?.requestNextQuestion()
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // Получаем результат текущей игры
            let correctAnswers = self.correctAnswers
            let totalQuestions = self.questionsAmount
            
            // Обновляем статистику,сохраняя результат игры
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            // Получаем текст для отображения в алерте
            let totalAccuracyString = String(format: "%.2f", statisticService?.totalAccuracy ?? 0)
            let bestGame = statisticService?.bestGame
            let bestGameDate = bestGame?.date.dateTimeString ?? "N/A" // Форматируем дату
            let message = """
            Ваш результат: \(correctAnswers) из \(totalQuestions)
            Количество сыграных квизов: \(statisticService?.gamesCount ?? 0)
            Рекорд: \(bestGame?.correct ?? 0) из \(bestGame?.total ?? 0) (\(bestGameDate))
            Средняя точность: \(totalAccuracyString)%
            """
            // Создаем и показываем алерт с результатами
            let alert = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.currentQuestionIndex = 0
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                    self?.setButtonsEnabled(true)
                }
            )
            alertPresenter?.show(alertModel: alert)
        } else {
            // Переход к следующему вопросу
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            setButtonsEnabled(true) // Включаем кнопки для следующего вопроса
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor // Сброс рамки для следующего вопроса
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel( // 1
            image: UIImage(named: model.image) ?? UIImage(), // 2
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
}
