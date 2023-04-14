import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    @IBOutlet weak private var textQuestionLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var countLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        preparation()
        
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
    
    // MARK: - yes/no button action
    
    @IBAction private func noButtonAction(_ sender: UIButton) {
        noButtonTapped()
    }
    
    @IBAction private func yesButtonAction(_ sender: UIButton) {
        yesButtonTapped()
    }
    
    // MARK: - yes/no button logic
    
    private func noButtonTapped() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.currentAnswer)
       }
    
    private func yesButtonTapped() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.currentAnswer)
       }
    
    // MARK: - initial setup
    
    private func preparation() {
        imageView.layer.cornerRadius = 20
        questionFactory?.requestNextQuestion()
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionAmount - 1 {
            showResult(quiz: QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш результат: \(correctAnswers)/10", buttonText: "Сыграть ещё раз"))
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - The logic of choosing an action
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderWidth = 8
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        countLabel.text = step.questionNumber
        textQuestionLabel.text = step.question
    }
    
    private func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
}
