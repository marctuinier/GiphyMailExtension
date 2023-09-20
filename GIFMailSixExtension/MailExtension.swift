//
//  MailExtension.swift
//  GIFMailSixExtension
//
//  Created by Marc Tuinier on 9/16/23.
//

import MailKit

class MailExtension: NSObject, MEExtension {
    
    
    func handler(for session: MEComposeSession) -> MEComposeSessionHandler {
        // Create a unique instance, since each compose window is separate.
        return ComposeSessionHandler()
    }

    
}

