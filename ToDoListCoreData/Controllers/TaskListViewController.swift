//
//  ViewController.swift
//  ToDoListCoreData
//
//  Created by Sergey Runovich on 19.04.22.
//

import UIKit

class TaskListViewController: UITableViewController {

    // MARK: - Private Properties
    private var tasks = StorageManager.shared.fetchData()

    // MARK: - Live Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    // MARK: - Private Methods
    private func configureView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: GlobalStrings.cellID)
        view.backgroundColor = .cyan
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navBarAppearance.backgroundColor = UIColor(
            displayP3Red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )

        navigationController?.navigationBar.tintColor = .black
    }

    @objc private func addNewTask() {
        showAlert()
    }

    private func saveTaskToCoreData(task: String) {
        StorageManager.shared.saveTask(task) { [weak self] task in
            guard let strongSelf = self else { return }
            strongSelf.tasks.append(task)
            strongSelf.tableView.insertRows(
                at: [IndexPath(row: strongSelf.tasks.count - 1, section: 0)],
                with: .automatic
            )
        }
    }
}

extension TaskListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = tableView.dequeueReusableCell(withIdentifier: GlobalStrings.cellID, for: indexPath)
        taskCell.backgroundColor = .clear
        taskCell.selectionStyle = .none

        let task = tasks[indexPath.row]
        taskCell.textLabel?.text = task.info

        return taskCell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = UIContextualAction(
            style: .normal,
            title: "") { contextualAction, view, boolValue in
                let task = self.tasks[indexPath.row]
                self.showAlert(task: task) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        item.image = UIImage(systemName: "list.bullet")
        item.backgroundColor = .clear
        let swipeActions = UISwipeActionsConfiguration(actions: [item])

        return swipeActions
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]

        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.deleteTask(task)
        }
    }
}

// MARK: - Custom Alert Controller
extension TaskListViewController {

    private func showAlert(task: Task? = nil, completion: (() -> Void)? = nil) {

        let title = task != nil ? "Do you want change it?" : "Add new Task"

        let alert = TaskAlertController(
            title: title,
            message: "What do prefer?",
            preferredStyle: .alert
        )

        alert.addTask(task: task) { info in
            if let task = task, let completion = completion {
                StorageManager.shared.editTask(task, newName: info)
                completion()
            } else {
                self.saveTaskToCoreData(task: info)
            }
        }

        present(alert, animated: true)
    }
}
