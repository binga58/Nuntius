//
//  ChatSentMessageTableViewCell.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 23/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class ChatSentMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var statusLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(message: NTMessage) -> () {
        txtView.text = message.messageText
        if let status: MessageStatus = message.messageStatus{
            switch status {
            case .waiting:
                statusLBL.text = "Waiting To Sent - \(String(describing: NTUtility.getLocalTimeFromUTC(date: Date.init(timeIntervalSince1970: (message.createdTimestamp?.doubleValue)!))))"
            case .sent:
                statusLBL.text = "Sent At - \(String(describing: NTUtility.getLocalTimeFromUTC(date: Date.init(timeIntervalSince1970: (message.createdTimestamp?.doubleValue)!))))"
            case .delivered:
                statusLBL.text = "Delivered At - \(String(describing: Date.init(timeIntervalSince1970: (message.deliveredTimestamp?.doubleValue)!)))"
            case .read:
                statusLBL.text = "Read At - \(String(describing: Date.init(timeIntervalSince1970: (message.readTimestamp?.doubleValue)!)))"
            default:
                statusLBL.text = "Failed"
            }
        }
        
        
    }
    
}
