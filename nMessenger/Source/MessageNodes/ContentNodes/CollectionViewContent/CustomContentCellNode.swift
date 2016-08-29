//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit

//MARK: CustomContentCellNode
/**
 CustomContentCellNode class for N Messenger.
 Define the cell for CollectionViewContentNode
 */
public class CustomContentCellNode: ASCellNode {
    
    // MARK: Public Variables
    /** ASDisplayNode as the content of the cell*/
    public var customContent:ASDisplayNode = ASDisplayNode()
    
    // MARK: Initialisers
    
    /**
     Initialiser for the cell.
     - parameter withCustomNode: Must be ASDisplayNode. Sets content for the cell.
     */
    public init(withCustomNode node:ASDisplayNode)
    {
        super.init()
        self.customContent = node
        self.addSubnode(self.customContent)
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override public func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let customContetntSpec = ASStaticLayoutSpec(children: [customContent])
        return customContetntSpec
    }    
}
