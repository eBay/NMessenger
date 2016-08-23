//
//  UIFontTests.swift
//  nMessenger
//
//  Created by Tainter, Aaron on 8/23/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import XCTest
@testable import nMessenger

class N1FontTests: XCTestCase {
    func testFontsForValues() {
        XCTAssertNotNil(UIFont.n1B1Font())
        XCTAssertNotNil(UIFont.n1B2Font())
        XCTAssertNotNil(UIFont.n1H1Font())
        XCTAssertNotNil(UIFont.n1H2Font())
        XCTAssertNotNil(UIFont.n1H3Font())
        XCTAssertNotNil(UIFont.n1LinkFont())
        XCTAssertNotNil(UIFont.n1CaptionFont())
        XCTAssertNotNil(UIFont.n1TextStyleFont())
        XCTAssertNotNil(UIFont.n1TextStyle3Font())
        XCTAssertNotNil(UIFont.n1TextStyle3MiniFont())
        XCTAssertNotNil(UIFont.n1TextStyle2Font())
        XCTAssertNotNil(UIFont.n1TextStyle4Font())
    }
}