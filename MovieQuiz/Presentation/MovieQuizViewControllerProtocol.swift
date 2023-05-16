import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResult()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showNetworkError(message: String)
    func didReceiveNextQuestion(question: QuizQuestion?)
}
