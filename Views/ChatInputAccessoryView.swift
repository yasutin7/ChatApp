//
//  ChatInputAccessoryView.swift
//  ChatApp
//
//  Created by 藤原康就 on 2020/11/28.
//

import UIKit
class ChatInputAccessoryView: UIView {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
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
