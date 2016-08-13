//
//  CollectionViewContentNodeTests.swift
//  n1
//
//  Created by Schechter, David on 4/28/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import XCTest
import AsyncDisplayKit
@testable import nMessenger

class CollectionViewContentNodeTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let tmpView = UIView(frame: CGRectMake(0,0,100,100))
        let tempColectionNode = CollectionViewContentNode(withCustomViews: [tmpView], andNumberOfRows: 1)
        let tmpSize = CGSizeMake(100, 100)
        tempColectionNode.layoutSpecThatFits(ASSizeRangeMake(tmpSize, tmpSize))
        let tmpCollection = UICollectionView(frame: CGRectMake(0,0,100,100), collectionViewLayout: UICollectionViewFlowLayout())
        tempColectionNode.collectionView(tmpCollection, numberOfItemsInSection: 0)
    }
    
}
