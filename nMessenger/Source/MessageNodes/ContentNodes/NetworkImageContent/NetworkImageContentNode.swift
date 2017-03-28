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
 NetworkImageContentNode class for N Messenger. Extends MessageNode.
 Defines content that is a network image (An image that is provided via url).
 */
open class NetworkImageContentNode: ContentNode,ASNetworkImageNodeDelegate {
    
    // MARK: Public Variables
    /** NSURL for the image*/
    open var url: URL? {
        get {
            return networkImageMessageNode.url
        } set {
            networkImageMessageNode.url = newValue
        }
    }
    
    // MARK: Private Variables
    /** ASNetworkImageNode as the content of the cell*/
    open fileprivate(set) var networkImageMessageNode:ASNetworkImageNode = ASNetworkImageNode()

    
    // MARK: Initialisers
    /**
     Initialiser for the cell.
     - parameter imageURL: Must be String. Sets url for the image in the cell.
     Calls helper method to setup cell
     */
    public init(imageURL: String, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupNetworkImageNode(imageURL)
    }
    
    // MARK: Initialiser helper method
    /** Override updateBubbleConfig to set bubble mask */
    open override func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol) {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = true
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    /**
     Sets the URL to be display in the image. Clips and rounds the corners.
     - parameter imageURL: Must be String. Sets url for the image in the cell.
     */
    fileprivate func setupNetworkImageNode(_ imageURL: String)
    {
        networkImageMessageNode.url = URL(string: imageURL)
        networkImageMessageNode.shouldCacheImage = true
        networkImageMessageNode.delegate = self
        self.addSubnode(networkImageMessageNode)
    }
    
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let width = constrainedSize.max.width
        self.networkImageMessageNode.style.width = ASDimension(unit: .points, value: width)
        self.networkImageMessageNode.style.height = ASDimension(unit: .points, value: width/4*3)
        let absLayoutSpec = ASAbsoluteLayoutSpec()
        absLayoutSpec.sizing = .sizeToFit
        absLayoutSpec.children = [self.networkImageMessageNode]
        return absLayoutSpec
    }
    
    // MARK: ASNetworkImageNodeDelegate
    /**
     Overriding didLoadImage to layout the node once the image is loaded
     */
    open func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        self.setNeedsLayout()
    }
    
    // MARK: UILongPressGestureRecognizer Selector Methods
    
    /**
     Overriding canBecomeFirstResponder to make cell first responder
     */
    override open func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    /**
     Override method from superclass
     */
    open override func messageNodeLongPressSelector(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            
            let touchLocation = recognizer.location(in: view)
            if self.networkImageMessageNode.frame.contains(touchLocation) {
                
                view.becomeFirstResponder()
                
                delay(0.1, closure: {
                    let menuController = UIMenuController.shared
                    menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(NetworkImageContentNode.copySelector))]
                    menuController.setTargetRect(self.networkImageMessageNode.frame, in: self.view)
                    menuController.setMenuVisible(true, animated:true)
                })
            }
        }
    }
    
    /**
     Copy Selector for UIMenuController
     Puts the node's image on UIPasteboard
     */
    open func copySelector() {
        if let image = self.networkImageMessageNode.image {
            UIPasteboard.general.image = image
        }
    }
    
}

