//
//  ChatListViewController.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/11/27.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Nuke

class ChatListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    private var chatRooms = [ChatRoom]()
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        confirmLoggedInUser()
        fetchLoginUserInfo()
        fetchChatRoomsInfoFromFirestore()
    }
    
    private func fetchChatRoomsInfoFromFirestore() {
        Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (snapshots, err) in
                if let err = err {
                    print("Firestoreからルーム情報の取得に失敗しました。", err)
                    return
                }
                
                snapshots?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                    case .modified,.removed:
                        print("nothing to do")
                    }
                })
                
               
            }
    }
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        let chatRoom = ChatRoom.init(dic: dic)
        chatRoom.documentId = documentChange.document.documentID
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let isContain = chatRoom.members.contains(uid)
        
        if !isContain {return}
        
        chatRoom.members.forEach{(memberUid) in
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument { (partnerSnapshot, err) in
                    if let err = err {
                        print("パートナー情報の取得に失敗しました。", err)
                    }
                    
                    guard let dic = partnerSnapshot?.data() else {return}
                    let user = User(dic: dic)
                    chatRoom.partnerUser = user
                    user.uid = documentChange.document.documentID
                    
                    guard let chatRoomId = chatRoom.documentId else {return}
                    let latestMessageId = chatRoom.latestMessageId
                    
                    if latestMessageId == "" {
                        self.chatRooms.append(chatRoom)
                        self.chatListTableView.reloadData()
                        return
                    }
                    
                    Firestore.firestore().collection("chatRooms").document(chatRoom.documentId ?? "").collection("messages").document(latestMessageId).getDocument { (latestMessageSnapshot, err) in
                        if let err = err {
                            print("最新のメッセージの取得に失敗しました。", err)
                            return
                        }
                        
                        guard let dic = latestMessageSnapshot?.data()  else {return}
                        let message = Message(dic: dic)
                        chatRoom.latestMessage = message
                    
                        self.chatRooms.append(chatRoom)
                        self.chatListTableView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    private func setUpViews() {
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 254, green: 60, blue: 114)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        let rightBarButton = UIBarButtonItem(title: "チャット", style: .plain, target: self, action: #selector(tapperNavRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc private func tapperNavRightBarButton() {
        let storyboard = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListController = storyboard.instantiateViewController(withIdentifier: "UserListController")
        let nav = UINavigationController(rootViewController: userListController)
        self.present(nav, animated: true, completion: nil)
    }
    
    
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            let storyboard = UIStoryboard.init(name: "SignUp", bundle: nil)
            let signUpViewController = storyboard.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            self.present(signUpViewController, animated: true, completion: nil)
        }
    }
    
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument{(snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。", err)
            }else {
                guard let dic = snapshot?.data() else {return}
                self.user = User.init(dic: dic)
                
            }
        }
        
    }
    
}



//MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatRooms[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.user = user
        chatRoomViewController.chatroom = chatRooms[indexPath.row]
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
    
}


class ChatListTableViewCell: UITableViewCell {
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                partnerLabel.text = chatroom.partnerUser?.username
                
                let url = URL(string: chatroom.partnerUser?.profile_image ?? "")
                Nuke.loadImage(with: url as! ImageRequestConvertible, into: userImageView)
                dateLabel.text = dateFomatterForDateLabel(date: chatroom.latestMessage?.createdAt.dateValue() ?? Date())
                latestMessageLabel.text = chatroom.latestMessage?.message
            }
        }
    }
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 35
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateFomatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
