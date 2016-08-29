//
//  MessageGroupTests.swift
//  n1
//
//  Created by Tainter, Aaron on 5/9/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import XCTest
import AsyncDisplayKit
@testable import nMessenger

class MessageGroupTests: XCTestCase {
    func testInitialize() {
        let messageGroup = MessageGroup()
        
        let textContent = TextContentNode(textMessageString: "blah")
        let newCell = MessageNode(content: textContent)
        messageGroup.addMessageToGroup(newCell, completion: nil)
        
        XCTAssertEqual(messageGroup.messages.count, 1)
        XCTAssertEqual(messageGroup.messages.last, newCell)
        
        messageGroup.removeMessageFromGroup(newCell, completion: nil)
        
        XCTAssertEqual(messageGroup.messages.count, 0)
        
        messageGroup.removeMessageFromGroup(newCell, completion: nil)
        
        XCTAssertEqual(messageGroup.messages.count, 0)
        
        messageGroup.addMessageToGroup(newCell, completion: nil)
        
        let textContent2 = TextContentNode(textMessageString: "blah")
        let newCell2 = MessageNode(content: textContent2)
        messageGroup.replaceMessage(newCell, withMessage: newCell2, completion: nil)
        
        XCTAssertEqual(messageGroup.messages.count, 1)
        XCTAssertEqual(messageGroup.messages.last, newCell2)
        
        //test avatar
        var avatarNode = ASDisplayNode()
        messageGroup.avatarNode = avatarNode
        
        XCTAssertNotNil(messageGroup.avatarNode)
        XCTAssertEqual(messageGroup.avatarNode, avatarNode)
        
        avatarNode = ASDisplayNode()
        messageGroup.avatarNode = avatarNode
        
        XCTAssertNotNil(messageGroup.avatarNode)
        XCTAssertEqual(messageGroup.avatarNode, avatarNode)
        
        //avatar insets
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageGroup.avatarInsets = insets
        
        XCTAssertNotNil(messageGroup.avatarInsets)
        XCTAssertEqual(messageGroup.avatarInsets, insets)
        
        //message offset
        let messageOffset: CGFloat = 10
        messageGroup.messageOffset = messageOffset
        
        XCTAssertNotNil(messageGroup.messageOffset)
        XCTAssertEqual(messageGroup.messageOffset, messageOffset)
        
        //incoming message
        messageGroup.isIncomingMessage = false
        
        for cell in messageGroup.messages {
            if let message = cell as? MessageNode {
                XCTAssertNotNil(message.contentNode)
                XCTAssertFalse(message.contentNode!.isIncomingMessage)
            }
        }
    }
}