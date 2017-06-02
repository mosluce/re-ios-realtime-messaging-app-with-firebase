//
//  ChatViewController.swift
//  LetsChat
//
//  Created by 默司 on 2017/6/2.
//  Copyright © 2017年 默司. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {
    
    // 房間ID用來讀取該房間的訊息
    var roomID: String!
    // 房間名稱
    var roomName: String!
    // 訊息資料
    var messages = [[String: String]]()
    // 訊息記錄節點
    var messageRef: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        messageRef = FIRDatabase.database().reference().child("messages/\(roomID!)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func senderId() -> String {
        return FIRAuth.auth()?.currentUser?.uid ?? ""
    }
    
    override func senderDisplayName() -> String {
        return FIRAuth.auth()?.currentUser?.displayName ?? FIRAuth.auth()?.currentUser?.email ?? ""
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        // 實作傳送訊息
        let messageNode = messageRef.childByAutoId()
        
        messageNode.setValue([
            "senderId": senderId,
            "senderDisplayName": senderDisplayName,
            "date": date.timeIntervalSince1970 * 1000
        ]) {[unowned self] (error, _) in
            self.finishSendingMessage()
        }
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
