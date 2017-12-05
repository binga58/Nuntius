//
//  UserInfoTableViewCell.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 28/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var presenceImageView: UIImageView!
    @IBOutlet weak var userNameLBL: UILabel!
    
    @IBOutlet weak var unreadCountLBL: UILabel!
    @IBOutlet weak var lastMessageLBL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(userData: NTUserData){
        
        userNameLBL.text = userData.userId
        
        let childMOC = NTDatabaseManager.sharedManager().getChildContext()
        
        if let messageId = userData.lastMessageId, let lastMessage: NTMessage = NTMessageData.message(messageId: messageId, managedObjectContext: childMOC){
            lastMessageLBL.text = lastMessage.messageText
        }
        let presence = Presence(rawValue: (userData.presence?.intValue)!)
        
        switch presence {
        case .online?:
            presenceImageView.image = #imageLiteral(resourceName: "status-available")
        default:
            presenceImageView.image = #imageLiteral(resourceName: "status-offline")
        }
        
        
    }
    
}
