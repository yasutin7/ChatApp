//
//  SignUpViewController.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/11/30.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet var alreadyHaveAccountButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        registerButton.layer.cornerRadius = 15
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        userNameTextField.delegate = self
        
    }
    
    @IBAction func tappedProfileImageButton(_ sender: Any) {
       let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func tappedRegisterButton(_ sender: Any) {
        guard let image = profileImageButton.imageView?.image else {return}
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else {return}
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("画像の保存に失敗しました。 \(err)")
            }else {
                print("画像の保存に成功しました。")
                storageRef.downloadURL{ [self](url,err) in
                    if let err = err {
                        print("firestorageからのダウンロードに失敗しました。\(err)")
                    }else {
                        guard let urlString = url?.absoluteString else {return}
                        print("urlString \(urlString)")
                        createUserToFirestore(profile_image: urlString)
                    }
                    
                }
            }
        }
    }
    
    private func createUserToFirestore(profile_image: String) {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().createUser(withEmail: email, password: password) { [self](res, err ) in
            if let err = err {
                print("認証情報の登録に失敗しました。　\(err)")
                return
            }
            
            guard let uid = res?.user.uid else {return}
            guard let username = userNameTextField.text else {return}
            let docData = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "profile_image": profile_image
            ] as [String : Any]
            
            Firestore.firestore().collection("users").document(uid).setData(docData) {(err) in
                if let err = err {
                    print("データベースへの保存に失敗しました。\(err)")
                }
                
            }
            
        }
        
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty =  passwordTextField.text?.isEmpty ?? false
        let userNameIsEmpty = userNameTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || userNameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
       
    }
}


extension SignUpViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal),for: .normal)
        }
        
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
}
