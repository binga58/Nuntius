//
//  NTXMPPConnection.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 21/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import XMPPFramework

class NTXMPPConnection: NSObject {
    
    lazy var myJID: XMPPJID? = {
        
        return XMPPJID.init(string: NTUtility.getCurrentUserFullId())
    }()
    
    var iqManager: NTIQManger!
    
    var presenceManager: NTPresenceManager!
    
    var messageManager: NTMessageManager!
    
    
    
    //XMPPSteam
    var xmppStream: XMPPStream!
    var xmppReconnect: XMPPReconnect!
    
    //XMPPStreamManagement
    var xmppStreamManagement: XMPPStreamManagement!
    var xmppStreamManagementMemoryStorage: XMPPStreamManagementMemoryStorage!
    
    //XMPPPing
    var xmppPing: XMPPPing!
    var xmppAutoPing: XMPPAutoPing!
    
    //XMPPMessageArchive
    var xmppMessageArchivingCoreDataStorage: XMPPMessageArchivingCoreDataStorage!
    var xmppMessageArchivingModule: XMPPMessageArchiving!
    var xmppMessageArchiveManagement: XMPPMessageArchiveManagement!
    
    //XMPPRoster
    var xmppRoster: XMPPRoster!
    var xmppRosterCoreDataStorage: XMPPRosterCoreDataStorage!
    
    //XMPPvCard
    var xmppvCardCoreDataStorage: XMPPvCardCoreDataStorage!
    var xmppvCardTemp: XMPPvCardTempModule!
    var xmppvCardAvatar: XMPPvCardAvatarModule!
    
    //Capabilities
    var xmppCapabilities: XMPPCapabilities!
    var xmppCapabilitiesCoreDataStorage: XMPPCapabilitiesCoreDataStorage!
    
    //XMPPRoom
    var xmppRoom: XMPPRoom!
    var xmppRoomMemoryStorage: XMPPRoomMemoryStorage!
    var xmppRoomCoreDataStorage: XMPPRoomCoreDataStorage!
    var xmppMUC: XMPPMUC!
    
    //Rooms Data
    var xmppRooms = [XMPPRoom]()
    var allowSSLHostNameMismatch: Bool!
    var allowSelfSignedCertificates: Bool!
    var xmppAccount : NTXMPPAccount?
    
    var timeout = 10
    
    public override init() {
        super.init()
        self.iqManager = NTIQManger()
        self.messageManager = NTMessageManager()
        self.presenceManager = NTPresenceManager()
    }
    
    func sharedPresenceManager() -> NTPresenceManager {
        return self.presenceManager
    }
    
    func sharedIQManger() -> NTIQManger {
        return self.iqManager
    }
    
    func sharedMessageManager() -> NTMessageManager {
        return self.messageManager
    }
    
}

//MARK:--------------- Connect and authenticate ---------------
extension NTXMPPConnection{
    /**
     This method connects with xmppserver by initializing stream and authenticating with server
     
     - parameter xmppAccount: Object of class NTXMPPAccount containing information of serverAddress, username and password.Above variables should not be nil.
     - Returns: true if connection is successful else false
     */
    
    func connect(xmppAccount:NTXMPPAccount) -> Bool{
        print("---------Connect called-----------")
        self.xmppAccount = xmppAccount
        if xmppStream == nil{
            self.setUpXMPPStream()
        }
        if xmppStream.isDisconnected && self.xmppAccount?.userName != nil && self.xmppAccount?.password != nil{
            let myXMPPjID = XMPPJID.init(string: NTUtility.getCurrentUserFullId())
            if xmppStream.myJID?.user != myXMPPjID?.user{
                xmppStream.disconnect()
            }
            xmppStream.myJID = myXMPPjID
            do{
                try xmppStream.connect(withTimeout: TimeInterval((self.xmppAccount?.timeoutInterval)!))
                return true
            }
            catch{
                print(error)
                return false
            }
            
        }else{
            return false
        }
    }
    
    /**
     Authenticate user with password from server.
     - parameter stream: stream on which user wants to authenticate
     */
    
