//
//  LoginViewModel.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 24.05.2024.
//

import Foundation
import Combine

final class LoginViewModel {
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var login: String = ""
    @Published var password: String = ""
    
    init() {
        setupBindings()
    }
}

private extension LoginViewModel {
    func setupBindings() {
        $login
            .sink { [weak self] value in
                guard let self else { return }
                
            }
            .store(in: &cancellables)
    }
    
    func validateEmail(_ value: String) throws {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
