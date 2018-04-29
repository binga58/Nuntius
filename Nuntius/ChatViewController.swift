//
//  ChatViewController.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 23/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import CoreData
import MessageKit
import MapKit

class ChatViewController: MessagesViewController {
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
    
    var allMessages = [NTMessageData]()
    
    
    //MARK:----------------- View Life cycle methods ------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTable()
        self.title = buddy?.userId
        do {
            try fetchedResultsController.performFetch()
            allMessages = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print(error)
        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
//        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
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
        if let msgId = messageData.msgId, let msgHeight: NSNumber = self.messageHeight.object(forKey: msgId as NSString){
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
        messageHeight.setObject(NSNumber.init(value: Float(cellRect.height)), forKey: messageData.msgId! as NSString)
        
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
            if let newIndexPath = newIndexPath, let message = anObject as? NTMessageData {
                allMessages.insert(message, at: newIndexPath.row)
//                chatTableView.insertRows(at: [newIndexPath as IndexPath], with: .bottom)
                messagesCollectionView.insertSections([allMessages.count - 1])
                messagesCollectionView.scrollToBottom()
            }
            
        case .delete:
            if let indexPath = indexPath, let message = anObject as? NTMessageData {
                allMessages.remove(at: indexPath.row)
                messagesCollectionView.deleteSections([allMessages.count - 1])
//                chatTableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
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
    }
    
}

//MARK:--------------- Text view Delegate ---------------
extension ChatViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        NTXMPPManager.sharedManager().sendChatStateToUser(userId: (buddy?.userId)!, chatState: .composing)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        NTXMPPManager.sharedManager().sendChatStateToUser(userId: (buddy?.userId)!, chatState: .active)
        
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

extension ChatViewController: MessagesDataSource{
    func currentSender() -> Sender {
        return Sender(id: NTXMPPManager.sharedManager().xmppAccount.userName!, displayName: (NTXMPPManager.sharedManager().xmppAccount.userName)!)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return allMessages[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return allMessages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        struct ConversationDateFormatter {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter
            }()
        }
        let formatter = ConversationDateFormatter.formatter
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func avatarPosition(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> AvatarPosition {
        return AvatarPosition(horizontal: .natural, vertical: .messageBottom)
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        } else {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
    }
    
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        } else {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: messagesCollectionView.bounds.width, height: 10)
    }
    
    // MARK: - Location Messages
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
    
}

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        
        for component in inputBar.inputTextView.components {
            
//            if let image = component as? UIImage {
//
//                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
//                messageList.append(imageMessage)
//                messagesCollectionView.insertSections([messageList.count - 1])
//
//            } else
            if let text = component as? String {
            
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                
                NTXMPPManager.sharedManager().sendMessage(messageText: text, userId: (buddy?.userId)! )
                
//                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
//                messageList.append(message)
//                messagesCollectionView.insertSections([messageList.count - 1])
            }
            
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey : Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
        //        let configurationClosure = { (view: MessageContainerView) in}
        //        return .custom(configurationClosure)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: Avatar())
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "pin")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions()
    }
}
