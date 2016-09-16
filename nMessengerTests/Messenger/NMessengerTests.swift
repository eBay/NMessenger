//
//  NMessengerTests.swift
//  n1
//
//  Created by Tainter, Aaron on 4/27/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import Foundation
import XCTest
import UIKit
@testable import nMessenger

/**
 Since you can't really unit test ui component, this is simply to make sure it doesn't crash or produce some unexpected behavior when used
 */
class NMessengerTests: XCTestCase {
    
    class TestVC: UIViewController, NMessengerDelegate {
        func batchFetchContent() {}
    }
    
    func testInit() {
        let testVC = TestVC()
        
       let messenger = NMessenger(frame: CGRect.zero)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        messenger.delegate = testVC
        XCTAssertNotNil(messenger.delegate)
        XCTAssertTrue(messenger.subviews.contains(messenger.messengerNode.view))
        
        let messenger2 = NMessenger()
        XCTAssertNotNil(messenger2)
        XCTAssertNotNil(messenger2.messengerNode)
        messenger2.delegate = testVC
        XCTAssertNotNil(messenger2.delegate)
        XCTAssertTrue(messenger.subviews.contains(messenger.messengerNode.view))
    }
    
    func testAdd() {
        let testVC = TestVC()
        let messenger = NMessenger()
        messenger.delegate = testVC
        let cell = GeneralMessengerCell()
        messenger.addMessage(cell, scrollsToMessage: false)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        messenger.addMessage(cell, scrollsToMessage: false, withAnimation: .none)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        messenger.addMessages([cell], scrollsToMessage: false)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        messenger.addMessages([cell], scrollsToMessage: false, withAnimation: .none)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        messenger.addMessages([GeneralMessengerCell](), scrollsToMessage: true)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        let expectationSuccess = expectation(description: "expectationSuccess")
        messenger.addMessagesWithBlock([cell], scrollsToMessage: false, withAnimation: .none) {
            XCTAssertNotNil(messenger)
            XCTAssertNotNil(messenger.messengerNode)
            expectationSuccess.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testAddMG() {
        let testVC = TestVC()
        let messenger = NMessenger()
        messenger.delegate = testVC
        let mg = MessageGroup()
        messenger.addMessage(mg, scrollsToMessage: false)
        let content = TextContentNode(textMessageString: "test")
        let mn = MessageNode(content: content)
        mn.currentViewController = testVC
        messenger.addMessageToMessageGroup(mn, messageGroup: mg, scrollsToLastMessage: false)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        XCTAssertTrue(mg.messages.contains(mn))
        
        let content2 = TextContentNode(textMessageString: "test")
        let mn2 = MessageNode(content: content2)
        mn2.currentViewController = testVC
        messenger.addMessageToMessageGroup(mn2, messageGroup: mg, scrollsToLastMessage: false, completion: nil)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        XCTAssertTrue(mg.messages.contains(mn2))
    }
    
    func testRemoveMG() {
        let testVC = TestVC()
        let messenger = NMessenger()
        messenger.delegate = testVC
        let mg = MessageGroup()
        messenger.addMessage(mg, scrollsToMessage: false)
        let content = TextContentNode(textMessageString: "test")
        let mn = MessageNode(content: content)
        mn.currentViewController = testVC
        messenger.addMessageToMessageGroup(mn, messageGroup: mg, scrollsToLastMessage: false)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        XCTAssertTrue(mg.messages.contains(mn))
        
        messenger.removeMessageFromMessageGroup(mn, messageGroup: mg, scrollsToLastMessage: false, toPosition: nil)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        XCTAssertFalse(mg.messages.contains(mn))
        
        messenger.addMessageToMessageGroup(mn, messageGroup: mg, scrollsToLastMessage: false, completion: nil)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        XCTAssertTrue(mg.messages.contains(mn))
        
        messenger.removeMessageFromMessageGroup(mn, messageGroup: mg, scrollsToLastMessage: false, toPosition: nil, completion: nil)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        XCTAssertFalse(mg.messages.contains(mn))
    }
    
    func testRemove() {
        let testVC = TestVC()
        let messenger = NMessenger()
        messenger.delegate = testVC
        
        messenger.clearALLMessages()
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        var cell = GeneralMessengerCell()
        messenger.removeMessage(cell, animation: .none)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        cell = GeneralMessengerCell()
        messenger.addMessage(cell, scrollsToMessage: false)
        messenger.removeMessage(cell, animation: .none)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        cell = GeneralMessengerCell()
        messenger.removeMessages([cell], animation: .none)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        cell = GeneralMessengerCell()
        messenger.addMessage(cell, scrollsToMessage: false)
        messenger.removeMessages([cell], animation: .none)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        messenger.removeMessages([GeneralMessengerCell](), animation: .none)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        cell = GeneralMessengerCell()
        messenger.addMessage(cell, scrollsToMessage: false)
        messenger.clearALLMessages()
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        let expectationSuccess = expectation(description: "expectationSuccess")
        cell = GeneralMessengerCell()
        messenger.addMessage(cell, scrollsToMessage: false)
        messenger.removeMessagesWithBlock([cell], animation: .none) {
            XCTAssertNotNil(messenger)
            XCTAssertNotNil(messenger.messengerNode)
            expectationSuccess.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testVariousUtilFunctions() {
        let testVC = TestVC()
        let messenger = NMessenger()
        messenger.delegate = testVC
        
        _ = messenger.allMessages()
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        let tmpCell = GeneralMessengerCell()
        messenger.addMessage(tmpCell, scrollsToMessage: false)
        _ = messenger.allMessages()
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        _ = messenger.hasMessage(tmpCell)
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        _ = messenger.hasMessage(GeneralMessengerCell())
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
        
        //do this to make sure everything else has been called
        let expectationSuccess = expectation(description: "expectationSuccess")
        let cell = GeneralMessengerCell()
        messenger.addMessage(cell, scrollsToMessage: false)
        messenger.removeMessagesWithBlock([cell], animation: .none) {
            XCTAssertNotNil(messenger)
            XCTAssertNotNil(messenger.messengerNode)
            expectationSuccess.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testTypingIndicators() {
        let testVC = TestVC()
        let messenger = NMessenger()
        messenger.delegate = testVC
        
        let indicator = GeneralMessengerCell(cellPadding: nil, currentViewController: nil)
        messenger.addTypingIndicator(indicator, scrollsToLast: false, animated: false, completion: nil)
        
        //TODO: can't test with message lock
        //XCTAssertTrue(messenger.hasIndicator(indicator))
        
        messenger.removeTypingIndicator(indicator, scrollsToLast: false, animated: false)
        
        XCTAssertFalse(messenger.hasIndicator(indicator))
    }
    
    /**
    full prefetch tests should be done in the functional test
     */
    func testBatchFetch() {
        let testVC = TestVC()
        let messenger = NMessenger()
        messenger.delegate = testVC
        messenger.endBatchFetchWithMessages([GeneralMessengerCell]())
        XCTAssertNotNil(messenger)
        XCTAssertNotNil(messenger.messengerNode)
    }
    
}
