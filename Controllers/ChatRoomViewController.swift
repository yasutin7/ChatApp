//
//  ChatRoomViewController.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/11/28.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChatRoomViewController: UIViewController {
    
    var chatroom: ChatRoom?
    var user: User?
    let cellId = "cellId"
    
    var messsages = [Message]()
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
     
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
        
    }()
    @IBOutlet var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 50, right: 0)
        fetchMessages()
        
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessages() {
        guard let chatRoomDocId = chatroom?.documentId else {return}
        Firestore.firestore().collection("chatRooms").document(chatRoomDocId).collection("messages").addSnapshotListener { [self] (snapshots, err) in
            if let err = err {
                print("メッセージ情報の取得に失敗しました。", err)
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = chatroom?.partnerUser
                    self.messsages.append(message)
                    self.messsages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date < m2Date
                    }
                self.chatRoomTableView.reloadData()
                    self.chatRoomTableView.scrollToRow(at: IndexPath(row: messsages.count-1, section: 0), at: .bottom, animated: true)
                case .modified,.removed:
                    print("nothing to do")
                }
            })
        }
    }
}


extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    
    private func addMessageToFirestore(text: String) {
        guard let chatRoomDocId = chatroom?.documentId else {return}
        guard let name = user?.username else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        chatInputAccessoryView.removeText()
        
        let messageId = randomSetId(length: 20)
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        Firestore.firestore().collection("chatRooms").document(chatRoomDocId).collection("messages").document(messageId).setData(docData) {(err) in
            if let err = err {
                print("メッセージの保存に失敗しました。", err)
                return
            }
            
          
            let latestMessageDate =  [
                "latestMessageId": messageId
            ]
            Firestore.firestore().collection("chatRooms").document(chatRoomDocId).updateData(latestMessageDate) {(err) in
                if let err = err {
                    print("最新のメッセージの保存に失敗しました。", err)
                    return
                }
                
                print("メッセージの保存に成功しました")
                
            }
        }
    }
    
    private func randomSetId(length: Int) -> String {
        let letters : NSString =  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomSetId = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomSetId += NSString(characters: &nextChar, length: 1) as String
        }
        return randomSetId
    }
    
    
}

//MARK - UITableViewDelegate, UITableViewDataSource
extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messsages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatRoomTableViewCell
        
        cell.message = messsages[indexPath.row] 
        return cell
    }
    
    
    
}
