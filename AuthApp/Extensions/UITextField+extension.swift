//
//  UIButton+extension.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 24.05.2024.
//

import UIKit
import Combine

extension UITextField {
    var editingDidEndPublisher: AnyPublisher<Void, Never> {
        controlEventPublisher(for: .editingDidEnd)
    }
}
