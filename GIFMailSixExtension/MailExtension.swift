//
//  MailExtension.swift
//  GIFMailSixExtension
//
//  Created by Marc Tuinier on 9/16/23.
//

import MailKit

class MailExtension: NSObject, MEExtension {
    func handler(for session: MEComposeSession) -> MEComposeSessionHandler {
        return ComposeSessionHandler()
    }
}