    func authenticateWithServer(stream: XMPPStream) -> () {
        if stream == xmppStream{
            if let password = self.xmppAccount?.password{
                do{
                    try xmppStream.authenticate(withPassword: password)
                }
                catch{
                    NTXMPPManager.sharedManager().connect()
                }
            }
        }
    }
}


//MARK:--------------- Send Elements ---------------
extension NTXMPPConnection{
    
    func sendElement(element: DDXMLElement) -> () {
        xmppStream.send(element)
    }
    
}


//MARK:-------------- Archive stanza ---------------
extension NTXMPPConnection{
    
    func sendArchiveRequest(utcDateTime: NSDate) -> () {
        
        let field = DDXMLElement.element(withName: NTConstants.field) as? DDXMLElement
        field?.addAttribute(withName: NTConstants.varXMPP, stringValue: NTConstants.start)
        let xmppDateTime = utcDateTime.xmppDateTimeString
        let value = DDXMLElement.element(withName: NTConstants.value, stringValue: xmppDateTime) as? DDXMLElement
        field?.addChild(value!)
        var formField = [DDXMLElement]()
        formField.append(field!)
        
        let resultSet = XMPPResultSet.init(max: 1)
        
        xmppMessageArchiveManagement.retrieveMessageArchive(at: nil, withFields: formField, with: resultSet)
        
    }
    
}


