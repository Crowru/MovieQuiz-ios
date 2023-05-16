import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    enum GameError: Error {
        case imageLoadingError
        case exceededLimitError
    }
    
    private let moviewLoader: MoviesLoadingProtocol
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate?) {
        self.moviewLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviewLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.errorMessage.isEmpty {
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    } else {
                        self.delegate?.didExceededLimit(error: GameError.exceededLimitError)
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let randomRating = (5...9).randomElement() ?? 5
            let moreThan = Bool.random()
            
            let text  = "Рейтинг этого фильма \(moreThan ? "больше" : "меньше") чем \(randomRating)?"
            let correctAnswer = moreThan ? rating > Float(randomRating) : rating < Float(randomRating)
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        currentAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
