//
//  ViewController.swift
//  LetsChat
//
//  Created by 默司 on 2017/5/16.
//  Copyright © 2017年 默司. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let user = FIRAuth.auth()?.currentUser else {
            // 尚未登入，前往登入、註冊介面
            navigationController?.setViewControllers([AuthViewController()], animated: false)
            return
        }
        
        // 驗證token是否還有效
        user.getTokenWithCompletion {[unowned self] (_, error) in
            if let error = error {
                // TODO: b.顯示錯誤訊息，並前往登入、註冊介面
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                SVProgressHUD.dismiss(withDelay: 3, completion: { 
                    
                })
                return
            }
            
            // TODO: c.token 驗證成功前往聊天室列表
        }
    }
    
    func showAuthViewController() {
        navigationController?.setViewControllers([AuthViewController()], animated: false)
    }
    
    func showRoomListViewController() {
        navigationController?.setViewControllers([RoomListViewController()], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

