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

    var emailField: UITextField!
    var passwordField: UITextField!
    var loginButton: UIButton!
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
    
    func setupUI() {
        emailField = UITextField(frame: .zero)
        emailField.placeholder = "請輸入電子郵件"
        emailField.borderStyle = .roundedRect
        
        passwordField = UITextField(frame: .zero)
        passwordField.placeholder = "請輸入密碼"
        passwordField.isSecureTextEntry = true
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
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7, constant: 0).isActive = true
        
        // 高度會因為內容而自動展開
    }
    
    func login(_ sender: Any) {
        // 實作登入流程
        if validateFields() {
            FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: {[unowned self] (user, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    SVProgressHUD.dismiss(withDelay: 2)
                } else {
                    UserDefaults.standard.set(user!.email, forKey: "user-email")
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "RoomListViewController")
                    
                    self.navigationController?.setViewControllers([vc!], animated: true)
                }
            })
        }
    }
    
    func register(_ sender: Any) {
        // 實作註冊流程
        if validateFields() {
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: {[unowned self] (user, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    SVProgressHUD.dismiss(withDelay: 2)
                } else {
                    self.login(sender)
                }
            })
        }
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
        return text?.isEmpty ?? false
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
