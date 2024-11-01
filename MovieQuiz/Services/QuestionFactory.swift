//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Александр Дудченко on 13.10.2024.
//

import Foundation

final class QuestionFactory:QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = [] // Массив для хранения загруженных фильмов
    private var shownQuestions: [QuizQuestion] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    // Метод для загрузки фильмов с сервера
    func loadData() {
        // Вызов метода loadMovies, который загружает фильмы
        moviesLoader.loadMovies { [weak self] result in
            // Переход на главную поток для обновления интерфейса после получения данных
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    // Сохраняем загруженные фильмы в свойстве movies
                    self.movies = mostPopularMovies.items
                    // Уведомляем делегата о том, что загрузка завершена успешно
                    self.delegate?.didLoadDataFromServer()
                    
                case .failure(let error):
                    // Уведомляем делегата о том, что произошла ошибка
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    /* Пока что мы не используем эти данные поэтому коментируем их!
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
     */
    // Метод для запроса следующего вопроса
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return}
            
            // Если все фильмы уже были использованы, очищаем список показанных вопросов
            if self.shownQuestions.count == self.movies.count {
                self.shownQuestions.removeAll()
            }
            //Выбираем случайный фильм, который еще не был показан
            var movie: MostPopularMovie?
            repeat {
                guard let index = (0..<movies.count).randomElement() else {
                    self.delegate?.didReceiveNextQuestion(question: nil)
                    return
                }
                movie = movies[safe: index]
            } while shownQuestions.contains(where: { $0.text == movie?.title })
            
            // Проверяем,что фильм выбран
            guard let selectedMovie = movie else {
                print("Не удалось выбрать фильм") // удалить
                self.delegate?.didReceiveNextQuestion(question: nil)
                return
            }
            
            // Преобразование рейтинга и создание текста вопроса
            let rating = Float(selectedMovie.rating) ?? 0.0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7.0
            
            // Асинхронная загрузка изображения
            guard let imageURL = movie?.resizedImageURL else {
                self.delegate?.didReceiveNextQuestion(question: nil)
                return
            }
            self.loadImageData(from: imageURL) { [weak self] imageData in
                guard let self = self, let imageData = imageData else {
                    print("Failed to load image")
                    self?.delegate?.didReceiveNextQuestion(question: nil)
                    return
                }
                // Создание новый вопрос QuizQuestion
                let question = QuizQuestion(
                    image: imageData,
                    text: text,
                    correctAnswer: correctAnswer
                )
                // Передача вопроса на главный поток
                self.shownQuestions.append(question)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }
        }
    }
    private func loadImageData(from url: URL, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil) // возвращаем nil в случае ошибки
                return
            }
            completion(data)
        }.resume()
    }
}
