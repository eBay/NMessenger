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

//MARK: NetworkImageContentNode
/**
 NetworkImageContentNode class for N Messanger. Extends MessageNode.
 Defines content that is a network image (An image that is provided via url).
 */
public class NetworkImageContentNode: ContentNode,ASNetworkImageNodeDelegate {
    
    // MARK: Public Variables
    /** NSURL for the image*/
    public var url: NSURL? {
        get {
            return networkImageMessegeNode.URL
        } set {
            networkImageMessegeNode.URL = newValue
        }
    }
    
    // MARK: Private Variables
    /** ASNetworkImageNode as the content of the cell*/
    private(set) var networkImageMessegeNode:ASNetworkImageNode = ASNetworkImageNode()

    
    // MARK: Initialisers
    /**
     Initialiser for the cell.
     - parameter imageURL: Must be String. Sets url for the image in the cell.
     Calls helper methond to setup cell
     */
    public init(imageURL: String, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupNetworkImageNode(imageURL)
    }
    
    // MARK: Initialiser helper method
    /** Override updateBubbleConfig to set bubble mask */
    public override func updateBubbleConfig(newValue: BubbleConfigurationProtocol) {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = true
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    /**
     Sets the URL to be display in the image. Clips and rounds the corners.
     - parameter imageURL: Must be String. Sets url for the image in the cell.
     */
    private func setupNetworkImageNode(imageURL: String)
    {
        networkImageMessegeNode.URL = NSURL(string: imageURL)
        networkImageMessegeNode.shouldCacheImage = true
        networkImageMessegeNode.delegate = self
        self.addSubnode(networkImageMessegeNode)
    }
    
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override public func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let width = UIScreen.mainScreen().bounds.width/3*2
        self.networkImageMessegeNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(width, width/4*3))
        return ASStaticLayoutSpec(children: [self.networkImageMessegeNode])
    }
    
    // MARK: ASNetworkImageNodeDelegate
    /**
     Overriding didLoadImage to layout the node once the image is loaded
     */
    public func imageNode(imageNode: ASNetworkImageNode, didLoadImage image: UIImage) {
        self.setNeedsLayout()
    }
    
    // MARK: UILongPressGestureRecognizer Selector Methods
    
    /**
     Overriding canBecomeFirstResponder to make cell first responder
     */
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    /**
     Override method from superclass
     */
    public override func messageNodeLongPressSelector(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            
            let touchLocation = recognizer.locationInView(view)
            if CGRectContainsPoint(self.networkImageMessegeNode.frame, touchLocation) {
                
                view.becomeFirstResponder()
                
                delay(0.1, closure: {
                    let menuController = UIMenuController.sharedMenuController()
                    menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(NetworkImageContentNode.copySelector))]
                    menuController.setTargetRect(self.networkImageMessegeNode.frame, inView: self.view)
                    menuController.setMenuVisible(true, animated:true)
                })
            }
        }
    }
    
    /**
     Copy Selector for UIMenuController
     Puts the node's image on UIPasteboard
     */
    public func copySelector() {
        if let image = self.networkImageMessegeNode.image {
            UIPasteboard.generalPasteboard().image = image
        }
    }
    
}

