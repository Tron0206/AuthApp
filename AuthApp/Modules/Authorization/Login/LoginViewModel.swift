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
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var login: String = ""
    @Published var password: String = ""
    
    var loginValid = PassthroughSubject<EmailValidationError, Never>()
    
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
    }
    
    func validateEmail(_ value: String) -> EmailValidationError {
        let atSymbolPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", "@")
        if !atSymbolPredicate.evaluate(with: value) {
            return .missingAtSymbol
        }

        let domainPartPredicate = NSPredicate(format: "SELF MATCHES %@", ".*@.+\\..+")
        if !domainPartPredicate.evaluate(with: value) {
            return .missingDomain
        }

        let emailFormatPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        if !emailFormatPredicate.evaluate(with: value) {
            return .invalidFormat
        }

        return .valid
    }
}

enum EmailValidationError {
    case missingAtSymbol
    case missingDomain
    case invalidFormat
    case valid
    
    var errorMessage: String {
        switch self {
        case .missingAtSymbol:
            return "Адрес электронной почты должен содержать символ '@'."
        case .missingDomain:
            return "Адрес электронной почты должен содержать доменное имя (например, example@domain.com)."
        case .invalidFormat:
            return "Некорректный формат адреса электронной почты. Проверьте правильность ввода."
        case .valid:
            return ""
        }
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

