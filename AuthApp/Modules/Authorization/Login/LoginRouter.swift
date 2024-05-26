//
//  LoginRouter.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 25.05.2024.
//

import UIKit

final class LoginRouter {
    var viewController: UIViewController?
    
    func openRegistrationModule() {
        let registrationModule = RegistrationModuleConfigurator().configure()
        viewController?.navigationController?.pushViewController(registrationModule, animated: true)
    }
}
