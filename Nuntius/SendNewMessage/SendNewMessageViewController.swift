//
//  SendNewMessageViewController.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 29/12/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class SendNewMessageViewController: UIViewController {

    @IBOutlet weak var receiverIdTF: UITextField!
    
    @IBOutlet weak var firstMessageTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

//UI Events
extension SendNewMessageViewController{
    @IBAction func dismissViewControllerTaped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendMessageTaped(_ sender: Any) {
        if let userIdCount =  receiverIdTF.text?.count, userIdCount > 0, let userId = receiverIdTF.text, let message = firstMessageTF.text{
            NTXMPPManager.sharedManager().sendMessage(messageText: message, userId: userId)
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
}
