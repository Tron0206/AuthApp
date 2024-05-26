//
//  RegistrationModuleConfigurator.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 26.05.2024.
//

import UIKit

struct RegistrationModuleConfigurator {
    func configure() -> UIViewController {
        let view = RegistrationViewController()
        let viewModel = RegistrationViewModel()
        
        view.viewModel = viewModel
        return view
    }
}
