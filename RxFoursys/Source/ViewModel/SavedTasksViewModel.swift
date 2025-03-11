//
//  SavedTasksViewModel.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 11/03/25.
//

import RxSwift
import RxCocoa

class SavedTasksViewModel {
    private let disposeBag = DisposeBag()
    var savedTasks = BehaviorRelay<[Task]>(value: [])
    var isLoading = BehaviorRelay<Bool>(value: false)
    var fetchError = PublishSubject<Error>()
    
    // Function that fetches tasks saved in API
    func fetchSavedTasks() {
        isLoading.accept(true)
        
        TaskService.fetchSavedTasks()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] tasks in
                self?.savedTasks.accept(tasks)
                self?.isLoading.accept(false)
            }, onError: { [weak self] error in
                self?.fetchError.onNext(error)
                self?.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
}
