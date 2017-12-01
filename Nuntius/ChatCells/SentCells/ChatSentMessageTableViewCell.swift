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
//        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
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
                statusLBL.text = "Waiting To Sent - \(NTUtility.getLocalTimeToDisplayOnChatCell(timeInterval: (message.createdTimestamp?.doubleValue)! + NTXMPPManager.sharedManager().xmppServerTimeDifference))"
            case .sent:
                statusLBL.text = "Sent At - \(NTUtility.getLocalTimeToDisplayOnChatCell(timeInterval: (message.createdTimestamp?.doubleValue)! + NTXMPPManager.sharedManager().xmppServerTimeDifference))"
            case .delivered:
                statusLBL.text = "Delivered At - \(NTUtility.getLocalTimeToDisplayOnChatCell(timeInterval: (message.deliveredTimestamp?.doubleValue)! + NTXMPPManager.sharedManager().xmppServerTimeDifference))"
            case .read:
                statusLBL.text = "Read At - \(NTUtility.getLocalTimeToDisplayOnChatCell(timeInterval: (message.readTimestamp?.doubleValue)! + NTXMPPManager.sharedManager().xmppServerTimeDifference))"
            default:
                statusLBL.text = "Failed"
            }
        }
        
        
    }
    
}
