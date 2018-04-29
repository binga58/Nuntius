//
//  NTXMPPIqManger.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 24/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit
import XMPPFramework

class NTIQManger: NSObject {
    
    //Dictionary of id and block function. When we receive the result of our query from server we perform the block corresponding to the id.
    fileprivate var outstandingXMPPStanzaResponseBlocks:[String: (Bool, XMPPIQ) -> Void] = [:]
    
    /**
     Fetches time of xmpp server in utc format and saves the difference with device's date and time
     */
    
    func getXMPPServerTime(completion:@escaping (Bool) -> ()) -> DDXMLElement {
        
//        <iq type='get'
//        from='romeo@montague.net/orchard'
//        to='juliet@capulet.com/balcony'
//        id='time_1'>
//        <time xmlns='urn:xmpp:time'/>
//        </iq>
        let messageId = NTUtility.getMessageId()
        
        //Closure which defines action taken after we get the result from server
        outstandingXMPPStanzaResponseBlocks[messageId] = { (success: Bool,iq: XMPPIQ) in
            if(success){
                
                if let timeElement = iq.element(forName: NTConstants.time), let utcTimeStanza = timeElement.element(forName: NTConstants.utc), let utcTime = utcTimeStanza.stringValue, let serverDateTime = NSDate.init(xmppDateTime: utcTime){
                    
                    //Current UTC time
                    let currentDateTime = NSDate()
                    //Differnce between server and current time
//                    let difference = serverDateTime.timeIntervalSince(currentDateTime as Date)
                    let difference = currentDateTime.timeIntervalSince(serverDateTime as Date)
                    //Saving the difference
                    NTXMPPManager.sharedManager().xmppServerTimeDifference = difference
                }
            }
            completion(success)
        }
        
        //Creates stanza for requesting server time
        let serverTimeNode = XMPPIQ.init(iqType: .get)
        serverTimeNode.addAttribute(withName: NTConstants.from, stringValue: NTUtility.getCurrentUserFullId())
        serverTimeNode.addAttribute(withName: NTConstants.id, stringValue: messageId)
        serverTimeNode.addAttribute(withName: NTConstants.to, stringValue: NTXMPPManager.sharedManager().xmppAccount.serverDomain!)
        
        let timenode = DDXMLElement.init(name: NTConstants.time, xmlns: NTConstants.xmlnsType.time)
        serverTimeNode.addChild(timenode)
        
        
        return serverTimeNode
    }
    
    
    func requestDiscoInfo(discoName: String) {
//        <iq from='romeo@shakespeare.lit/orchard'
//        id='disco1'
//        to='juliet@capulet.com/balcony'
//        type='get'>
//        <query xmlns='http://jabber.org/protocol/disco#info'/>
//        </iq>
        
        let messageId = NTUtility.getMessageId()
        
        //Closure which defines action taken after we get the result from server
        outstandingXMPPStanzaResponseBlocks[messageId] = { (success: Bool,iq: XMPPIQ) in
            if(success){
                
            }
            
        }
        
        
        let iqNode = XMPPIQ.init(iqType: .get)
        iqNode.addAttribute(withName: NTConstants.from, stringValue: NTUtility.getCurrentUserFullId())
        iqNode.addAttribute(withName: NTConstants.id, stringValue: messageId)
        iqNode.addAttribute(withName: NTConstants.to, stringValue: NTXMPPManager.sharedManager().xmppAccount.serverDomain!)
        
//        let queryNode = XMLElement.init(name: NTConstants.query, xmlns: <#T##String#>)
        
        
    }
    
    func getLastActivity(userId:String) -> Void {
        if let jid = XMPPJID(string: userId), let iq = XMPPIQ.lastActivityQuery(to: jid), let msgId = iq.elementID{
            
            let id = NTXMPPManager.sharedManager().xmppConnection?.xmppLastActivity.sendQuery(to: jid)
            
            self.outstandingXMPPStanzaResponseBlocks[id!] = { (success: Bool,iq: XMPPIQ) in
                if(success){
                    
                }
                
            }
            
            NTXMPPManager.sharedManager().xmppConnection?.sendElement(element: iq)
            
        }
    }

}

//MARK:----------------- IQ result completion --------------
extension NTIQManger{
    /**
     Perform completion block on completion of iq query
     */
    func callAndRemoveOutstandingBlock(success: Bool,iq: XMPPIQ){
        
        if let messageId = iq.elementID, let block = outstandingXMPPStanzaResponseBlocks[messageId]{
            block(success,iq)
            outstandingXMPPStanzaResponseBlocks.removeValue(forKey: messageId)
        }
        
    }
}

//MARK:----------------- XMPPStream IQ delegates----------------
extension NTIQManger: XMPPStreamDelegate{
    func xmppStream(_ sender: XMPPStream, didFailToSend iq: XMPPIQ, error: Error) {
        self.callAndRemoveOutstandingBlock(success: false, iq: iq)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        self.callAndRemoveOutstandingBlock(success: true, iq: iq)
        return true
    }
    
    func xmppStream(_ sender: XMPPStream, didSend iq: XMPPIQ) {
        
    }
}
