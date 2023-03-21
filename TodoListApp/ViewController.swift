//
//  ViewController.swift
//  TodoListApp
//
//  Created by 김다진 on 2023/03/21.
//

import UIKit

class ViewController: UIViewController {
    
    var tasks = [Task]() {
        // 연산프로퍼티
        // tasks 배열에 할 일이 추가될 때마다
        // saveTasks가 실행되며 UserDefaults에 할 일 저장
        didSet {
            self.saveTasks()
        }
    }

    // strong으로 선언
    // edit버튼이 done으로 바뀌어도 계속 참조할 수 있도록
    @IBOutlet var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.loadTasks()
    }
    
    // selector로 호출할 메서드를 선언할 땐
    // @objc 를 붙여야 함
    @objc func doneButtonTap(){
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true)
    }
    
    @IBAction func tabEditButton(_ sender: UIBarButtonItem) {
        // 테이블 뷰 비어있으면 리턴
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func tabAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "등록", style: .default,
                                           
                                           // 등록버튼 누르면 실행될 클로저
                                           handler: { [weak self] _ in
            
            // 알럿 내 텍스트 필드의 값을 가져옴
            // alert.textFields?[0].text
            
            // 등록버튼 누르면 tasks의 값들이 하나씩 추가되도록
            guard let title  = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData()

            
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        // configurationHandler 는 알럿을 띄우기 전에
        // textfield를 구성/준비하는 작업을 하는 곳
        alert.addTextField(configurationHandler: {  textField in
            textField.placeholder = "할 일을 입력해주세요."
        })
        self.present(alert, animated: true, completion: nil)
    }

    // UserDefaalts
    // 데이터저장소 (singleton, sharedPreference 같은 거?)
    func saveTasks(){
        let data = self.tasks.map {
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasks")
    }
    
    func loadTasks(){
        let userDefualts = UserDefaults.standard
        guard let data = userDefualts.object(forKey: "tasks") as? [[String: Any]] else { return }
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    // 행의 개수 (필수함수)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    // cellForRowAt: 특정 셀의 n번째 raw를 반환하는 셀을 반환하는 함수 (필수 함수)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        // 스토리보드에서 정의한 셀을 가져올 수 있음
        // 셀을 큐를 사용하여 재사용함
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
    
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    

    // 편집 모드에서 삭제했을 때 어떤 셀이 삭제됐는지 알려줌
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if self.tasks.isEmpty {
            self.doneButtonTap()
        }
    }
    
    // 편집모드에서 할 일 순서 변경
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 셀 위치가 변경되었을 때 어느 인덱스에서(sourceIndexPath) 어느 인덱스로(destinationIndexPath) 이동하는지 알려줌
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // 배열도 그에 맞게 재정렬
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        self.tasks = tasks
    }
}

extension ViewController: UITableViewDelegate {
    // 셀이 선택됐을 때 어떤 셀인지 알려주는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        
        // 선택된 셀만 리로드할 수 있게 구현
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
