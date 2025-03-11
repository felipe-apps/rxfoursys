//
//  Task.swift
//  RxFoursys
//
//  Created by Felipe Ferreira on 25/02/25.
//

import Foundation

struct Task: Codable {
    let id: Int?
    var title: String
    var isCompleted: Bool

    init(id: Int?, title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

