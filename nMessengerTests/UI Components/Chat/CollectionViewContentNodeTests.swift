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
        let tmpView = UIView(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
        let tempColectionNode = CollectionViewContentNode(withCustomViews: [tmpView], andNumberOfRows: 1)
        let tmpSize = CGSize(width: 100, height: 100)
        _ = tempColectionNode.layoutSpecThatFits(ASSizeRangeMake(tmpSize, tmpSize))
        let tmpCollection = UICollectionView(frame: CGRect(x: 0,y: 0,width: 100,height: 100), collectionViewLayout: UICollectionViewFlowLayout())
        _ = tempColectionNode.collectionView(tmpCollection, numberOfItemsInSection: 0)
    }
    
}
