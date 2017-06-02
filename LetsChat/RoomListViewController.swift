//
//  RoomListViewController.swift
//  LetsChat
//
//  Created by 默司 on 2017/5/16.
//  Copyright © 2017年 默司. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseDatabase

class RoomListViewController: UIViewController {

    // 存取聊天室房間資料庫用參考
    var roomsRef: FIRDatabaseReference!
    
    // 聊天室名稱欄位
    var roomNameField: UITextField!
    // 聊天室建立按鈕
    var createRoomButton: UIButton!
    
    var roomListTableView: UITableView!
    var rooms = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "房間列表"
        
        setupUI()
        
        // 存取聊天室房間資料庫用參考
        roomsRef = FIRDatabase.database().reference().child("rooms")
        // 觀察房間是否有增加
        roomsRef.observe(.childAdded, with: {[weak self] (snapshot) in
            let roomID = snapshot.key
            if let roomData = snapshot.value as? [String: String] {
                var data = roomData
                data["id"] = roomID
                
                // 以下順序重要
                // 1. 先對 datasource 進行操作
                self?.rooms.append(data)
                
                let lastIndex = (self?.rooms.count ?? 0) - 1
                
                guard lastIndex >= 0 else { return }
                
                // 2. 告知tableView開始更新
                self?.roomListTableView.beginUpdates()
                // 3. 進行更新 (除了insert，另外還有 delete 和 update 可以進行操作)
                self?.roomListTableView.insertRows(at: [IndexPath(row: lastIndex, section: 0)], with: UITableViewRowAnimation.automatic)
                // 4. 告知tableView結束更新
                self?.roomListTableView.endUpdates()
            }
        })
        
    }
    
    deinit {
        roomsRef.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createRoom(_ sender: Any) {
        // 如果 roomName 沒有填寫就不繼續
        guard let roomName = roomNameField.text, !roomName.isEmpty else {
            return
        }
        
        // 建立一個 Room
        // 結構為
        // RoomID - 自動產生
        // |-- RoomData - 下面setValue的對象
        let newRoom = roomsRef.childByAutoId()
        
        newRoom.setValue(["name": roomName]) {[unowned self] (error, _) in
            if let error = error {
                print(error)
            }
            
            // 清除房間名稱欄位
            self.roomNameField.text = nil
        }
    }
    
    func setupUI() {
        // 灰色底色的容器
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = UIColor.lightGray
        
        view.addSubview(bar)
        bar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        roomNameField = UITextField()
        roomNameField.placeholder = "輸入房間名稱"
        roomNameField.autocapitalizationType = .none
        roomNameField.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7)
        
        createRoomButton = UIButton(type: .system)
        createRoomButton.setTitle("新增", for: .normal)
        createRoomButton.addTarget(self, action: #selector(createRoom(_:)), for: .touchUpInside)
        
        // 使用StackView簡化排版
        let container = UIStackView(arrangedSubviews: [roomNameField, createRoomButton])
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alignment = .center
        container.axis = .horizontal
        container.spacing = 4
        
        bar.addSubview(container)
        
        container.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -4).isActive = true
        container.leftAnchor.constraint(equalTo: bar.leftAnchor, constant: 4).isActive = true
        container.rightAnchor.constraint(equalTo: bar.rightAnchor, constant: -4).isActive = true
        container.topAnchor.constraint(equalTo: bar.topAnchor, constant: 4).isActive = true
        
        roomListTableView = UITableView(frame: .zero, style: .plain)
        roomListTableView.delegate = self
        roomListTableView.dataSource = self
        
        // 設定Layout
        view.addSubview(roomListTableView)
        
        roomListTableView.translatesAutoresizingMaskIntoConstraints = false
        roomListTableView.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        roomListTableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        roomListTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        roomListTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // 註冊稍後要使用的Cell型別
        roomListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "RoomCell")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension RoomListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 使用先前註冊的Cell名稱取出可重複使用的Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
        cell.textLabel?.text = rooms[indexPath.row]["name"]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let roomData = rooms[indexPath.row]
        let roomID = roomData["id"]
        
    }
}
