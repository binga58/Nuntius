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
    
    //XMPPSteam
    var xmppStream: XMPPStream!
    var xmppReconnect: XMPPReconnect!
    
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
    
//    //User details
//    var userId: String!
//    var userPassword: String!
//    
//    //XMPPHost details
//    var hostName: String!
//    var hostPort: UInt16!
    var allowSSLHostNameMismatch: Bool!
    var allowSelfSignedCertificates: Bool!
    var xmppAccount : NTXMPPAccount?
    
    
    func connect(xmppAccount:NTXMPPAccount){
        self.xmppAccount = xmppAccount
        if xmppStream == nil{
            self.setUpXMPPStream()
        }
        
    }
    
    func setUpXMPPStream() {
        xmppStream = XMPPStream()
//        xmppStream.enableBackgroundingOnSocket = true
        xmppStream.hostName = self.xmppAccount?.userName
        xmppStream.hostPort = (self.xmppAccount?.port)!
        
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
        
        //activate XMPP Modules
        xmppReconnect.activate(xmppStream)
        xmppRoster.activate(xmppStream)
        xmppvCardTemp.activate(xmppStream)
        
        xmppvCardAvatar.activate(xmppStream)
        xmppCapabilities.activate(xmppStream)
        
        //add delegate
        xmppStream.addDelegate(self, delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppRoster.addDelegate(self, delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppReconnect.addDelegate(self, delegateQueue: NTXMPPManager.sharedManager().getQueue())
        
        xmppRoomCoreDataStorage = XMPPRoomCoreDataStorage()
        xmppRoomCoreDataStorage.autoRecreateDatabaseFile = false
        xmppRoomCoreDataStorage.autoRemovePreviousDatabaseFile = false
        
        xmppMUC = XMPPMUC(dispatchQueue: NTXMPPManager.sharedManager().getQueue())
        xmppMUC.activate(xmppStream)
        xmppMUC.addDelegate(self, delegateQueue: NTXMPPManager.sharedManager().getQueue())
        xmppMUC.discoverServices()
    }
    
    
    
    
}
