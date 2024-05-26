//
//  ValidationService.swift
//  AuthApp
//
//  Created by Zhasur Sidamatov on 26.05.2024.
//

import Foundation

final class ValidationService {
    func validateEmail(value: String) -> EmailValidationError {
        let atSymbolPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", "@")
        if !atSymbolPredicate.evaluate(with: value) {
            return .missingAtSymbol
        }

        let domainPartPredicate = NSPredicate(format: "SELF MATCHES %@", ".*@.+\\..+")
        if !domainPartPredicate.evaluate(with: value) {
            return .missingDomain
        }

        let emailFormatPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        if !emailFormatPredicate.evaluate(with: value) {
            return .invalidFormat
        }

        return .valid
    }
    
    func validatePassword(value: String) -> PasswordValidationError {
        if value.count < 6 || value.count > 20 {
            return .lenthIncorrect
        }
        
        let digit = CharacterSet.decimalDigits
        if value.rangeOfCharacter(from: digit) == nil {
            return .missingDigit
        }
        
        if value.rangeOfCharacter(from: CharacterSet.whitespaces) != nil {
            return .containsWhitespace
        }
        
        let latinCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+{}[]|\\;:'\",.<>?/`~")
        if value.rangeOfCharacter(from: latinCharacters.inverted) != nil {
            return .containsNonLatinCharacters
        }
        
        return .valid
    }
    
    func validateName(value: String) -> NameValidationError {
        if value.count < 2 {
            return .tooShort
        }
        
        if value.count > 50 {
            return .tooLong
        }
        
        let digitCharacterSet = CharacterSet.decimalDigits
        if value.rangeOfCharacter(from: digitCharacterSet) != nil {
            return .containsDigits
        }
        
        let specialCharacterSet = CharacterSet.letters.union(.whitespaces).inverted
        if value.rangeOfCharacter(from: specialCharacterSet) != nil {
            return .containsSpecialCharacters
        }
        
        return .valid
    }
}

protocol ValidationError {
    var errorMessage: String { get }
}

enum EmailValidationError: ValidationError {
    case missingAtSymbol
    case missingDomain
    case invalidFormat
    case valid
    
    var errorMessage: String {
        switch self {
        case .missingAtSymbol:
            return "Адрес электронной почты должен содержать символ '@'."
        case .missingDomain:
            return "Адрес электронной почты должен содержать доменное имя (например, example@domain.com)."
        case .invalidFormat:
            return "Некорректный формат адреса электронной почты. Проверьте правильность ввода."
        case .valid:
            return ""
        }
    }
}

enum PasswordValidationError: ValidationError {
    case lenthIncorrect
    case missingDigit
    case containsWhitespace
    case containsNonLatinCharacters
    case valid
    
    var errorMessage: String {
        switch self {
        case .lenthIncorrect:
            return "Пароль должен быть от 6 до 20 символов."
        case .missingDigit:
            return "Пароль должен содержать хотя бы одну цифру."
        case .containsWhitespace:
            return "Пароль не должен содержать пробелов."
        case .containsNonLatinCharacters:
            return "Пароль должен содержать только латинские символы."
        case .valid:
            return ""
        }
    }
}

enum NameValidationError: ValidationError {
    case tooShort
    case tooLong
    case containsDigits
    case containsSpecialCharacters
    case valid
    
    var errorMessage: String {
        switch self {
        case .tooShort:
            return "Имя должно быть не менее 2 символов."
        case .tooLong:
            return "Имя должно быть не более 50 символов."
        case .containsDigits:
            return "Имя не должно содержать цифры."
        case .containsSpecialCharacters:
            return "Имя не должно содержать специальные символы."
        case .valid:
            return ""
        }
    }
}
