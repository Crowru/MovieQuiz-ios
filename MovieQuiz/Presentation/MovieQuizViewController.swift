import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet weak private var textQuestionLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var countLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preparation()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
    presenter.didReceiveNextQuestion(question: question)
    }
    
    
    
    // MARK: - yes/no button action
    
    @IBAction private func noButtonAction(_ sender: UIButton) {
        presenter.noButtonTapped()
    }
    
    @IBAction private func yesButtonAction(_ sender: UIButton) {
        presenter.yesButtonTapped()
    }
    
    // MARK: - initial setup
    
    private func preparation() {
        activityIndicator.hidesWhenStopped = true
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(viewController: self)
        //presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: presenter)
        //presenter.questionFactory?.loadData()
        showLoadindIndicator()
        //presenter.statisticService = StatisticServiceImplementation()
        //presenter.viewController = self
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - The logic of choosing an action
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.didAnswer(isCorrectAnswer: isCorrect)
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderWidth = 8
        
        showLoadindIndicator()
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.hideLoadindIndicator()
            self.presenter.showNextQuestionOrResult()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
        }
    }
    
    func showResult() {
        //presenter.statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: presenter.makeResultMessage(),
            buttonText: "Сыграть ещё раз") { [weak self] in
                self?.presenter.restartGame()
            }
        alertPresenter?.show(alertModel: alertModel)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        countLabel.text = step.questionNumber
        textQuestionLabel.text = step.question
    }
    
    // MARK: - Loading Indicator
    
    func showLoadindIndicator() {
        activityIndicator.color = .white
        activityIndicator.startAnimating()
    }
    
    func hideLoadindIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - NetworkError
    
    func showNetworkError(message: String) {
        hideLoadindIndicator()
        
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
            //self.presenter.questionFactory?.loadData()
        }
        alertPresenter?.show(alertModel: model)
    }
}
