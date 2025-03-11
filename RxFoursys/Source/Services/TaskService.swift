//
//  TaskService.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 11/03/25.
//

import Foundation
import RxSwift

class TaskService {

    static func saveCompletedTasks(_ tasks: [Task]) -> Completable {
        return Completable.create { completable in
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let jsonData = try JSONEncoder().encode(tasks)
                request.httpBody = jsonData
            } catch {
                completable(.error(error))
                return Disposables.create()
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completable(.error(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completable(.error(NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    return
                }

                if httpResponse.statusCode == 201 {
                    // Após o sucesso no servidor, salve localmente
                    TaskService.saveTasksToUserDefaults(tasks)

                    // Após salvar localmente, faça o fetch das tasks
                    let savedTasks = TaskService.fetchSavedTasks()
                    print("Tasks salvas localmente após o POST:", savedTasks)

                    completable(.completed)
                } else {
                    completable(.error(NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response"])))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    static func saveTasksToUserDefaults(_ newTasks: [Task]) {
            var savedTasks = fetchSavedTasksSync()

            savedTasks.append(contentsOf: newTasks)

            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(savedTasks) {
                UserDefaults.standard.set(encoded, forKey: "savedTasks")
            }
        }
    
    static func fetchSavedTasksSync() -> [Task] {
            if let savedData = UserDefaults.standard.data(forKey: "savedTasks"),
               let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedData) {
                return decodedTasks
            }
            return []
        }

    static func fetchSavedTasks() -> Observable<[Task]> {
            return Observable.create { observer in
                let tasks = fetchSavedTasksSync() 
                observer.onNext(tasks)
                observer.onCompleted()
                return Disposables.create()
            }
        }
}
