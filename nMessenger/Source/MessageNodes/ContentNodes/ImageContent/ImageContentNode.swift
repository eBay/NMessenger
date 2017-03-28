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

//MARK: ImageContentNode
/**
 ImageContentNode for NMessenger. Extends ContentNode.
 Defines content that is an image.
 */
open class ImageContentNode: ContentNode {
    
    // MARK: Public Variables
    /** UIImage as the image of the cell*/
    open var image: UIImage? {
        get {
            return imageMessageNode.image
        } set {
            imageMessageNode.image = newValue
        }
    }
    
    // MARK: Private Variables
    /** ASImageNode as the content of the cell*/
    open fileprivate(set) var imageMessageNode:ASImageNode = ASImageNode()
    
    // MARK: Initialisers
    
    /**
     Initialiser for the cell.
     - parameter image: Must be UIImage. Sets image for cell.
     Calls helper method to setup cell
     */
    public init(image: UIImage, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupImageNode(image)
    }
    
    // MARK: Initialiser helper method
    /** Override updateBubbleConfig to set bubble mask */
    open override func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol) {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = true
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    /**
     Sets the image to be display in the cell. Clips and rounds the corners.
     - parameter image: Must be UIImage. Sets image for cell.
     */
    fileprivate func setupImageNode(_ image: UIImage)
    {
        imageMessageNode.image = image
        imageMessageNode.clipsToBounds = true
        imageMessageNode.contentMode = UIViewContentMode.scaleAspectFill
        self.imageMessageNode.accessibilityIdentifier = "imageNode"
        self.imageMessageNode.isAccessibilityElement = true
        self.addSubnode(imageMessageNode)
    }
    
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let width = constrainedSize.max.width
        self.imageMessageNode.style.width = ASDimension(unit: .points, value: width)
        self.imageMessageNode.style.height = ASDimension(unit: .points, value: width/4*3)
        let absLayout = ASAbsoluteLayoutSpec()
        absLayout.sizing = .sizeToFit
        absLayout.children = [self.imageMessageNode]
        return absLayout
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
            if self.imageMessageNode.frame.contains(touchLocation) {
                
                view.becomeFirstResponder()
                
                delay(0.1, closure: {
                    let menuController = UIMenuController.shared
                    menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(ImageContentNode.copySelector))]
                    menuController.setTargetRect(self.imageMessageNode.frame, in: self.view)
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
        if let image = self.image {
            UIPasteboard.general.image = image
        }
    }
    
}

