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

    // 存取資料庫用參考
    var ref: FIRDatabaseReference!
    var roomNameField: UITextField!
    var createRoomButton: UIButton!
    var roomListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "房間列表"
        
        // 取得存取節點
        ref = FIRDatabase.database().reference().child("rooms")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createRoom(with roomName: String) {
        let newRoom = ref.childByAutoId()
        
        newRoom.setValue(["name": roomName])
    }
    
    func createRoom(_ sender: Any) {
        
    }
    
    func setupUI() {
        roomNameField = UITextField()
        roomNameField.placeholder = "輸入房間名稱"
        roomNameField.autocapitalizationType = .none
        roomNameField.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7)
        
        createRoomButton = UIButton(type: .system)
        createRoomButton.setTitle("新增", for: .normal)
        
        let container = UIStackView(arrangedSubviews: [roomNameField, createRoomButton])
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alignment = .center
        container.axis = .horizontal
        container.spacing = 4
        
        container.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
        container.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        container.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
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
