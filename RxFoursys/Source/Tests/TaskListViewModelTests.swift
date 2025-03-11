//
//  TaskListViewModelTests.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 25/02/25.
//

import XCTest
import RxSwift
@testable import RxFoursys

class TaskListViewModelTests: XCTestCase {
    var viewModel: TaskListViewModel!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        viewModel = TaskListViewModel()
        disposeBag = DisposeBag()
    }

    func testAddTask() {
        let taskTitle = "Test Task"
        viewModel.addTask(title: taskTitle)
        
        XCTAssertEqual(viewModel.tasks.value.count, 1)
        XCTAssertEqual(viewModel.tasks.value.first?.title, taskTitle)
    }

    func testToggleTaskCompletion() {
        viewModel.addTask(title: "Task")
        viewModel.toggleTaskCompletion(index: 0)

        XCTAssertTrue(viewModel.tasks.value[0].isCompleted)
    }
}

