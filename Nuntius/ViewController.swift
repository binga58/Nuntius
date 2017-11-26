//
//  ViewController.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 21/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connectTap(_ sender: Any) {
        
    }
    
    @IBAction func disconnectTap(_ sender: Any) {
        NTXMPPManager.sharedManager().disconnect()
    }
    @IBAction func chatTaped(_ sender: Any) {
        let account = NTXMPPAccount.init(serverDomain: "xmpp2.livecare.ca", userName: "612", password:  "bb580825-4bca-4111-9f28-85a61f17cb33", groupChatServiceName: "groupChat")
//
//        let account = NTXMPPAccount.init(serverDomain: "xmpp2.livecare.ca", userName: "610", password:  "dacd0e23-01dc-486d-8a8a-02665c0d4941", groupChatServiceName: "groupChat")
//        let account = NTXMPPAccount.init(serverDomain: "xmpp2.livecare.ca", userName: "103", password:  "07ff5446-df43-478c-9077-14ac4a12c90f", groupChatServiceName: "groupChat")
        NTXMPPManager.sharedManager().setxmppAccount(xmppAccount: account)
        NTXMPPManager.sharedManager().connect()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatViewController = storyboard.instantiateViewController(withIdentifier: String(describing: ChatViewController.self))
        
//        let chatViewController = ChatViewController.init(nibName: String(describing: ChatViewController.self), bundle: nil)
        self.navigationController?.pushViewController(chatViewController, animated: true)
        
    }
}

