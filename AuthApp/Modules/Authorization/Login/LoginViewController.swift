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
        lbl.text = "Войти или зарегистрироваться"
        return lbl
    }()
    
    private lazy var loginTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 16, weight: .bold)
        tf.autocorrectionType = .no
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "Введите почту",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "F2F2F7").withAlphaComponent(0.7)]
        )
        tf.keyboardType = .emailAddress
        tf.textColor = .white
        return tf
    }()
    
    private lazy var loginUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
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
        tf.rightViewMode = .always
        return tf
    }()
    
    private lazy var passwordUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupGestureRecognizer()
        setupBindings()
    }
}

private extension LoginViewController {
    func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(loginTextField)
        view.addSubview(loginUnderlineView)
        view.addSubview(passwordTextField)
        view.addSubview(passwordUnderlineView)
        view.addSubview(loginButton)
    }
    
    func setupConstraints() {
        backgroundImageView.easy.layout(
            Edges()
        )
        
        titleLabel.easy.layout(
            Top(200),
            Leading(16),
            Trailing(16)
        )
        
        loginTextField.easy.layout(
            Top(34).to(titleLabel, .bottom),
            Leading(16),
            Trailing(16),
            Height(36)
        )
        
        loginUnderlineView.easy.layout(
            Top().to(loginTextField, .bottom),
            Leading(16),
            Trailing(16),
            Height(1)
        )
        
        passwordTextField.easy.layout(
            Top(48).to(loginTextField, .bottom),
            Leading(16),
            Trailing(16),
            Height(36)
        )
        
        passwordUnderlineView.easy.layout(
            Top().to(passwordTextField, .bottom),
            Leading(16),
            Trailing(16),
            Height(1)
        )
        
        loginButton.easy.layout(
            Top(60).to(passwordUnderlineView, .bottom),
            Leading(25),
            Trailing(25),
            Height(42)
        )
    }
    
    func setupBindings() {
        securitePasswordButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                securitePasswordButton.isSelected.toggle()
                passwordTextField.isSecureTextEntry.toggle()
            }
            .store(in: &cancellables)
        
        loginButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                print("login button did touch")
            }
            .store(in: &cancellables)
        
        loginTextField.returnPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.passwordTextField.becomeFirstResponder()
            }
            .store(in: &cancellables)
        
        loginTextField.editingDidEndPublisher
            .sink { [weak self] in
                guard let self else { return }
                guard let text = self.loginTextField.text else { return }
                self.viewModel.login = text
            }
            .store(in: &cancellables)
        
        passwordTextField.returnPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.passwordTextField.resignFirstResponder()
            }
            .store(in: &cancellables)
        
        
    }
    
    func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func viewTapped() {
        view.endEditing(true)
    }
}
