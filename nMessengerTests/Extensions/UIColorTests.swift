//
//  UIColorTests.swift
//  nMessenger
//
//  Created by Tainter, Aaron on 8/23/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import XCTest
@testable import nMessenger

class UIColorTests: XCTestCase {
    func testColorsForValues() {
        XCTAssertNotNil(UIColor.n1WhiteColor())
        XCTAssertNotNil(UIColor.n1MidGreyColor())
        XCTAssertNotNil(UIColor.n1BrandRedColor())
        XCTAssertNotNil(UIColor.n1DarkGreyColor())
        XCTAssertNotNil(UIColor.n1PaleGreyColor())
        XCTAssertNotNil(UIColor.n1LightGreyColor())
        XCTAssertNotNil(UIColor.n1ActionBlueColor())
        XCTAssertNotNil(UIColor.n1DarkerGreyColor())
        XCTAssertNotNil(UIColor.n1AlmostWhiteColor())
        XCTAssertNotNil(UIColor.n1DarkestGreyColor())
        XCTAssertNotNil(UIColor.n1LighterGreyColor())
        XCTAssertNotNil(UIColor.n1OverlayBorderColor())
        XCTAssertNotNil(UIColor.n1Black50Color())
        XCTAssertNotNil(UIColor.randomColor())
        XCTAssertNotNil(UIColor.colorFromRGB(0x000000))
    }
}