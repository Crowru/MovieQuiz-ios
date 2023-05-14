import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticServiceProtocol!
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        self.viewController?.showLoadingIndicator()
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
    
    // MARK: - QuestionFactoryDelegate
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: "Невозможно загрузить данные")
        viewController?.showLoadingIndicator()
    }
    
    func didExceededLimit(error: Error) {
        viewController?.showNetworkError(message: "Превышен лимит на сервере")
        viewController?.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
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
    
    private func didAnswer(isCorrectAnswer: Bool) {
        correctAnswers += 1
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            viewController?.showResult()
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            didAnswer(isCorrectAnswer: isCorrect)
        }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.showLoadingIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.viewController?.hideLoadingIndicator()
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.currentAnswer)
    }
}
