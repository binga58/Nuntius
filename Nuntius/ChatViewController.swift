//
//  ChatViewController.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 23/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {
    //IBOutlets
    @IBOutlet weak var textVIew: UITextView!
    @IBOutlet weak var chatTableView: UITableView!
    
    //Variables
    var messageHeight: NSCache<NSString, NSNumber> = {
        let cache = NSCache<NSString, NSNumber>()
        cache.countLimit = 1000
        return cache
    }()
    
    var buddy: NTUserData?
    
    var fetchCount = 100
    
    lazy var fetchedResultsController: NSFetchedResultsController<NTMessageData> = {
        let messageFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NTMessageData.entityName)
        messageFetchRequest.predicate = NSPredicate.init(format: "\(NTMessageData.messageDataHasUser).\(NTUserData.userDataUserId) == %@ && \(NTMessageData.messageDataHasUser).\(NTUserData.userDataIsGroup) == %@",(buddy?.userId)!,(buddy?.isGroup)!)
        let primarySortDescriptor = NSSortDescriptor(key: "\(NTMessageData.messageDataReceivedTimestamp)", ascending: true)
        messageFetchRequest.sortDescriptors = [primarySortDescriptor]
        let frc = NSFetchedResultsController(
            fetchRequest: messageFetchRequest,
            managedObjectContext: NTDatabaseManager.sharedManager().getMainManagedObjectContext(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc as! NSFetchedResultsController<NTMessageData>
    }()
    
    lazy var navigationView: NTUserStateView = {
        
        let chatStateView = NTUserStateView.getInstance()
        chatStateView?.buddy = self.buddy
        chatStateView?.frame = CGRect(x: 0, y: 0, width: 400, height: 44)
        return chatStateView ?? NTUserStateView()
        
    }()
    
    
    //MARK:----------------- View Life cycle methods ------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTable()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        self.addNotificationObservers()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatTableView.scrollToRow(at: chatTableView.indexPathForLastRow(), at: .bottom, animated: false)
        NTXMPPManager.sharedManager().xmppConnection?.iqManager.getLastActivity(userId: (buddy?.userId)!)
        NTXMPPManager.sharedManager().addInRoster(userId: buddy?.userId)
        NTXMPPManager.sharedManager().setCurrentBuddy(buddy: NTUser.init(ntUserData: buddy))
        NTXMPPManager.sharedManager().markMessagesRead(userData: buddy) { (success) in
            
            if success{
                
                NTXMPPManager.sharedManager().sendReadReceiptsToUser(user: self.buddy, completion: { (sucess) in
                    
                })
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        chatTableView.scrollToRow(at: chatTableView.indexPathForLastRow(), at: .bottom, animated: true)
        NTXMPPManager.sharedManager().sendChatStateToUser(userId: (buddy?.userId)!, chatState: .active)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NTXMPPManager.sharedManager().removeCurrentBuddy()
        NTXMPPManager.sharedManager().sendChatStateToUser(userId: (buddy?.userId)!, chatState: .gone)
    }
    
    deinit {
        NTXMPPManager.sharedManager().removeCurrentBuddy()
        self.removeNotificationObservers()
    }
    
}

//MARK:-------------------- View setup helper --------------------
extension ChatViewController{
    func setupView() -> Void {
        navigationView.updateState()
        navigationView.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        navigationView.registerForNotification()
        self.navigationItem.titleView = navigationView
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections{
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageData: NTMessageData = fetchedResultsController.object(at: indexPath)
        let msg: NTMessage = NTMessage.init(messageData: messageData)
        
        if (messageData.isMine?.boolValue)!{
            if let cell: ChatSentMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatSentMessageTableViewCell.self)) as? ChatSentMessageTableViewCell{
                cell.configureCell(message: msg)
                return cell
            }
            
        }else{
            if let cell: ChatReceiveMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatReceiveMessageTableViewCell.self)) as? ChatReceiveMessageTableViewCell{
                cell.configureCell(message: msg)
                return cell
            }
            
        }
        return UITableViewCell()
        
    }
}

//MARK:----------------- Table view delegate ----------------------
extension ChatViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let messageData = fetchedResultsController.object(at: indexPath)
        if let messageId = messageData.messageId, let msgHeight: NSNumber = self.messageHeight.object(forKey: messageId as NSString){
            return CGFloat(msgHeight.floatValue)
        }
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        textVIew.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let messageData = fetchedResultsController.object(at: indexPath)
        let cellRect = tableView.rectForRow(at: indexPath)
        messageHeight.setObject(NSNumber.init(value: Float(cellRect.height)), forKey: messageData.messageId! as NSString)
        
    }
    
    
}

//MARK:--------------- Fetchresult controller delegate -------------
extension ChatViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.chatTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch(type) {
            
        case .insert:
            if let newIndexPath = newIndexPath {
                chatTableView.insertRows(at: [newIndexPath as IndexPath], with: .bottom)
            }
            
        case .delete:
            if let indexPath = indexPath {
                chatTableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
            
        case .update:
            if let indexPath = indexPath {
                
                let messageData: NTMessageData = fetchedResultsController.object(at: indexPath)
                if (messageData.isMine?.boolValue)!{
                    if let cell = chatTableView.cellForRow(at: indexPath) as? ChatSentMessageTableViewCell{
                        cell.configureCell(message: NTMessage.init(messageData: messageData))
                    }else{
                        if let cell = chatTableView.cellForRow(at: indexPath) as? ChatReceiveMessageTableViewCell{
                            cell.configureCell(message: NTMessage.init(messageData: messageData))
                        }
                    }
                }
            }
            
        case .move:
            break;
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.chatTableView.endUpdates()
        chatTableView.scrollToRow(at: chatTableView.indexPathForLastRow(), at: .bottom, animated: true)
    }
    
}

//MARK:----------------- Button Actions ------------------
extension ChatViewController{
    @IBAction func sendTaped(_ sender: Any) {
        let messageText = textVIew.text
        textVIew.text = ""
        NTXMPPManager.sharedManager().sendMessage(messageText: messageText!, userId: (buddy?.userId)! )
        NTXMPPManager.sharedManager().sendChatStateToUser(userId: (buddy?.userId)!, chatState: .active)
    }
    
}

//MARK:--------------- Text view Delegate ---------------
extension ChatViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        NTXMPPManager.sharedManager().sendChatStateToUser(userId: (buddy?.userId)!, chatState: .composing)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
//        NTXMPPManager.sharedManager().sendChatStateToUser(userId: (buddy?.userId)!, chatState: .active)
        
    }
    
}


//MARK:--------------- Add/Remove Notifications ----------
extension ChatViewController{
    func addNotificationObservers() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeNotificationObservers() -> Void {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:---------------- Keyboard handler --------------
extension ChatViewController{
    @objc func keyboardWillShow(sender: NSNotification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) -> Void {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}
