//
//  ChatRoomTableCell.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/11/28.
//

import UIKit
import Firebase
import Nuke

class ChatRoomTableViewCell: UITableViewCell {
    
    var message: Message? {
        didSet {
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var partnerMessageTextViewWidth: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var myMessageTextViewWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30
        partnerMessageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichUserMessage()
    }
    
    private func checkWhichUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        if uid == message?.uid {
            partnerMessageTextView.isHidden = true
            userImageView.isHidden = true
            partnerDateLabel.isHidden = true
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false
            if let message = message {
                myMessageTextView.text = message.message
                let width = estimateFrameTextView(text: message.message).width + 20
                myMessageTextViewWidth.constant = width
                myDateLabel.text = dateFomatterForDateLabel(date: message.createdAt.dateValue())
            }
        } else {
            partnerMessageTextView.isHidden = false
            userImageView.isHidden = false
            partnerDateLabel.isHidden = false
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true
            
            if let urlString = message?.partnerUser?.profile_image, let url = URL(string: urlString){
                Nuke.loadImage(with: url, into: userImageView)
            }
            if let message = message {
                partnerMessageTextView.text = message.message
                let width = estimateFrameTextView(text: message.message).width + 20
                partnerMessageTextViewWidth.constant = width
                partnerDateLabel.text = dateFomatterForDateLabel(date: message.createdAt.dateValue())
            }
        }
        
        
    }
    
    private func estimateFrameTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)], context: nil)
        
    }
    
    private func dateFomatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
