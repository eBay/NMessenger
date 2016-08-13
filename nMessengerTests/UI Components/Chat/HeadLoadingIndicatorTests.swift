//
//  HeadLoadingIndicatorTests.swift
//  n1
//
//  Created by Tainter, Aaron on 4/26/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import Foundation
import XCTest
import AsyncDisplayKit
@testable import nMessenger

class HeadLoadingIndicatorTests: XCTestCase {
    
    func testElement() {
        let loadingIndicator = HeadLoadingIndicator()
        XCTAssertNotNil(loadingIndicator.spinner)
        XCTAssertNotNil(loadingIndicator.text)
        loadingIndicator.layoutSpecThatFits(ASSizeRange(min: CGSize(width: 50, height: 10), max:  CGSize(width: 200, height: 20)))
    }
    
    func testSpinner() {
        let spinner = SpinnerNode()
        XCTAssertNotNil(spinner.activityIndicatorView)
    }
}