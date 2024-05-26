//
//  AuthTextField.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 24.05.2024.
//

import UIKit
import EasyPeasy

final class AuthTextField: UIView {
    
    enum State {
        case failure
        case success
    }
    
    private(set) var state: State = .success
    
    var attributedPlaceholder: NSAttributedString = NSAttributedString() {
        didSet {
            textField.attributedPlaceholder = attributedPlaceholder
        }
    }
    
    var autocorrectionType: UITextAutocorrectionType = .no {
        didSet {
            textField.autocorrectionType = autocorrectionType
        }
    }
    
    var font: UIFont? = .systemFont(ofSize: 14) {
        didSet {
            textField.font = font
        }
    }
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }
    
    var textColor: UIColor? = .black {
        didSet {
            textField.textColor = textColor
        }
    }
    
    var borderStyle: UITextField.BorderStyle = .none {
        didSet {
            textField.borderStyle = borderStyle
        }
    }
    
    var autocapitalizationType: UITextAutocapitalizationType = .none {
        didSet {
            textField.autocapitalizationType = autocapitalizationType
        }
    }
    
    var isSecureTextEntry: Bool = false {
        didSet {
            textField.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    var rightView: UIView? = nil {
        didSet {
            textField.rightView = rightView
            textField.rightViewMode = .always
        }
    }
    
    var tf: UITextField {
        return self.textField
    }
    
    var text: String {
        return self.textField.text ?? ""
    }
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .red
        lbl.font = .systemFont(ofSize: 12)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setErrorState(message: String) {
        state = .failure
        lineView.backgroundColor = .red
        errorLabel.text = message
    }
    
    func setSuccessState() {
        state = .success
        lineView.backgroundColor = .white
        errorLabel.text = nil
    }
    
    func shakeError() {
        errorLabel.shake()
    }
}

private extension AuthTextField {
    func setupViews() {
        addSubview(textField)
        addSubview(lineView)
        addSubview(errorLabel)
    }
    
    func setupConstraints() {
        textField.easy.layout(
            Top(),
            Leading(),
            Trailing(),
            Height(36)
        )
        
        lineView.easy.layout(
            Top().to(textField, .bottom),
            Leading(),
            Trailing(),
            Height(1)
        )
        
        errorLabel.easy.layout(
            Top(4).to(lineView, .bottom),
            Leading(),
            Trailing(),
            Bottom()
        )
    }
}
