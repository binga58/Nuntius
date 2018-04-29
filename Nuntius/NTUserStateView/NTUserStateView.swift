//
//  NTUserStateView.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 30/04/18.
//  Copyright © 2018 Finoit Technologies. All rights reserved.
//

import UIKit

class NTUserStateView: UIView {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userChatState: UILabel!
    
    var buddy: NTUserData?
    
    static func getInstance() -> NTUserStateView?{
        if let view = Bundle.main.loadNibNamed(NTUserStateView.className(), owner: self, options: nil)?.first as? NTUserStateView{
            
            return view
        }
        return NTUserStateView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerForNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(updateState), name: NSNotification.Name.init("updateState"), object: nil)
    }
    
    @objc func updateState() -> Void {
        DispatchQueue.main.async {
            if let user = self.buddy{
                self.userName.text = user.userId
                
                var text = ""
                if let chatState = NTChatState(rawValue: user.chatState?.intValue ?? 0){
                    switch chatState{
                    case .gone:
                        text = "gone"
                    case .active:
                        text = "active"
                    case .composing:
                        text = "typing"
                    case .paused:
                        text = "active"
                    case .inactive:
                        text = "last active on - "
                    }
                }
                self.userChatState.text = text
                
                
            }
        }
    }

}
