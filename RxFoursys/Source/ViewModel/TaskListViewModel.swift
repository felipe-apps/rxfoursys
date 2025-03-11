//
//  TaskListViewModel.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 25/02/25.
//

import RxSwift
import RxCocoa

class TaskListViewModel {
    private let disposeBag = DisposeBag()
    var tasks = BehaviorRelay<[Task]>(value: [])
    let saveStatus = PublishSubject<String>()
    
    func addTask(title: String) {
        var currentTasks = tasks.value
        currentTasks.append(Task(id: UUID().hashValue, title: title))
        tasks.accept(currentTasks)
    }
    
    func toggleTaskCompletion(index: Int) {
        var currentTasks = tasks.value
        currentTasks[index].isCompleted.toggle()
        tasks.accept(currentTasks)
    }
    
    private func removeCompletedTasks() {
        let remainingTasks = tasks.value.filter { !$0.isCompleted }
        tasks.accept(remainingTasks)
    }
    
    // Function that saves completed tasks to API and Locally
    func saveCompletedTasks() -> Completable {
        let completedTasks = tasks.value.filter { $0.isCompleted }
        
        guard !completedTasks.isEmpty else {
            saveStatus.onNext("Nenhuma tarefa concluída para salvar.")
            return Completable.empty()
        }
        
        return TaskService.saveCompletedTasks(completedTasks)
            .do(
                onError: { [weak self] error in
                    self?.saveStatus.onNext("Erro ao salvar tarefas: \(error.localizedDescription)")
                },
                onCompleted: { [weak self] in
                    self?.removeCompletedTasks()
                    self?.saveStatus.onNext("Tarefas concluídas salvas com sucesso!")
                }
            )
    }
}

