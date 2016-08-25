//
//  BubbleTests.swift
//  n1
//
//  Created by Tainter, Aaron on 4/21/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import XCTest
@testable import nMessenger

class BubbleTests: XCTestCase {
    
    func testBubble() {
        let bubble = Bubble()
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
        XCTAssertEqual(bubble.hasLayerMask, false)
        
        var rect = CGRect(x: 0,y: 0,width: 50,height: 50)
        bubble.sizeToBounds(rect)
        XCTAssertEqual(rect.minX, bubble.calculatedBounds.minX)
        XCTAssertEqual(rect.minY, bubble.calculatedBounds.minY)
        XCTAssertEqual(rect.width, bubble.calculatedBounds.width)
        XCTAssertEqual(rect.height, bubble.calculatedBounds.height)
        
        rect = CGRectZero
        bubble.sizeToBounds(rect)
        XCTAssertEqual(rect.minX, bubble.calculatedBounds.minX)
        XCTAssertEqual(rect.minY, bubble.calculatedBounds.minY)
        XCTAssertEqual(rect.width, bubble.calculatedBounds.width)
        XCTAssertEqual(rect.height, bubble.calculatedBounds.height)
        
        bubble.createLayer()
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
    }
    
    func testBubbleSimple() {
        let bubble = SimpleBubble()
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
        XCTAssertEqual(bubble.hasLayerMask, false)
        
        var rect = CGRect(x: 0,y: 0,width: 50,height: 50)
        bubble.sizeToBounds(rect)
        XCTAssertEqual(rect.minX, bubble.calculatedBounds.minX)
        XCTAssertEqual(rect.minY, bubble.calculatedBounds.minY)
        XCTAssertEqual(rect.width, bubble.calculatedBounds.width)
        XCTAssertEqual(rect.height, bubble.calculatedBounds.height)
        
        rect = CGRectZero
        bubble.sizeToBounds(rect)
        XCTAssertEqual(rect.minX, bubble.calculatedBounds.minX)
        XCTAssertEqual(rect.minY, bubble.calculatedBounds.minY)
        XCTAssertEqual(rect.width, bubble.calculatedBounds.width)
        XCTAssertEqual(rect.height, bubble.calculatedBounds.height)
        
        bubble.createLayer()
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
    }
    
    func testBubbleDefault() {
        let bubble = DefaultBubble()
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
        XCTAssertEqual(bubble.hasLayerMask, false)
        
        var rect = CGRect(x: 0,y: 0,width: 50,height: 50)
        bubble.sizeToBounds(rect)
        XCTAssertEqual(rect.minX, bubble.calculatedBounds.minX)
        XCTAssertEqual(rect.minY, bubble.calculatedBounds.minY)
        XCTAssertEqual(rect.width, bubble.calculatedBounds.width)
        XCTAssertEqual(rect.height, bubble.calculatedBounds.height)
        
        rect = CGRectZero
        bubble.sizeToBounds(rect)
        XCTAssertEqual(rect.minX, bubble.calculatedBounds.minX)
        XCTAssertEqual(rect.minY, bubble.calculatedBounds.minY)
        XCTAssertEqual(rect.width, bubble.calculatedBounds.width)
        XCTAssertEqual(rect.height, bubble.calculatedBounds.height)
        
        bubble.createLayer()
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
    }
    
    func testBubbleStacked() {
        let bubble = StackedBubble()
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
        XCTAssertEqual(bubble.hasLayerMask, false)
        
        var rect = CGRect(x: 0,y: 0,width: 50,height: 50)
        bubble.sizeToBounds(rect)
        XCTAssertEqual(rect.minX, bubble.calculatedBounds.minX)
        XCTAssertEqual(rect.minY, bubble.calculatedBounds.minY)
        XCTAssertEqual(rect.width, bubble.calculatedBounds.width)
        XCTAssertEqual(rect.height, bubble.calculatedBounds.height)
        
        rect = CGRectZero
        bubble.sizeToBounds(rect)
        XCTAssertEqual(rect.minX, bubble.calculatedBounds.minX)
        XCTAssertEqual(rect.minY, bubble.calculatedBounds.minY)
        XCTAssertEqual(rect.width, bubble.calculatedBounds.width)
        XCTAssertEqual(rect.height, bubble.calculatedBounds.height)
        
        bubble.createLayer()
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
    }
    
    func testBubbleImage() {
        let bubble = ImageBubble()
        bubble.bubbleImage = UIImage(named: "MessageBubble")
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
        XCTAssertEqual(bubble.hasLayerMask, true)
        
        let rect = CGRect(x: 0,y: 0,width: 50,height: 50)
        bubble.sizeToBounds(rect)
        XCTAssertEqual(rect.minX, bubble.calculatedBounds.minX)
        XCTAssertEqual(rect.minY, bubble.calculatedBounds.minY)
        XCTAssertEqual(rect.width, bubble.calculatedBounds.width)
        XCTAssertEqual(rect.height, bubble.calculatedBounds.height)
        
        bubble.createLayer()
        XCTAssertNotNil(bubble.layer)
        XCTAssertNotNil(bubble.maskLayer)
    }
}