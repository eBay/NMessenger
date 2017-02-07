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

//MARK: CustomContentMessageNode
/**
 Custom View Message class for NMessenger. Extends ContentNode.
 Defines content that is a custom. Content can be a view or a node.
 */
open class CustomContentNode: ContentNode {
    
    // MARK: Public Variables
    /** Insets for the node */
    open var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            setNeedsLayout()
        }
    }
    /**Should the bubble be masked or not*/
    open var maskedBubble = true {
        didSet {
            self.updateBubbleConfig(self.bubbleConfiguration)
            self.setNeedsLayout()
        }
    }
    
    // MARK: Private Variables
    /** ASCollectionNode as the content of the cell*/
    open fileprivate(set) var customContentMessageNode:ASDisplayNode = ASDisplayNode()
    /** UIView as the posiible view of the cell*/
    fileprivate var customView:UIView?
    /** ASDisplayNode as the posiible view of the cell*/
    fileprivate var customNode:ASDisplayNode?
   
    
    // MARK: Initialisers
    
    /**
     Initialiser for the cell.
     - parameter customView: Must be UIView. Sets view for the cell.
     Calls helper method to setup cell
     */
    public init(withCustomView customView: UIView, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupCustomView(customView)
    }
    
    /**
     Initialiser for the cell.
     - parameter customNode: Must be ASDisplayNode. Sets view for the cell.
     Calls helper method to setup cell
     */
    public init(withCustomNode customNode: ASDisplayNode, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupCustomNode(customNode)
    }
    
    // MARK: Initialiser helper methods
     /** Override updateBubbleConfig to set bubble mask */
    open override func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol) {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = self.maskedBubble
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    /**
     Adds subview to the content
     - parameter customView: Must be UIView. Sets view for the cell.
     */
    fileprivate func setupCustomView(_ customView: UIView)
    {
        self.customView = customView
        DispatchQueue.main.async {
            self.customContentMessageNode.view.addSubview(customView)
            self.customContentMessageNode.preferredFrameSize = customView.frame.size
        }
        self.addSubnode(customContentMessageNode)
    }
    
    /**
     Adds subnode to the content
     - parameter customNode: Must be ASDisplayNode. Sets view for the cell.
     */
    fileprivate func setupCustomNode(_ customNode: ASDisplayNode)
    {
        self.isUserInteractionEnabled = true
        self.customNode = customNode
        self.customNode?.isUserInteractionEnabled = true
        customContentMessageNode = customNode
        self.addSubnode(customContentMessageNode)
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let width = constrainedSize.max.width
        
        let max = ASRelativeSizeMake(ASDimension(unit: .points, value: width), ASDimension(unit: .fraction, value: 1))
        let tmp = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSize.zero), max)
        
        customContentMessageNode.sizeRange = tmp
        let customContentSpec = ASStaticLayoutSpec()
        customContentSpec.children = [customContentMessageNode]
        return ASInsetLayoutSpec(insets: insets, child: customContentSpec)
    }
    
}
