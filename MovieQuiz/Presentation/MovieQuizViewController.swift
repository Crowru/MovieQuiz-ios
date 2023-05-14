import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
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
    
    // MARK: - The logic of choosing an action
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func showResult() {
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
        imageView.layer.borderColor = UIColor.clear.cgColor
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    // MARK: - Loading Indicator
    
    func showLoadingIndicator() {
        activityIndicator.color = .white
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - NetworkError
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
        }
        alertPresenter?.show(alertModel: model)
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
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
    }
}
