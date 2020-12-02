//
//  UserListController.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/12/01.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Nuke

class UserListController: UIViewController {
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startChatButton.layer.cornerRadius = 10
        startChatButton.isEnabled = false
        navigationController?.navigationBar.barTintColor = .rgb(red: 254, green: 60, blue: 114)
        userListTableView.delegate = self
        userListTableView.dataSource = self
        fetchUserInfoFromFirestore()
    
    }
    
    @IBAction func tappedStartChatButton(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let partnerUid = selectedUser?.uid else {return}
        let members = [uid, partnerUid]
        
        let docData = [
            "members": members,
            "latestMessageId": "",
            "createdAt" : Timestamp()
        ] as [String : Any]
        
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in

            if let err = err {
                print("チャットルームの保存に失敗しました。", err)
            } else {
                print("チャットルームの保存に成功しました。")
            }
        }
    }
    
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments{(snapshots, err) in
            if let err = err {
                print("userのデータの取得に失敗しました。\(err)")
            }
                print("user情報の取得に成功しました。")
                snapshots?.documents.forEach({ (snapshot) in
                    let dic = snapshot.data()
                    let user = User.init(dic: dic)
                    user.uid = snapshot.documentID
                   
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    if uid == snapshot.documentID {
                       return
                    }
                    self.users.append(user)
                    self.userListTableView.reloadData()
                })
        }
    }

    
}

extension UserListController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatButton.isEnabled = true
        let user = users[indexPath.row]
        self.selectedUser = user
      
    }
    
}



class UserListTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var user: User? {
        didSet {
            userNameLabel.text = user?.username
            if let url = URL(string: user?.profile_image ?? "") {
                Nuke.loadImage(with: url, into: userImageView, completion: nil)
            }
          
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 22
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


