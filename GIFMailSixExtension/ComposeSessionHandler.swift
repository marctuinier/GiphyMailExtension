//
//  ComposeSessionHandler.swift
//  GIFMailSixExtension
//
//  Created by Marc Tuinier on 9/16/23.
//

import MailKit

class ComposeSessionHandler: NSObject, MEComposeSessionHandler {

    func mailComposeSessionDidBegin(_ session: MEComposeSession) {
    }

    func mailComposeSessionDidEnd(_ session: MEComposeSession) {
    }

    func viewController(for session: MEComposeSession) -> MEExtensionViewController {
        return ComposeSessionViewController()
    }

    func allowMessageSendForSession(_ session: MEComposeSession, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}
