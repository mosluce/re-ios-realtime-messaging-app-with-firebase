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
    var messages = [[String: Any]]()
    // 訊息記錄節點
    var messageRef: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        edgesForExtendedLayout = []
        
        messageRef = FIRDatabase.database().reference().child("messages/\(roomID!)")
        messageRef.observeSingleEvent(of: .value, with: {[unowned self] (snapshot) in
            
            // messages 架構為
            // messageId1
            // |- messageData1
            // messageId2
            // |- messageData2
            guard let messagesCollection = snapshot.value as? [String: [String: Any]] else {
                return
            }
            
            messagesCollection.forEach({ (msgId, msgData) in
                var message = msgData
                message["id"] = msgId
                self.messages.append(message)
            })
            
            self.collectionView?.reloadData()
            self.messageRef.observe(.childAdded, with: {[weak self] (snapshot) in
                guard let msgData = snapshot.value as? [String: Any], let senderId = msgData["senderId"] as? String else {
                    return
                }
                
                if senderId == self?.senderId() {
                    return
                }
                
                var message = msgData
                message["id"] = snapshot.key
                
                self?.messages.append(message)
                self?.finishReceivingMessage()
            })
        })
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
        let message = [
            "senderId": senderId,
            "senderDisplayName": senderDisplayName,
            "date": date.timeIntervalSince1970,
            "text": text
        ] as [String : Any];
        
        self.messages.append(message)
        
        messageNode.setValue(message) {[weak self] (error, _) in
            self?.finishSendingMessage()
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

extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        let message = messages[indexPath.item]
        
        guard let text = message["text"] as? String,
            let senderId = message["senderId"] as? String,
            let senderDisplayName = message["senderDisplayName"] as? String,
            let interval = message["date"] as? TimeInterval
            else { fatalError("data format exception") }
        
        let date = Date(timeIntervalSince1970: interval)
        
        return JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.green)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
}
