//
//  RegistrationViewModel.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 25.05.2024.
//

import Foundation
import Combine
import FirebaseAuth

final class RegistrationViewModel {
    
    private let validationService = ValidationService()
    
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    var nameIsValid = PassthroughSubject<NameValidationError, Never>()
    var emailIsValid = PassthroughSubject<EmailValidationError, Never>()
    var passwordValid = PassthroughSubject<PasswordValidationError, Never>()
    var confirmIsValid = PassthroughSubject<Bool, Never>()
    
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        setupBindings()
    }
    
    func registration(with email: String, password: String) -> AnyPublisher<Void, RegistrationError> {
        return Future<Void, RegistrationError> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error as? NSError {
                    let errorCode = AuthErrorCode(_nsError: error).code
                    promise(.failure(RegistrationError(error: errorCode)))
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

private extension RegistrationViewModel {
    func setupBindings() {
        $name
            .sink { [weak self] value in
                guard let self else { return }
                let result = self.validateName(value)
                self.nameIsValid.send(result)
            }
            .store(in: &cancellables)
        
        $email
            .sink { [weak self] value in
                guard let self else { return }
                let result = self.validateEmail(value)
                self.emailIsValid.send(result)
            }
            .store(in: &cancellables)
        
        $password
            .sink { [weak self] value in
                guard let self else { return }
                let result = self.validatePassword(value)
                self.passwordValid.send(result)
            }
            .store(in: &cancellables)
        
        $confirmPassword
            .sink { [weak self] value in
                guard let self else { return }
                let result = self.validatePassword(self.password)
                self.passwordValid.send(result)
                self.confirmIsValid.send(self.password == value)
            }
            .store(in: &cancellables)
    }
    
    func validateName(_ value: String) -> NameValidationError {
        validationService.validateName(value: value)
    }
    
    func validateEmail(_ value: String) -> EmailValidationError {
        validationService.validateEmail(value: value)
    }
    
    func validatePassword(_ value: String) -> PasswordValidationError {
        validationService.validatePassword(value: value)
    }
}
