import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var questionFactory: QuestionFactoryProtocol? // да
    var correctAnswers = 0 // да
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var statisticService: StatisticServiceProtocol?
    
    init(viewController: MovieQuizViewController) {

        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        self.viewController?.showLoadindIndicator()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func showNextQuestionOrResult() {
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            viewController?.showResult()
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        correctAnswers += 1
    }
    
    
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: "Невозможно загрузить данные")
        viewController?.showLoadindIndicator()
    }
    
    func didExceededLimit(error: Error) {
        viewController?.showNetworkError(message: "Превышен лимит на сервере")
        viewController?.showLoadindIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadindIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func makeResultMessage() -> String {
         guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
             return ""
         }

         let totalPlayCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
         let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
         let bestGameInfoLine = "Рекорд: \(bestGame.correct)/10" + " (\(bestGame.date.dateTimeString))"
         let resultMessage = [currentGameResultLine, totalPlayCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
         return resultMessage
    }
    
    // MARK: - yes/no button logic
    
    func noButtonTapped() {
        didAnswer(isYes: false)
       }
    
    func yesButtonTapped() {
        didAnswer(isYes: true)
       }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.currentAnswer)
    }
}
