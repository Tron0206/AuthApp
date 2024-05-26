//
//  LoginViewModel.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 24.05.2024.
//

import Foundation
import Combine
import FirebaseAuth

final class LoginViewModel {
    
    var router: LoginRouter?
    
    private let validationService = ValidationService()
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var login: String = ""
    @Published var password: String = ""
    
    var loginValid = PassthroughSubject<EmailValidationError, Never>()
    var passwordValid = PassthroughSubject<PasswordValidationError, Never>()
    
    init() {
        setupBindings()
    }
    
    func login(with email: String, password: String) -> AnyPublisher<Void, LoginError> {
        return Future<Void, LoginError> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error as? NSError {
                    let errorCode = AuthErrorCode(_nsError: error).code
                    promise(.failure(LoginError(error: errorCode)))
                    return
                }
                
                if result != nil {
                    promise(.success(Void()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func openRegistration() {
        router?.openRegistrationModule()
    }
}

private extension LoginViewModel {
    func setupBindings() {
        $login
            .sink { [weak self] value in
                guard let self else { return }
                let result = self.validateEmail(value)
                self.loginValid.send(result)
            }
            .store(in: &cancellables)
        
        $password
            .sink { [weak self] value in
                guard let self else { return }
                let result = self.validatePassword(value)
                self.passwordValid.send(result)
            }
            .store(in: &cancellables)
    }
    
    func validateEmail(_ value: String) -> EmailValidationError {
        validationService.validateEmail(value: value)
    }
    
    func validatePassword(_ value: String) ->  PasswordValidationError {
        validationService.validatePassword(value: value)
    }
    
}
struct LoginError: Error {
    private let error: AuthErrorCode.Code
    
    init(error: AuthErrorCode.Code) {
        self.error = error
    }
    
    var errorDescription: String {
        switch error {
        case .operationNotAllowed:
            return "Извините, регистрация с использованием электронной почты и пароля в данный момент недоступна. Пожалуйста, попробуйте другой способ аутентификации или свяжитесь с поддержкой."
        case .invalidEmail:
            return "Введённый адрес электронной почты имеет неверный формат. Пожалуйста, проверьте и попробуйте снова."
        case .userDisabled:
            return "Ваша учетная запись была отключена. Пожалуйста, свяжитесь с поддержкой для получения дополнительной информации."
        case .wrongPassword:
            return "Введён неверный пароль. Пожалуйста, проверьте пароль и попробуйте снова."
        default:
            return "Неизвестная ошибка"
        }
    }
}

struct RegistrationError: Error {
    private let error: AuthErrorCode.Code

    init(error: AuthErrorCode.Code) {
        self.error = error
    }

    var errorDescription: String {
        switch error {
        case .invalidEmail:
            return "Введённый адрес электронной почты имеет неверный формат. Пожалуйста, проверьте и попробуйте снова."
        case .emailAlreadyInUse:
            return "Указанный адрес электронной почты уже используется. Проверьте возможные способы входа или используйте другой адрес."
        case .operationNotAllowed:
            return "Извините, регистрация с использованием электронной почты и пароля в данный момент недоступна. Пожалуйста, попробуйте другой способ аутентификации или свяжитесь с поддержкой."
        case .weakPassword:
            return "Введённый пароль слишком слабый. Пожалуйста, используйте более сложный пароль."
        default:
            return "Произошла неизвестная ошибка. Пожалуйста, попробуйте снова позже."
        }
    }
}

