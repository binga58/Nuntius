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
    
    func getXMPPServerTime() -> DDXMLElement {
        
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
                
                if let timeElement = iq.element(forName: Constants.time), let utcTimeStanza = timeElement.element(forName: Constants.utc), let utcTime = utcTimeStanza.stringValue, let serverDateTime = NSDate.init(xmppDateTime: utcTime){
                    
                    //Current UTC time
                    let currentDateTime = NSDate()
                    //Differnce between server and current time
                    let difference = currentDateTime.timeIntervalSince(serverDateTime as Date)
                    //Saving the difference
                    NTXMPPManager.sharedManager().xmppServerTimeDifference = difference
                }
            }
        }
        
        //Creates stanza for requesting server time
        let serverTimeNode = XMPPIQ.init(iqType: .get)
        serverTimeNode.addAttribute(withName: Constants.from, stringValue: NTUtility.getCurrentUserFullId())
        serverTimeNode.addAttribute(withName: Constants.id, stringValue: messageId)
        serverTimeNode.addAttribute(withName: Constants.to, stringValue: NTXMPPManager.sharedManager().xmppAccount.serverDomain!)
        
        let timenode = DDXMLElement.init(name: Constants.time, xmlns: Constants.xmlnsType.time)
        serverTimeNode.addChild(timenode)
        
        
        return serverTimeNode
    }
    
    func callAndRemoveOutstandingBlock(success: Bool,iq: XMPPIQ){
        
        if let messageId = iq.elementID, let block = outstandingXMPPStanzaResponseBlocks[messageId]{
            block(success,iq)
            outstandingXMPPStanzaResponseBlocks.removeValue(forKey: messageId)
        }
        
    }

}
