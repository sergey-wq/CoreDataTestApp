//
//  Extension + Alert.swift
//  ToDoListCoreData
//
//  Created by Sergey Runovich on 19.04.22.
//

import UIKit

class TaskAlertController: UIAlertController {

    func addTask(task: Task?, completion: @escaping (String) -> Void) {

        let saveButtonAction = UIAlertAction(
            title: "Save",
            style: .default) { _ in
                guard let newElement = self.textFields?.first?.text else { return }
                guard !newElement.isEmpty else { return }
                completion(newElement)
            }

        let cancelButtonAction = UIAlertAction(title: "Cancel", style: .destructive)

        addAction(saveButtonAction)
        addAction(cancelButtonAction)
        addTextField { textField in
            textField.placeholder = "New Task"
            textField.text = task?.info
        }
    }
}
