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
    
    lazy var incomingBubbleImage: JSQMessageBubbleImageDataSource = {[unowned self] in
        let factory = JSQMessagesBubbleImageFactory()
        return factory.incomingMessagesBubbleImage(with: UIColor.darkGray)
    }()
    
    lazy var outgoingBubbleImage: JSQMessageBubbleImageDataSource = {[unowned self] in
        let factory = JSQMessagesBubbleImageFactory()
        return factory.outgoingMessagesBubbleImage(with: UIColor.lightGray)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        edgesForExtendedLayout = []
        
        messageRef = FIRDatabase.database().reference().child("messages/\(roomID!)")
        messageRef.queryOrdered(byChild: "date").observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            
            if !snapshot.hasChildren() { return }
            
            // messages 架構為
            // messageId1
            // |- messageData1
            // messageId2
            // |- messageData2
            snapshot.children.forEach({ (child) in
                guard let childSnap = child as? FIRDataSnapshot else { return }
                
                guard let msgData = childSnap.value as? [String: Any] else { return }
                
                let msgId = childSnap.key
                var message = msgData
                message["id"] = msgId
                self?.messages.append(message)
            })
            
            self?.collectionView?.reloadData()
            
            guard let interval = self?.messages.last?["date"] as? TimeInterval else { return }
            
            self?.messageRef.queryOrdered(byChild: "date").queryStarting(atValue: interval + 0.001).observe(.childAdded, with: {[weak self] (snapshot) in
                
                guard let msgData = snapshot.value as? [String: Any], let senderId = msgData["senderId"] as? String else {
                    return
                }
                
                // 如果是自己傳的訊息就跳過 (因未之前傳送訊息時就有加入dataSource了)
                if senderId == self?.senderId() {
                    return
                }
                
                var message = msgData
                message["id"] = snapshot.key
                
                self?.messages.append(message)
                self?.finishReceivingMessage()
            })
        })
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
    }
    
    deinit {
        messageRef.removeAllObservers()
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
        let message = messages[indexPath.item]
        
        if message["senderId"] as? String == self.senderId() {
            return outgoingBubbleImage
        } else {
            return incomingBubbleImage
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        
        let message = messages[indexPath.item]
        
        if message["senderId"] as? String == self.senderId() {
            return nil
        }
        
        guard let displayName = message["senderDisplayName"] as? String else {
            return NSAttributedString(string: "未知")
        }
        
        return NSAttributedString(string: displayName)
    }
}
