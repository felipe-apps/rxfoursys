//
//  SavedTasksViewController.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 11/03/25.
//

import UIKit
import RxSwift
import RxCocoa

class SavedTasksViewController: UIViewController {
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let resetButton = UIButton(type: .system)
    private let viewModel = SavedTasksViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchSavedTasks()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Voltar", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Setting up UI elements
    private func setupUI() {
        view.backgroundColor = UIColor.systemGray6
        title = "Tarefas Salvas"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = 8
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        resetButton.setTitle("Resetar Lista", for: .normal)
        resetButton.backgroundColor = .systemBlue
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -20),
        ])
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Adding reset button function
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Reset Button Action
    @objc private func resetButtonTapped() {
        UserDefaults.standard.removeObject(forKey: "savedTasks")
        
        viewModel.fetchSavedTasks()
    }

    // MARK: - Binding ViewModel to View
    private func bindViewModel() {
        
        viewModel.savedTasks
            .observe(on: MainScheduler.instance)
            .map { tasks in
                tasks.filter { $0.isCompleted }
            }
            .bind(to: tableView.rx.items(cellIdentifier: "TaskCell")) { _, task, cell in
                cell.textLabel?.text = task.title
                cell.accessoryType = .checkmark
            }
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.fetchError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Show Error Alert
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Erro", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
