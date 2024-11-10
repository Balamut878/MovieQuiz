
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    private var presenter = MovieQuizPresenter()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        // Скгругляем углы постера при инициализации
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        statisticService = StatisticService()
        
        let factory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = factory
        
        alertPresenter = AlertPresenter(viewcontroller: self)
        
        showLoadingIndicator() // Показываем индикатор загрузки
        questionFactory?.loadData() // Запускаем загрузку данных
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // MARK: - Private Methods
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            
            let totalQuestions = presenter.questionsAmount
            statisticService?.store(correct: correctAnswers, total: totalQuestions)
            
            
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
                    self?.presenter.resetQuestionIndex()
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                    self?.setButtonsEnabled(true)
                }
            )
            alertPresenter?.show(alertModel: alert)
        } else {
            // Переход к следующему вопросу
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            setButtonsEnabled(true) // Включаем кнопки для следующего вопроса
        }
    }
    
    private func show(quiz result: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor // Сброс рамки для следующего вопроса
        imageView.image = result.image
        textLabel.text = result.question
        counterLabel.text = result.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
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
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(alertModel: model)
    }
}

