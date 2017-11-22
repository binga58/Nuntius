//
//  NTXMPPError.swift
//  Nuntius
//
//  Created by Abhishek Sharma on 22/11/17.
//  Copyright © 2017 Finoit Technologies. All rights reserved.
//

import UIKit

protocol GlobalError {
    var error: Error?{get set}
    var stanza: String?{get set}
}

enum XMPPStreamError {
    case streamNotConnected, userNotAuthenticated, userNotRegistered, streamDisconnected, connectionTimedOut, unknownError
}

class NTXMPPStreamError: NSObject, GlobalError {
    var error: Error?
    
    var stanza: String?
    
    var streamError: XMPPStreamError?
    
    var developerMessage: String?
    
    init(error: Error?, stanza: String?, streamError: XMPPStreamError) {
        super.init()
        self.error = error
        self.stanza = stanza
        self.streamError = streamError
    }

}
