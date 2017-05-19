//
//  AuthViewController.swift
//  LetsChat
//
//  Created by 默司 on 2017/5/16.
//  Copyright © 2017年 默司. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth

class AuthViewController: UIViewController {

    // Email輸入框
    var emailField: UITextField!
    // 密碼輸入框
    var passwordField: UITextField!
    // 登入按鈕
    var loginButton: UIButton!
    // 註冊按鈕
    var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "使用者驗證"
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 登入按鈕事件
    func login(_ sender: Any) {
        // 實作登入流程
        guard validateFields(), let email = emailField.text, let password = passwordField.text else {
            return
        }
        
        SVProgressHUD.show(withStatus: "登入中...")
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {[unowned self] (user, error) in
            SVProgressHUD.dismiss()
            
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                SVProgressHUD.dismiss(withDelay: 2)
            } else {
                UserDefaults.standard.set(user!.email, forKey: "user-email")
                
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "RoomListViewController") {
                    self.navigationController?.setViewControllers([vc], animated: true)
                }
            }
        })
    }
    
    /// 註冊按鈕事件
    func register(_ sender: Any) {
        // 實作註冊流程
        guard validateFields(), let email = emailField.text, let password = passwordField.text else {
            return
        }
        
        SVProgressHUD.show(withStatus: "註冊中...")
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {[unowned self] (user, error) in
            SVProgressHUD.dismiss()
            
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                SVProgressHUD.dismiss(withDelay: 2)
            } else {
                self.login(sender)
            }
        })
    }
    
    /// UI初始化、設定、排版
    func setupUI() {
        emailField = UITextField(frame: .zero)
        emailField.placeholder = "請輸入電子郵件"
        emailField.borderStyle = .roundedRect
        emailField.autocapitalizationType = .none // 取消自動字首大寫
        
        passwordField = UITextField(frame: .zero)
        passwordField.placeholder = "請輸入密碼"
        passwordField.isSecureTextEntry = true // 輸入內容自動遮蓋
        passwordField.borderStyle = .roundedRect
        
        loginButton = UIButton(type: .system)
        loginButton.setTitle("登入", for: .normal)
        loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        
        registerButton = UIButton(type: .system)
        registerButton.setTitle("註冊", for: .normal)
        registerButton.addTarget(self, action: #selector(register(_:)), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [emailField, passwordField, loginButton, registerButton])
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical //Stack方向
        stackView.spacing = 8 //間距
        
        // 上下左右置中
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        // 寬度設定為畫面的 70%
        // 高度會因內容而自動展開
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7, constant: 0).isActive = true
    }
    
    func isEmail(text: String?) -> Bool {
        guard let text = text else {
            return false
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
    
    func isNotEmpty(text: String?) -> Bool {
        return !(text?.isEmpty ?? true)
    }
    
    func validateFields() -> Bool {
        guard isNotEmpty(text: passwordField.text) && isEmail(text: emailField.text) else {
            SVProgressHUD.showError(withStatus: "請正確填寫Email和密碼")
            SVProgressHUD.dismiss(withDelay: 2)
            return false
        }
        
        return true
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
