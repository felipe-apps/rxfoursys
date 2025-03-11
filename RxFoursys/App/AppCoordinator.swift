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
        navigationController.setViewControllers([taskListVC], animated: true)
    }
}
