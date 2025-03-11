//
//  ViewController.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 24/02/25.
//

import UIKit
import RxSwift
import RxCocoa

class TaskListViewController: UIViewController {
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let showSavedTasksButton = UIButton(type: .system)
    private let viewModel = TaskListViewModel()
    private let disposeBag = DisposeBag()
    var coordinator: AppCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Setting up UI elements
    private func setupUI() {
        view.backgroundColor = UIColor.systemGray6
        title = "Minhas Tarefas"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = 8
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        configureButton(addButton, title: "Adicionar", color: .systemGreen)
        configureButton(saveButton, title: "Salvar", color: .systemBlue)
        configureButton(showSavedTasksButton, title: "Mostrar Tarefas Salvas", color: .systemBlue)
        
        let buttonStack = UIStackView(arrangedSubviews: [addButton, saveButton, showSavedTasksButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.heightAnchor.constraint(equalToConstant: 132).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [tableView, buttonStack])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
    }
    
    // MARK: - Binding ViewModel to View
    private func bindViewModel() {
        viewModel.tasks
            .bind(to: tableView.rx.items(cellIdentifier: "TaskCell")) { _, task, cell in
                cell.textLabel?.text = task.title
                cell.accessoryType = task.isCompleted ? .checkmark : .none
            }
            .disposed(by: disposeBag)
        
        viewModel.tasks
            .map { tasks in tasks.contains { $0.isCompleted } }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.tasks
            .map { tasks in tasks.contains { $0.isCompleted } ? UIColor.systemBlue : UIColor.systemGray }
            .bind(to: saveButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.toggleTaskCompletion(index: indexPath.row)
            })
            .disposed(by: disposeBag)

        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAddTaskAlert()
            })
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .flatMapLatest { [weak self] in
                self?.viewModel.saveCompletedTasks() ?? Completable.empty()
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        showSavedTasksButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.navigateToSavedTasks()
                })
                .disposed(by: disposeBag)

        // Shows alert after saving tasks
        viewModel.saveStatus
            .subscribe(onNext: { [weak self] message in
                DispatchQueue.main.async {
                    self?.showAlert(title: "", message: message)
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


    private func showAddTaskAlert() {
        let alertController = UIAlertController(title: "Nova Tarefa",
                                                message: "Digite o título da tarefa",
                                                preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Título da tarefa"
        }

        let addAction = UIAlertAction(title: "Adicionar", style: .default) { [weak self] _ in
            if let taskTitle = alertController.textFields?.first?.text, !taskTitle.isEmpty {
                self?.viewModel.addTask(title: taskTitle)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
    // MARK: - Navigation
    private func navigateToSavedTasks() {
        coordinator?.navigateToSavedTasks()
    }
}

