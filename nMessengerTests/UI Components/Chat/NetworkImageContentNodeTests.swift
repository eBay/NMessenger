//
//  NetworkImageContentNodeTests.swift
//  n1
//
//  Created by Schechter, David on 4/27/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import XCTest
import AsyncDisplayKit
@testable import nMessenger

class NetworkImageContentNodeTests: XCTestCase {
    
    func testNetworkImage() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let testNetworkImage = NetworkImageContentNode(imageURL: "http://placehold.it/100x100")
        let tmpSize = CGSize(width: 100, height: 100)
        let tmpRecongnizer = UITapGestureRecognizer()
        _ = testNetworkImage.layoutSpecThatFits(ASSizeRangeMake(tmpSize, tmpSize))
        testNetworkImage.messageNodeLongPressSelector(tmpRecongnizer)
        testNetworkImage.copySelector()
        _ = testNetworkImage.canBecomeFirstResponder()
    }
    
}
