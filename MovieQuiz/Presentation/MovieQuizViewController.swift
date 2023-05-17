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
        hideLoadingIndicator()
        let alertModel = AlertModel(
            title: presenter.makeTitleMessage(),
            message: presenter.makeResultMessage(),
            buttonText: presenter.makeButtonMessage() ) { [weak self] in
                self?.showLoadingIndicator()
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
        hideLoadingIndicator()
    }
    
    // MARK: - NetworkError
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: presenter.makeTitleMessageForError(), message: message, buttonText: presenter.makeButtonMessageForError() ) { [weak self] in
            guard let self else { return }
            self.showLoadingIndicator()
            self.presenter.loadData()
        }
        alertPresenter?.show(alertModel: model)
    }
    
    // MARK: - yes/no button action
    
    @IBAction private func noButtonAction(_ sender: UIButton) {
        if !presenter.hideLoadingForLastQuestion() {
            showLoadingIndicator()
        }
        presenter.noButtonTapped()
    }
    
    @IBAction private func yesButtonAction(_ sender: UIButton) {
        if !presenter.hideLoadingForLastQuestion() {
            showLoadingIndicator()
        }
        presenter.yesButtonTapped()
    }
}

    // MARK: - Private extention

private extension MovieQuizViewController {
    
    // MARK: - initial setup
    
    func preparation() {
        activityIndicator.hidesWhenStopped = true
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(viewController: self)
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
        activityIndicator.color = .white
    }
    
    // MARK: - Loading Indicator
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}
