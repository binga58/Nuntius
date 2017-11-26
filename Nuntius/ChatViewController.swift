//
//  ChatViewController.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 23/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var textVIew: UITextView!
    var messages = [String]()
    
    @IBOutlet weak var chatTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTable()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func sendTaped(_ sender: Any) {
        messages.append(textVIew.text)
        textVIew.text = ""
        NTXMPPManager.sharedManager().sendMessage(messageText: "123", userId: NTXMPPManager.sharedManager().xmppAccount.userName == "612" ? "103" : "612" )
        chatTableView.insertRows(at: [NSIndexPath.init(row: messages.count - 1, section: 0) as IndexPath], with: .automatic)
        self.goToBottom()
//        NTXMPPManager.xmppConnection?.loadarchivemsg()
        
    }
    
    @objc func goToBottom(){
        chatTableView.scrollToRow(at: NSIndexPath.init(row: messages.count - 1, section: 0) as IndexPath, at: .bottom, animated: true)
    }
}

//MARK:-------------------- Table view helper --------------------
extension ChatViewController{
    func setUpTable() -> () {
        let sentMessageCell = String(describing: ChatSentMessageTableViewCell.self)
        let receiveMessageCell = String(describing: ChatReceiveMessageTableViewCell.self)
        let nib = UINib.init(nibName: sentMessageCell, bundle: nil)
        chatTableView.register(nib, forCellReuseIdentifier: sentMessageCell)
        chatTableView.register(UINib.init(nibName: receiveMessageCell, bundle: nil), forCellReuseIdentifier: receiveMessageCell)
        
        
    }
}

//MARK:-------------------- Table view datasource----------------------
extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatSentMessageTableViewCell.self))
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatReceiveMessageTableViewCell.self))
            return cell!
        }
        
//        return UITableViewCell()
    }
}

//MARK:----------------- Table view delegate ----------------------
extension ChatViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

