//
//  LoginViewController.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 24.05.2024.
//

import UIKit
import EasyPeasy
import Combine
import CombineCocoa

fileprivate struct Image {
    static let background = UIImage(named: "loginBackground")
}

final class LoginViewController: UIViewController  {
    
    var viewModel: LoginViewModel!
    
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
        iv.backgroundColor = .black
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 32, weight: .heavy)
        lbl.numberOfLines = 0
        lbl.text = "Войти или зарегистрироваться"
        return lbl
    }()
    
    private lazy var loginTextField: AuthTextField = {
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
        tf.isSecureTextEntry = true
        tf.rightView = securitePasswordButton
        return tf
    }()
    
    private lazy var securitePasswordButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "eye")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.setImage(UIImage(systemName: "eye.slash")?.withRenderingMode(.alwaysTemplate), for: .selected)
        btn.tintColor = UIColor(hexString: "F2F2F7").withAlphaComponent(0.7)
        btn.easy.layout(
            Width(26),
            Height(16)
        )
        return btn
    }()
    
    private lazy var loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Войти", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(hexString: "127369")
        btn.layer.cornerRadius = 21
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowRadius = 15
        btn.layer.masksToBounds = false
        return btn
    }()
    
    private lazy var registrationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Регистрация", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .clear
        
        return btn
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Забыли пароль?", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .clear
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupBindingsUI()
        setupBindingsViewModel()
        
        self.setupEndEditingGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.navigationController!.isNavigationBarHidden {
            self.navigationController!.setNavigationBarHidden(true, animated: true)
        }
    }
}

private extension LoginViewController {
    func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(activityIndicator)
        view.addSubview(registrationButton)
        view.addSubview(forgotPasswordButton)
    }
    
    func setupConstraints() {
        backgroundImageView.easy.layout(
            Edges()
        )
        
        titleLabel.easy.layout(
            Top(140),
            Leading(16),
            Trailing(16)
        )
        
        loginTextField.easy.layout(
            Top(34).to(titleLabel, .bottom),
            Leading(16),
            Trailing(16)
        )
        
        passwordTextField.easy.layout(
            Top(80).to(loginTextField, .top),
            Leading(16),
            Trailing(16)
        )
        
        loginButton.easy.layout(
            Top(60).to(passwordTextField, .bottom),
            Leading(25),
            Trailing(25),
            Height(42)
        )
        
        activityIndicator.easy.layout( 
            Center()
        )
        
        registrationButton.easy.layout(
            Top(34).to(loginButton, .bottom),
            Leading(25),
            Height(35)
        )
        
        forgotPasswordButton.easy.layout(
            Top(2).to(registrationButton, .bottom),
            Leading(25),
            Height(35)
        )
    }
    
    func setupBindingsUI() {
        loginButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.view.endEditing(true)
                let textFields = [self.loginTextField, self.passwordTextField]
                guard !textFields.contains(where: { $0.state == .failure }) else {
                    textFields.forEach { tf in
                        tf.shakeError()
                    }
                    return
                }
                
                let login = self.loginTextField.text
                let password = self.passwordTextField.text
                
                guard !login.isEmpty && !password.isEmpty else {
                    self.showAlert(title: "Ошибка", description: "Заполните все поля")
                    return
                }
                
                self.activityIndicator.startAnimating()
                
                self.viewModel.login(with: login, password: password)
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
        
        //MARK: - Login
        loginTextField.tf.returnPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.passwordTextField.becomeFirstResponder()
            }
            .store(in: &cancellables)
        
        loginTextField.tf.editingDidEndPublisher
            .sink { [weak self] in
                guard let self else { return }
                let text = self.loginTextField.text
                guard !text.isEmpty else {
                    self.loginTextField.setSuccessState()
                    return
                }
                self.viewModel.login = text
            }
            .store(in: &cancellables)
        
        loginTextField.tf.didBeginEditingPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.loginTextField.setSuccessState()
            }
            .store(in: &cancellables)
        
        //MARK: - Password
        passwordTextField.tf.returnPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.passwordTextField.resignFirstResponder()
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
        
        
        securitePasswordButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                securitePasswordButton.isSelected.toggle()
                passwordTextField.isSecureTextEntry.toggle()
            }
            .store(in: &cancellables)
        
        registrationButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.viewModel.openRegistration()
            }
            .store(in: &cancellables)
    }
    
    func setupBindingsViewModel() {
        viewModel.loginValid
            .sink { [weak self] result in
                guard let self else { return }
                guard result != .valid else {
                    self.loginTextField.setSuccessState()
                    return
                }
                self.loginTextField.setErrorState(message: result.errorMessage)
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
    }
}
