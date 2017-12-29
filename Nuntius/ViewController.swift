//
//  ViewController.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 21/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var userThreadTableView: UITableView!
    lazy var fetchedResultsController: NSFetchedResultsController<NTUserData> = {
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NTUserData.entityName)
        userFetchRequest.predicate = NSPredicate.init(format: "\(NTUserData.userDataLastActivityTime) > 0", [])
        
        let primarySortDescriptor = NSSortDescriptor(key: "\(NTUserData.userDataLastActivityTime)", ascending: false)
        userFetchRequest.sortDescriptors = [primarySortDescriptor]
        userFetchRequest.fetchLimit = 100
        
        let frc = NSFetchedResultsController(
            fetchRequest: userFetchRequest,
            managedObjectContext: NTDatabaseManager.sharedManager().getMainManagedObjectContext(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc as! NSFetchedResultsController<NTUserData>
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        setUpTableView()
        connectTap(UIButton())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
            userThreadTableView.reloadData()
        } catch {
            print("An error occurred")
        }
    }

    @IBAction func chatTaped(_ sender: Any) {
        
        let mainStoryborad = UIStoryboard.init(name: "Main", bundle: nil)
        let sendMessageVC = mainStoryborad.instantiateViewController(withIdentifier: "sendMessage")
        self.definesPresentationContext = true;
        sendMessageVC.modalPresentationStyle = .overCurrentContext
        self.present(sendMessageVC, animated: true, completion: nil)
        
        
    }
    @IBAction func connectTap(_ sender: Any) {
//        let account = NTXMPPAccount.init(serverDomain: "xmpp2.livecare.ca", userName: "612", password:  "bb580825-4bca-4111-9f28-85a61f17cb33", groupChatServiceName: "groupChat")
//                let account = NTXMPPAccount.init(serverDomain: "xmpp2.livecare.ca", userName: "610", password:  "dacd0e23-01dc-486d-8a8a-02665c0d4941", groupChatServiceName: "groupChat")
//                let account = NTXMPPAccount.init(serverDomain: "xmpp2.livecare.ca", userName: "103", password:  "07ff5446-df43-478c-9077-14ac4a12c90f", groupChatServiceName: "groupChat")
//        let account = NTXMPPAccount.init(serverDomain: "jabber.cat", userName: "hiteshchu", password:  "123456", groupChatServiceName: "groupChat")
        let account = NTXMPPAccount.init(serverDomain: "jabber.cat", userName: "hiteshchomu", password:  "123456", groupChatServiceName: "groupChat")
//        let account = NTXMPPAccount.init(serverDomain: "xmpp.dk", userName: "vishnu123", password:  "123456", groupChatServiceName: "groupChat")
        NTXMPPManager.sharedManager().setxmppAccount(xmppAccount: account)
        NTXMPPManager.sharedManager().connect()
        NTXMPPManager.sharedManager().addPresenceDelegate(viewController: self)
    }
    
    @IBAction func disconnectTap(_ sender: Any) {
        NTXMPPManager.sharedManager().disconnect()
    }
//    @IBAction func chatTaped(_ sender: Any) {
//
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let chatViewController = storyboard.instantiateViewController(withIdentifier: String(describing: ChatViewController.self))
//        self.navigationController?.pushViewController(chatViewController, animated: true)
//
//    }
    
    func setUpTableView() -> () {
        let userInfoCell = String(describing: UserInfoTableViewCell.self)
        let nib = UINib.init(nibName: userInfoCell, bundle: nil)
        userThreadTableView.register(nib, forCellReuseIdentifier: userInfoCell)
    }
}

extension ViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userData = fetchedResultsController.object(at: indexPath)
        
        if let cell: UserInfoTableViewCell = userThreadTableView.dequeueReusableCell(withIdentifier: String(describing: UserInfoTableViewCell.self)) as? UserInfoTableViewCell{
            cell.configureCell(userData: userData)
            return cell
        }
        
        return UITableViewCell()
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chatViewController = storyboard.instantiateViewController(withIdentifier: String(describing: ChatViewController.self)) as? ChatViewController{
            let userData = fetchedResultsController.object(at: indexPath)
            chatViewController.buddy = userData
            self.navigationController?.pushViewController(chatViewController, animated: true)
        }
        
        
        
    }
}

extension ViewController : NSFetchedResultsControllerDelegate{
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        userThreadTableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        
        switch(type) {
            
        case .insert:
            if let newIndexPath = newIndexPath {
                userThreadTableView.insertRows(at: [newIndexPath as IndexPath], with: .bottom)
            }
            
        case .delete:
            if let indexPath = indexPath {
                userThreadTableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
            
        case .update:
            if let indexPath = indexPath {
                
//                let userData = fetchedResultsController.object(at: indexPath)
                
//                if let cell: UserInfoTableViewCell = userThreadTableView.dequeueReusableCell(withIdentifier: String(describing: UserInfoTableViewCell.self)) as? UserInfoTableViewCell{
//                    cell.configureCell(userData: userData)
                    userThreadTableView.reloadRows(at: [indexPath], with: .none)
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
    
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType){
        
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        userThreadTableView.endUpdates()
    }
}


extension ViewController: PresenceChanged{
    func presenceChanged(user: String, presence: Presence) {
        DispatchQueue.main.async {
            self.userThreadTableView.reloadData()
        }
    }
}

