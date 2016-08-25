//
//  BubbleConfigurationTests.swift
//  nMessenger
//
//  Created by Tainter, Aaron on 8/23/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//


import XCTest
@testable import nMessenger

class BubbleConfigurationTests: XCTestCase {

    func testStandardConfig() {
        let bc = StandardBubbleConfiguration()
        XCTAssertNotNil(bc.getBubble())
        XCTAssertNotNil(bc.getSecondaryBubble())
        XCTAssertNotNil(bc.getIncomingColor())
        XCTAssertNotNil(bc.getOutgoingColor())
        
        bc.isMasked = true
        XCTAssertNotNil(bc.getBubble())
        XCTAssertNotNil(bc.getSecondaryBubble())
        XCTAssertNotNil(bc.getIncomingColor())
        XCTAssertNotNil(bc.getOutgoingColor())
        
        XCTAssertTrue(bc.getBubble().hasLayerMask)
        XCTAssertTrue(bc.getSecondaryBubble().hasLayerMask)
    
    }
    
    func testSimpleBubbleConfig() {
        let bc = SimpleBubbleConfiguration()
        XCTAssertNotNil(bc.getBubble())
        XCTAssertNotNil(bc.getSecondaryBubble())
        XCTAssertNotNil(bc.getIncomingColor())
        XCTAssertNotNil(bc.getOutgoingColor())

        bc.isMasked = true
        XCTAssertNotNil(bc.getBubble())
        XCTAssertNotNil(bc.getSecondaryBubble())
        XCTAssertNotNil(bc.getIncomingColor())
        XCTAssertNotNil(bc.getOutgoingColor())
        
        XCTAssertTrue(bc.getBubble().hasLayerMask)
        XCTAssertTrue(bc.getSecondaryBubble().hasLayerMask)
    }
    
    func testImageBubbleConfiguration() {
        let bc = ImageBubbleConfiguration()
        XCTAssertNotNil(bc.getBubble())
        XCTAssertNotNil(bc.getSecondaryBubble())
        XCTAssertNotNil(bc.getIncomingColor())
        XCTAssertNotNil(bc.getOutgoingColor())
        
        bc.isMasked = true
        XCTAssertNotNil(bc.getBubble())
        XCTAssertNotNil(bc.getSecondaryBubble())
        XCTAssertNotNil(bc.getIncomingColor())
        XCTAssertNotNil(bc.getOutgoingColor())
        
        XCTAssertTrue(bc.getBubble().hasLayerMask)
        XCTAssertTrue(bc.getSecondaryBubble().hasLayerMask)
    }

}