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
        let router = LoginRouter()
        view.viewModel = viewModel
        viewModel.router = router
        router.viewController = view
        
        return UINavigationController(rootViewController: view)
    }
}
