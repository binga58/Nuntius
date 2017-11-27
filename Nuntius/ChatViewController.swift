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
    @IBOutlet weak var textVIew: UITextView!
    
    var fetchCount = 100
    
    lazy var fetchedResultsController: NSFetchedResultsController<NTMessageData> = {
        let animalsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NTMessageData.entityName)
        let primarySortDescriptor = NSSortDescriptor(key: "\(NTMessageData.messageDataCreatedTimeStamp)", ascending: true)
        animalsFetchRequest.sortDescriptors = [primarySortDescriptor]
        animalsFetchRequest.fetchLimit = 100
        
        let frc = NSFetchedResultsController(
            fetchRequest: animalsFetchRequest,
            managedObjectContext: NTDatabaseManager.sharedManager().mainManagedObjectContext(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self as? NSFetchedResultsControllerDelegate
        
        return frc as! NSFetchedResultsController<NTMessageData>
    }()
    
    
    @IBOutlet weak var chatTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTable()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func sendTaped(_ sender: Any) {
        let messageText = textVIew.text
        textVIew.text = ""
        NTXMPPManager.sharedManager().sendMessage(messageText: messageText!, userId: NTXMPPManager.sharedManager().xmppAccount.userName == "612" ? "610" : "612" )
//        chatTableView.insertRows(at: [NSIndexPath.init(row: messages.count - 1, section: 0) as IndexPath], with: .automatic)
//        self.goToBottom()
//        NTXMPPManager.xmppConnection?.loadarchivemsg()
        
    }
    
    @objc func goToBottom(){
//        chatTableView.scrollToRow(at: NSIndexPath.init(row: messages.count - 1, section: 0) as IndexPath, at: .bottom, animated: true)
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
        return 100
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
                chatTableView.insertRows(at: [newIndexPath as IndexPath], with: .automatic)
            }
            
        case .delete:
            if let indexPath = indexPath {
                chatTableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
            
        case .update:
            if let indexPath = indexPath {
//                if let cell = chatTableView.cellForRowAtIndexPath(indexPath) as? UITableViewCell {
//                    configureCell(cell, withObject: object)
//                }
            }
            
        case .move:
            if let indexPath = indexPath {
//                if let newIndexPath = newIndexPath {
//                    chatTableView.deleteRowsAtIndexPaths([indexPath],
//                                                     withRowAnimation: UITableViewRowAnimation.Fade)
//                    chatTableView.insertRowsAtIndexPaths([newIndexPath],
//                                                     withRowAnimation: UITableViewRowAnimation.Fade)
//                }
            }
        }
    }
//
//    func controller(controller: NSFetchedResultsController,
//                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
//                    atIndex sectionIndex: Int,
//                    forChangeType type: NSFetchedResultsChangeType)
//    {
//        switch(type) {
//
//        case .Insert:
//            tableView.insertSections(NSIndexSet(index: sectionIndex),
//                                     withRowAnimation: UITableViewRowAnimation.Fade)
//
//        case .Delete:
//            tableView.deleteSections(NSIndexSet(index: sectionIndex),
//                                     withRowAnimation: UITableViewRowAnimation.Fade)
//
//        default:
//            break
//        }
//    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.chatTableView.endUpdates()
        chatTableView.scrollToRow(at: chatTableView.indexPathForLastRow(), at: .bottom, animated: true)
    }
    
}

extension UITableView{
    func indexPathForLastRow() -> IndexPath {
        return IndexPath(row: numberOfRows(inSection: numberOfSections - 1) - 1, section: numberOfSections - 1)
    }
    
//    -(NSIndexPath*)indexPathForLastRow(){
//    return [NSIndexPath indexPathForRow:[self numberOfRowsInSection:self.numberOfSections - 1] - 1 inSection:self.numberOfSections - 1];
//    }
}



