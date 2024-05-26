//
//  RegistrationViewController.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 25.05.2024.
//

import UIKit
import Combine
import CombineCocoa
import EasyPeasy

fileprivate struct Image {
    static let background = UIImage(named: "loginBackground")
}

final class RegistrationViewController: UIViewController  {
    
    var viewModel: RegistrationViewModel!
    
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Image.background
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 32, weight: .heavy)
        lbl.numberOfLines = 0
        lbl.text = "Регистрация"
        return lbl
    }()
    
    private lazy var nameTextField: AuthTextField = {
        let tf = AuthTextField()
        tf.font = .systemFont(ofSize: 16, weight: .bold)
        tf.autocorrectionType = .no
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "Введите имя",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "F2F2F7").withAlphaComponent(0.7)]
        )
        tf.textColor = .white
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var emailTextField: AuthTextField = {
        let tf = AuthTextField()
        tf.font = .systemFont(ofSize: 16, weight: .bold)
        tf.autocorrectionType = .no
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "Введите почту",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "F2F2F7").withAlphaComponent(0.7)]
        )
        tf.keyboardType = .emailAddress
        tf.textColor = .white
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var passwordTextField: AuthTextField = {
        let tf = AuthTextField()
        tf.font = .systemFont(ofSize: 16, weight: .bold)
        tf.autocorrectionType = .no
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "Введите пароль",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "F2F2F7").withAlphaComponent(0.7)]
        )
        tf.textColor = .white
        return tf
    }()
    
    private lazy var confirmPasswordTextField: AuthTextField = {
        let tf = AuthTextField()
        tf.font = .systemFont(ofSize: 16, weight: .bold)
        tf.autocorrectionType = .no
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "Повторите пароль",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "F2F2F7").withAlphaComponent(0.7)]
        )
        tf.textColor = .white
        return tf
    }()
    
    private lazy var loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Продолжить", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(hexString: "127369")
        btn.layer.cornerRadius = 21
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowRadius = 15
        btn.layer.masksToBounds = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupEndEditingGestureRecognizer()
        setupBindingsUI()
        setupBindingsViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.backButtonTitle = "Назад"
        if self.navigationController!.isNavigationBarHidden {
            self.navigationController!.setNavigationBarHidden(false, animated: true)
        }
    }
}

