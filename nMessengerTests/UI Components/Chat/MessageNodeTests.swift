//
//  MessageNodeTests.swift
//  nMessenger
//
//  Created by Tainter, Aaron on 8/23/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import Foundation

import XCTest
import AsyncDisplayKit
@testable import nMessenger

class MessageNodeTests: XCTestCase {
    func testInitialize() {
        let textContent = TextContentNode(textMessegeString: "blah")
        let message = MessageNode(content: textContent)
        
        XCTAssertNotNil(message)
        XCTAssertNotNil(message.contentNode)
        XCTAssertEqual(message.contentNode, textContent)
        
        //reset content
        let newContent = TextContentNode(textMessegeString: "blah2")
        message.contentNode = newContent
        
        XCTAssertNotNil(message)
        XCTAssertNotNil(message.contentNode)
        XCTAssertEqual(message.contentNode, newContent)
        
        //test header
        var headerNode = ASDisplayNode()
        message.headerNode = headerNode
        
        XCTAssertNotNil(message.headerNode)
        XCTAssertEqual(message.headerNode, headerNode)
        
        headerNode = ASDisplayNode()
        message.headerNode = headerNode
        
        XCTAssertNotNil(message.headerNode)
        XCTAssertEqual(message.headerNode, headerNode)
        
        //test footer
        var footerNode = ASDisplayNode()
        message.footerNode = footerNode
        
        XCTAssertNotNil(message.footerNode)
        XCTAssertEqual(message.footerNode, footerNode)
        
        footerNode = ASDisplayNode()
        message.footerNode = footerNode
        
        XCTAssertNotNil(message.footerNode)
        XCTAssertEqual(message.footerNode, footerNode)
        
        //test avatar
        var avatarNode = ASDisplayNode()
        message.avatarNode = avatarNode
        
        XCTAssertNotNil(message.avatarNode)
        XCTAssertEqual(message.avatarNode, avatarNode)
        
        avatarNode = ASDisplayNode()
        message.avatarNode = avatarNode
        
        XCTAssertNotNil(message.avatarNode)
        XCTAssertEqual(message.avatarNode, avatarNode)
        
        
        //avatar insets
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        message.avatarInsets = insets
        
        XCTAssertNotNil(message.avatarInsets)
        XCTAssertEqual(message.avatarInsets, insets)
        
        
        //message offset
        let messageOffset: CGFloat = 10
        message.messageOffset = messageOffset
        
        XCTAssertNotNil(message.messageOffset)
        XCTAssertEqual(message.messageOffset, messageOffset)
        
        
        //header spacing
        let headerSpacing: CGFloat = 10
        message.headerSpacing = headerSpacing
        
        XCTAssertNotNil(message.headerSpacing)
        XCTAssertEqual(message.headerSpacing, headerSpacing)

        
        //footer spacing
        let footerSpacing: CGFloat = 10
        message.footerSpacing = footerSpacing
        
        XCTAssertNotNil(message.footerSpacing)
        XCTAssertEqual(message.footerSpacing, footerSpacing)

        
        //incoming message
        message.isIncomingMessage = false
        XCTAssertNotNil(message.contentNode)
        XCTAssertFalse(message.contentNode!.isIncomingMessage)
        
    }
}