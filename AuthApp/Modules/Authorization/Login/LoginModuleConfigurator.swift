//
//  LoginModuleConfigurator.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 24.05.2024.
//

import UIKit

struct LoginModuleConfigurator {
    func configure() -> UIViewController {
        let view = LoginViewController()
        let viewModel = LoginViewModel()
        view.viewModel = viewModel
        
        return view
    }
}
