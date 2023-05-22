import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticServiceProtocol!
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var isRu: Bool = LocalizationSystem.sharedInstance.getLanguage() == "ru"
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
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
    
    func hideLoadingForLastQuestion() -> Bool {
        currentQuestionIndex != 9
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
        viewController?.showNetworkError(message: isRu ? "Невозможно загрузить данные" : "Unable to upload data")
    }
    
    func didExceededLimit(error: Error) {
        viewController?.showNetworkError(message: isRu ? "Превышен лимит на сервере" : "Exceeded the limit on the server")
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func loadData() {
        questionFactory?.loadData()
    }
    
    func makeResultMessage() -> String {
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            return ""
        }
        
        let totalPlayCountLine = isRu ? "Количество сыгранных квизов: \(statisticService.gamesCount)" : "Number of quizzes played: \(statisticService.gamesCount)"
        let currentGameResultLine = isRu ? "Ваш результат: \(correctAnswers)/\(questionsAmount)" : "Your result: \(correctAnswers)/\(questionsAmount)"
        let averageAccuracyLine = isRu ? "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%" : "Average accuracy: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let bestGameInfoLine = isRu ? "Рекорд: \(bestGame.correct)/10 (\(bestGame.date.dateTimeString))" : "Record: \(bestGame.correct)/10 (\(bestGame.date.dateTimeString))"
        let resultMessage = [currentGameResultLine, totalPlayCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        
        return resultMessage
    }
    
    func makeTitleMessage() -> String {
        let titleMessage = isRu ? "Этот раунд окончен!" : "This round is over!"
        return titleMessage
    }
    
    func makeButtonMessage() -> String {
        let buttonMessage = isRu ? "Сыграть ещё раз" : "Play again"
        return buttonMessage
    }
    
    func makeTitleMessageForError() -> String {
        let buttonMessage = isRu ? "Ошибка" : "Error"
        return buttonMessage
    }
    
    func makeButtonMessageForError() -> String {
        let buttonMessage = isRu ? "Попробовать ещё раз" : "Try again"
        return buttonMessage
    }
    
    // MARK: - Yes/No button logic
    
    func noButtonTapped() {
        didAnswer(isYes: false)
    }
    
    func yesButtonTapped() {
        didAnswer(isYes: true)
    }
}

    // MARK: - Private extention

private extension MovieQuizPresenter {
    
    func didAnswer(isCorrectAnswer: Bool) {
        correctAnswers += 1
    }
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            viewController?.showResult()
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            didAnswer(isCorrectAnswer: isCorrect)
        }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.currentAnswer)
    }
}
