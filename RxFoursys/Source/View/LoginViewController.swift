//
//  LoginViewController.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 25/02/25.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    var onLoginSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGray6
        
        title = "Bem-vindo"
        
        configureTextField(emailTextField, placeholder: "Email", isSecure: false)
        configureTextField(passwordTextField, placeholder: "Senha", isSecure: true)

        loginButton.setTitle("Entrar", for: .normal)
        loginButton.backgroundColor = UIColor.systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.layer.cornerRadius = 8
        loginButton.isEnabled = false
        loginButton.setHeight(44)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String, isSecure: Bool) {
        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = isSecure
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.systemGray3.cgColor
        textField.layer.borderWidth = 1
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .darkGray
        textField.setHeight(44)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    private func bindViewModel() {
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        viewModel.isLoginEnabled
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isLoginEnabled
            .map { $0 ? UIColor.systemBlue : UIColor.systemGray }
            .bind(to: loginButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.loginUser()
            })
            .disposed(by: disposeBag)
        
        viewModel.loginSuccess
            .subscribe(onNext: { [weak self] in
                self?.onLoginSuccess?()
            })
            .disposed(by: disposeBag)
        
        viewModel.loginError
            .subscribe(onNext: { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            })
            .disposed(by: disposeBag)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UIView {
    func setHeight(_ height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
