//
//  LoginViewModel.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 25/02/25.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

class LoginViewModel {
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let isLoginEnabled: Observable<Bool>
    
    let loginSuccess = PublishSubject<Void>()
    let loginError = PublishSubject<String>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        // The login button is only enabled if the fields are filled
        isLoginEnabled = Observable.combineLatest(email, password) { !$0.isEmpty && !$1.isEmpty }
    }

    // Authenticating in Firebase
    func loginUser() {
        let email = email.value
        let pass = password.value
        
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] result, error in
            if let error = error as NSError? {
                let errorMessage = self?.mapAuthError(error) ?? "Ocorreu um erro desconhecido."
                self?.loginError.onNext(errorMessage)
            } else {
                self?.loginSuccess.onNext(())
            }
        }
    }

    // Function that maps Firebase errors
    private func mapAuthError(_ error: NSError) -> String {
        guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
            return "Ocorreu um erro desconhecido."
        }

        switch errorCode {
        case .invalidEmail:
            return "O email inserido é inválido."
        case .wrongPassword:
            return "A senha está incorreta."
        case .invalidCredential:
            return "Nenhuma conta encontrada para este email."
        case .networkError:
            return "Problema de conexão. Verifique sua internet."
        case .tooManyRequests:
            return "Muitas tentativas de login. Tente novamente mais tarde."
        case .userDisabled:
            return "Esta conta foi desativada."
        default:
            return "Erro ao tentar fazer login. Tente novamente."
        }
    }

}

