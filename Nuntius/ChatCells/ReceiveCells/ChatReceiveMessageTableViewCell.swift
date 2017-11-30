//
//  ChatReceiveMessageTableViewCell.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 23/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class ChatReceiveMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var dateTimeLBL: UILabel!
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
        textView.text = message.messageText
        if let status: MessageStatus = message.messageStatus{
            switch status {
            case .waiting:
                dateTimeLBL.text = "Waiting To Sent - \(NTUtility.getLocalTimeToDisplayOnChatCell(timeInterval: (message.createdTimestamp?.doubleValue)! + NTXMPPManager.sharedManager().xmppServerTimeDifference))"
            case .sent:
                dateTimeLBL.text = "Sent At - \(NTUtility.getLocalTimeToDisplayOnChatCell(timeInterval: (message.createdTimestamp?.doubleValue)! + NTXMPPManager.sharedManager().xmppServerTimeDifference))"
            case .delivered:
                dateTimeLBL.text = "Delivered At - \(NTUtility.getLocalTimeToDisplayOnChatCell(timeInterval: (message.createdTimestamp?.doubleValue)! + NTXMPPManager.sharedManager().xmppServerTimeDifference))"
            case .read:
                dateTimeLBL.text = "Read At - \(NTUtility.getLocalTimeToDisplayOnChatCell(timeInterval: (message.readTimestamp?.doubleValue)! + NTXMPPManager.sharedManager().xmppServerTimeDifference))"
            default:
                dateTimeLBL.text = "Failed"
            }
        }
    }
    
}
