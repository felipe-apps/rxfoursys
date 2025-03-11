//
//  AppCoordinator.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 25/02/25.
//

import UIKit

class AppCoordinator {
    private let window: UIWindow?
    private let navigationController: UINavigationController

    init(window: UIWindow?) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        let loginVC = LoginViewController()
        loginVC.onLoginSuccess = { [weak self] in
            self?.showTaskList()
        }
        
        navigationController.viewControllers = [loginVC]
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    private func showTaskList() {
        let taskListVC = TaskListViewController()
        taskListVC.coordinator = self
        navigationController.setViewControllers([taskListVC], animated: true)
    }
    
    func navigateToSavedTasks() {
        let savedTasksViewController = SavedTasksViewController()
        
        // Translating Back button to portuguese
        if let topViewController = navigationController.topViewController {
            topViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Voltar", style: .plain, target: nil, action: nil)
        }
        
        navigationController.pushViewController(savedTasksViewController, animated: true)
    }
}
