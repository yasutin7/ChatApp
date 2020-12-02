//
//  ChatInputAccessoryView.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/11/28.
//

import UIKit
protocol ChatInputAccessoryViewDelegate: class{
    func tappedSendButton(text: String)
}


class ChatInputAccessoryView: UIView {
    
    weak var delegate: ChatInputAccessoryViewDelegate?
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func tappedSendButton(_ sender: Any) {
        delegate?.tappedSendButton(text: chatTextView.text)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setUpViews()
        autoresizingMask = .flexibleHeight
    }
    
    private func setUpViews() {
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        sendButton.layer.cornerRadius = 15
        sendButton.isEnabled = false
        
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    
    func removeText() {
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func  nibInit() {
        let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        guard  let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return}
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(view)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatInputAccessoryView: UITextViewDelegate  {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        }else {
            sendButton.isEnabled = true
        }
        
    }
}
