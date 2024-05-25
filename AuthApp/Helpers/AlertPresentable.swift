//
//  AlertPresentable.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 25.05.2024.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, description: String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alert, animated: true)
    }
}
