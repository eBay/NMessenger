//
//  MessageGroupTests.swift
//  n1
//
//  Created by Tainter, Aaron on 5/9/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import XCTest
@testable import nMessenger

class MessageGroupTests: XCTestCase {
    func testInitialize() {
        let messageGroup = MessageGroup()
        
        let textContent = TextContentNode(textMessegeString: "blah")
        let newCell = MessageNode(content: textContent)
        messageGroup.addMessageToGroup(newCell, completion: nil)
        
        XCTAssertEqual(messageGroup.messages.count, 1)
        XCTAssertEqual(messageGroup.messages.last, newCell)
        
        messageGroup.removeMessageFromGroup(newCell, completion: nil)
        
        XCTAssertEqual(messageGroup.messages.count, 0)
        
        messageGroup.removeMessageFromGroup(newCell, completion: nil)
        
        XCTAssertEqual(messageGroup.messages.count, 0)
    }
}