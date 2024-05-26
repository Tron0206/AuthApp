//
//  UIViewController+extension.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 25.05.2024.
//

import UIKit

extension UIViewController {
    func setupEndEditingGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
}

private extension UIViewController {
    @objc
    func viewTapped() {
        view.endEditing(true)
    }
}
