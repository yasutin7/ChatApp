//
//  LoginViewController.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/12/05.
//

import UIKit
import Firebase
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backToSignUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 15
        loginButton.isEnabled = true
        loginButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
       
        backToSignUpButton.addTarget(self, action: #selector(tappedBackToSignUpButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
    }
    
    @objc private func tappedBackToSignUpButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedLoginButton() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        HUD.show(.progress)
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                HUD.hide()
                print("ログイン認証に失敗しました。", err)
                return
            }
            HUD.hide()
            
            let nav = self.presentingViewController as! UINavigationController
            let chatListViewController = nav.viewControllers[nav.viewControllers.count-1] as? ChatListViewController
            chatListViewController?.fetchChatRoomsInfoFromFirestore()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}