private extension RegistrationViewController {
    func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(activityIndicator)
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(loginButton)
    }
    
    func setupConstraints() {
        backgroundImageView.easy.layout(
            Edges()
        )
        
        activityIndicator.easy.layout(
            Center()
        )
        
        titleLabel.easy.layout(
            Top(140),
            Leading(16),
            Trailing(16)
        )
        
        nameTextField.easy.layout(
            Top(46).to(titleLabel, .bottom),
            Leading(16),
            Trailing(16)
        )
        
        emailTextField.easy.layout(
            Top(66).to(nameTextField, .top),
            Leading(16),
            Trailing()
        )
        
        passwordTextField.easy.layout(
            Top(66).to(emailTextField, .top),
            Leading(16),
            Trailing(16)
        )
        
        confirmPasswordTextField.easy.layout(
            Top(66).to(passwordTextField, .top),
            Leading(16),
            Trailing(16)
        )
        
        loginButton.easy.layout(
            Bottom(51).to(view.safeAreaLayoutGuide, .bottom),
            Leading(25),
            Trailing(25),
            Height(42)
        )
    }
    
    func setupBindingsUI() {
        loginButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.view.endEditing(true)
                let textFields = [
                    self.nameTextField,
                    self.emailTextField,
                    self.passwordTextField,
                    self.confirmPasswordTextField
                ]
                guard !textFields.contains(where: { $0.state == .failure }) else {
                    textFields.forEach { tf in
                        tf.shakeError()
                    }
                    return
                }
                
                if textFields.contains(where: { $0.text.isEmpty }) {
                    self.showAlert(title: "Ошибка", description: "Заполните все поля")
                    return
                }
                
                self.activityIndicator.startAnimating()
                
                self.viewModel.registration(
                    with: self.emailTextField.text,
                    password: self.passwordTextField.text
                )
                .sink { error in
                    self.activityIndicator.stopAnimating()
                    switch error {
                    case .finished:
                        break
                    case .failure(let error):
                        self.showAlert(title: "Ошибка", description: error.errorDescription)
                    }
                } receiveValue: { _ in
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Успешно", description: "")
                }
                .store(in: &cancellables)
                
            }
            .store(in: &cancellables)
        
        
        //MARK: - Name
        
        nameTextField.tf.returnPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.nameTextField.becomeFirstResponder()
            }
            .store(in: &cancellables)
        
        nameTextField.tf.editingDidEndPublisher
            .sink { [weak self] in
                guard let self else { return }
                let text = self.nameTextField.text
                guard !text.isEmpty else {
                    self.nameTextField.setSuccessState()
                    return
                }
                self.viewModel.name = text
            }
            .store(in: &cancellables)
        
        nameTextField.tf.didBeginEditingPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.nameTextField.setSuccessState()
            }
            .store(in: &cancellables)
        
        //MARK: - Email
        emailTextField.tf.returnPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.emailTextField.becomeFirstResponder()
            }
            .store(in: &cancellables)
        
        emailTextField.tf.editingDidEndPublisher
            .sink { [weak self] in
                guard let self else { return }
                let text = self.emailTextField.text
                guard !text.isEmpty else {
                    self.emailTextField.setSuccessState()
                    return
                }
                self.viewModel.email = text
            }
            .store(in: &cancellables)
        
        emailTextField.tf.didBeginEditingPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.emailTextField.setSuccessState()
            }
            .store(in: &cancellables)
        
        //MARK: - Password
        passwordTextField.tf.returnPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.passwordTextField.becomeFirstResponder()
            }
            .store(in: &cancellables)
        
        passwordTextField.tf.editingDidEndPublisher
            .sink { [weak self] in
                guard let self else { return }
                let text = self.passwordTextField.text
                guard !text.isEmpty else {
                    self.passwordTextField.setSuccessState()
                    return
                }
                self.viewModel.password = text
            }
            .store(in: &cancellables)
        
        passwordTextField.tf.didBeginEditingPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.passwordTextField.setSuccessState()
            }
            .store(in: &cancellables)
        
        //MARK: - Confirm password
        confirmPasswordTextField.tf.editingDidEndPublisher
            .sink { [weak self] value in
                guard let self else { return }
                let text = self.confirmPasswordTextField.text
                guard !text.isEmpty else {
                    self.confirmPasswordTextField.setSuccessState()
                    return
                }
                self.viewModel.confirmPassword = text
            }
            .store(in: &cancellables)
    }
    
    func setupBindingsViewModel() {
        viewModel.emailIsValid
            .sink { [weak self] result in
                guard let self else { return }
                guard result != .valid else {
                    self.emailTextField.setSuccessState()
                    return
                }
                self.emailTextField.setErrorState(message: result.errorMessage)
            }
            .store(in: &cancellables)
        
        viewModel.nameIsValid
            .sink { [weak self] result in
                guard let self else { return }
                guard result != .valid else {
                    self.nameTextField.setSuccessState()
                    return
                }
                self.nameTextField.setErrorState(message: result.errorMessage)
            }
            .store(in: &cancellables)
        
        viewModel.passwordValid
            .sink { [weak self] result in
                guard let self else { return }
                guard result != .valid else {
                    self.passwordTextField.setSuccessState()
                    return
                }
                self.passwordTextField.setErrorState(message: result.errorMessage)
            }
            .store(in: &cancellables)
        
        viewModel.confirmIsValid
            .sink { [weak self] isValid in
                guard let self else { return }
                if isValid {
                    self.confirmPasswordTextField.setSuccessState()
                } else {
                    self.confirmPasswordTextField.setErrorState(message: "Пароли не совпадают")
                }
            }
            .store(in: &cancellables)
    }
}