//MARK:--------------Stream setup and clear ---------------
extension NTXMPPConnection {
    /**
     Sets up xmpp stream variables
     */
    func setUpXMPPStream() {
        xmppStream = XMPPStream()
        xmppStream.hostName = self.xmppAccount?.serverDomain
        xmppStream.hostPort = (self.xmppAccount?.port)!
        xmppStream.tag = self.xmppAccount?.userName
        xmppStream.startTLSPolicy = .preferred
        
        //initialize XXMPPStreamManagement
        xmppStreamManagementMemoryStorage = XMPPStreamManagementMemoryStorage()
        xmppStreamManagement = XMPPStreamManagement.init(storage: xmppStreamManagementMemoryStorage, dispatchQueue: NTXMPPManager.sharedManager().getQueue())
        xmppStreamManagement.automaticallyRequestAcks(afterStanzaCount: 1, orTimeout: 5)
        xmppStreamManagement.automaticallySendAcks(afterStanzaCount: 30, orTimeout: 5)
        xmppStreamManagement.autoResume = true
        
        //initialize xmppPing
        xmppPing = XMPPPing.init(dispatchQueue: NTXMPPManager.sharedManager().getQueue())
        xmppPing.respondsToQueries = true
        
        xmppAutoPing = XMPPAutoPing.init(dispatchQueue: NTXMPPManager.sharedManager().getQueue())
        xmppAutoPing.pingTimeout = TimeInterval(timeout)
        xmppAutoPing.pingInterval = 2*60
        
        //initialize XMPPMessageArchive
        xmppMessageArchivingCoreDataStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
        xmppMessageArchivingModule = XMPPMessageArchiving.init(messageArchivingStorage: xmppMessageArchivingCoreDataStorage, dispatchQueue: NTXMPPManager.sharedManager().getQueue())
        xmppMessageArchiveManagement = XMPPMessageArchiveManagement.init(dispatchQueue: NTXMPPManager.sharedManager().getQueue())
        xmppMessageArchiveManagement.resultAutomaticPagingPageSize = 100
        
        //initialize XMPPReconnect
        xmppReconnect = XMPPReconnect()
        
        //initialize XMPPRosterCoreDataStorage
        xmppRosterCoreDataStorage = XMPPRosterCoreDataStorage()
        
        //initialize XMPPRoster
        xmppRoster = XMPPRoster.init(rosterStorage: xmppRosterCoreDataStorage)
        xmppRoster.autoFetchRoster = true
        xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = true
        
        //initialize vCard Support
        xmppvCardCoreDataStorage = XMPPvCardCoreDataStorage.sharedInstance()
        xmppvCardTemp = XMPPvCardTempModule.init(vCardStorage: xmppvCardCoreDataStorage)
        xmppvCardAvatar = XMPPvCardAvatarModule.init(vCardTempModule: xmppvCardTemp, dispatchQueue: NTXMPPManager.sharedManager().getQueue())
        
        //initialize Capabilities
        xmppCapabilitiesCoreDataStorage = XMPPCapabilitiesCoreDataStorage.sharedInstance()
        xmppCapabilities = XMPPCapabilities.init(capabilitiesStorage: xmppCapabilitiesCoreDataStorage)
        xmppCapabilities.autoFetchHashedCapabilities = true
        xmppCapabilities.autoFetchNonHashedCapabilities = true
        xmppCapabilities.autoFetchMyServerCapabilities = true
        
        //activate XMPP Modules
        xmppReconnect.activate(xmppStream)
        xmppRoster.activate(xmppStream)
        xmppMessageArchivingModule.activate(xmppStream)
        xmppMessageArchiveManagement.activate(xmppStream)
        xmppvCardTemp.activate(xmppStream)
        xmppStreamManagement.activate(xmppStream)
        //        xmppvCardAvatar.activate(xmppStream)
        xmppCapabilities.activate(xmppStream)
        
        //add delegate
        xmppStream.addDelegate(self, delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppStream.addDelegate(self.sharedMessageManager(), delegateQueue: NTXMPPManager.sharedManager().getQueue());
        xmppStream.addDelegate(self.sharedIQManger(), delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppStream.addDelegate(self.sharedPresenceManager(), delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppRoster.addDelegate(self, delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppReconnect.addDelegate(self, delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppStreamManagement.addDelegate(self, delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppMessageArchiveManagement.addDelegate(self.sharedMessageManager(), delegateQueue: NTXMPPManager.sharedManager().getQueue())
        
        xmppRoomCoreDataStorage = XMPPRoomCoreDataStorage()
        xmppRoomCoreDataStorage.autoRecreateDatabaseFile = false
        xmppRoomCoreDataStorage.autoRemovePreviousDatabaseFile = false
        
        xmppMUC = XMPPMUC(dispatchQueue: NTXMPPManager.sharedManager().getQueue())
        xmppMUC.activate(xmppStream)
        xmppMUC.addDelegate(self, delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppMUC.discoverServices()
    }
    
    /**
     Disconnects from xmpp server after sending all pending elements
     */
    func disconnectXMPPStream() -> () {
        xmppStream.disconnectAfterSending()
    }
    
    /**
     Clears xmppstream
     */
    func clearXMPPStream() {
        if xmppStream != nil{
            xmppStream.removeDelegate(self)
            xmppStream.removeDelegate(messageManager)
            xmppStream.removeDelegate(iqManager)
            xmppStream.removeDelegate(presenceManager)
        }
        if xmppRoster != nil{
            xmppRoster.removeDelegate(self)
            xmppRoster.deactivate()
        }
        if xmppCapabilities != nil{
            xmppCapabilities.removeDelegate(self)
            xmppCapabilities.deactivate()
        }
        if xmppMUC != nil{
            xmppMUC.removeDelegate(self)
            xmppMUC.deactivate()
        }
        if xmppReconnect != nil{
            xmppReconnect.removeDelegate(self)
            xmppReconnect.deactivate()
        }
        if xmppvCardTemp != nil {
            xmppvCardTemp.removeDelegate(self)
            xmppvCardTemp.deactivate()
        }
        if xmppStreamManagement != nil{
            xmppStreamManagement.removeDelegate(self)
            xmppStreamManagement.deactivate()
        }
        if xmppMessageArchivingModule != nil{
            xmppMessageArchivingModule.removeDelegate(self)
            xmppMessageArchivingModule.deactivate()
        }
        if xmppMessageArchiveManagement != nil{
            xmppMessageArchiveManagement.removeDelegate(self.sharedMessageManager())
            xmppMessageArchiveManagement.deactivate()
        }
        if xmppvCardAvatar != nil{
            xmppvCardAvatar.removeDelegate(self)
            xmppvCardAvatar.deactivate()
        }
        //clear objects
        xmppReconnect = nil
        xmppRoster = nil
        xmppRosterCoreDataStorage = nil
        xmppvCardCoreDataStorage = nil
        
        xmppvCardTemp = nil
        xmppvCardAvatar = nil
        
        xmppPing = nil
        xmppAutoPing = nil
        
        xmppStreamManagement = nil
        xmppStreamManagementMemoryStorage = nil
        
        xmppMessageArchiveManagement = nil
        xmppMessageArchivingModule = nil
        xmppMessageArchivingCoreDataStorage = nil
        
        //xmppvCardAvatar = nil
        xmppCapabilities = nil
        xmppCapabilitiesCoreDataStorage = nil
        
        xmppRoom = nil
        xmppRoomMemoryStorage = nil
        xmppRoomCoreDataStorage = nil
        xmppMUC = nil
        
        
        xmppStream.disconnect()
        xmppStream = nil
    }
    
}


//MARK:------------XMPPStream Delegate--------------
extension NTXMPPConnection: XMPPStreamDelegate {
    
    func xmppStream(_ sender: XMPPStream, socketDidConnect socket: GCDAsyncSocket) {
        NTXMPPManager.sharedManager().streamConnected()
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        self.authenticateWithServer(stream: sender)
    }
    
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        let streamError = NTStreamError.init(error: error, stanza: nil, streamError: XMPPStreamError.streamDisconnected)
        NTXMPPManager.sharedManager().xmppStreamError(streamError: streamError)
    }
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        let streamError = NTStreamError.init(error: nil, stanza: nil, streamError: XMPPStreamError.connectionTimedOut)
        NTXMPPManager.sharedManager().xmppStreamError(streamError: streamError)
    }
    
    func xmppStreamDidRegister(_ sender: XMPPStream) {
        
    }
    
    func xmppStream(_ sender: XMPPStream, didNotRegister error: DDXMLElement) {
        let streamError = NTStreamError.init(error: nil, stanza: String(describing: error), streamError: XMPPStreamError.userNotRegistered)
        NTXMPPManager.sharedManager().xmppStreamError(streamError: streamError)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceiveError error: DDXMLElement) {
        let streamError = NTStreamError.init(error: nil, stanza: String(describing: error), streamError: XMPPStreamError.unknownError)
        NTXMPPManager.sharedManager().xmppStreamError(streamError: streamError)
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("-----------Authenticated-------------")
        NTXMPPManager.sharedManager().userAuthenticated()
    }
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        let streamError = NTStreamError.init(error: nil, stanza: String(describing: error), streamError: XMPPStreamError.userNotAuthenticated)
        NTXMPPManager.sharedManager().xmppStreamError(streamError: streamError)
    }
    
    func xmppStream(_ sender: XMPPStream, didSendCustomElement element: DDXMLElement) {
        
    }
    
    
    
    //    func xmppStream(_ sender: XMPPStream, willSecureWithSettings settings: NSMutableDictionary) {
    //        if (self.xmppAccount?.allowSelfSignedCertificates)!{
    //            settings.setObject(NSNumber.init(value: allowSelfSignedCertificates), forKey: String(kCFStreamSSLValidatesCertificateChain) as NSCopying)
    //        }
    //        if (self.xmppAccount?.allowSSLHostNameMismatch)!{
    //            settings.setObject(NSNull(), forKey: String(kCFStreamSSLPeerName) as NSCopying)
    //        }else{
    //            let serverDomain = sender.hostName
    //            let virtualDomain = sender.myJID?.domain
    //            let expectedCertName: String
    //            if serverDomain == nil{
    //                expectedCertName = virtualDomain!
    //            }else{
    //                expectedCertName = serverDomain!
    //            }
    //            if expectedCertName.count > 0{
    //                settings.setObject(expectedCertName, forKey: String(kCFStreamSSLPeerName) as NSCopying)
    //            }
    //        }
    //    }
    
}



