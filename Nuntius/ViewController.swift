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
        let account = NTXMPPAccount.init(serverDomain: "xmpp2.livecare.ca", userName: "232", password:  "35e5bd12-d732-4243-9580-9ab4057003d3")
        NTXMPPManager.sharedManager().setxmppAccount(xmppAccount: account)
        NTXMPPManager.sharedManager().connect()
    }
    
    @IBAction func disconnectTap(_ sender: Any) {
        NTXMPPManager.sharedManager().disconnect()
    }
}

