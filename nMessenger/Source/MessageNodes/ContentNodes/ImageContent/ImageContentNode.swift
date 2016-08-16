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
public class ImageContentNode: ContentNode {
    
    // MARK: Public Variables
    /** UIImage as the image of the cell*/
    public var image: UIImage? {
        get {
            return imageMessegeNode.image
        } set {
            imageMessegeNode.image = newValue
        }
    }
    
    // MARK: Private Variables
    /** ASImageNode as the content of the cell*/
    public private(set) var imageMessegeNode:ASImageNode = ASImageNode()
    
    // MARK: Initialisers
    
    /**
     Initialiser for the cell.
     - parameter image: Must be UIImage. Sets image for cell.
     Calls helper methond to setup cell
     */
    public init(image: UIImage, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupImageNode(image)
    }
    
    // MARK: Initialiser helper method
    /** Override updateBubbleConfig to set bubble mask */
    public override func updateBubbleConfig(newValue: BubbleConfigurationProtocol) {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = true
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    /**
     Sets the image to be display in the cell. Clips and rounds the corners.
     - parameter image: Must be UIImage. Sets image for cell.
     */
    private func setupImageNode(image: UIImage)
    {
        imageMessegeNode.image = image
        imageMessegeNode.clipsToBounds = true
        imageMessegeNode.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageMessegeNode.accessibilityIdentifier = "imageNode"
        self.imageMessegeNode.isAccessibilityElement = true
        self.addSubnode(imageMessegeNode)
    }
    
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override public func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let width = UIScreen.mainScreen().bounds.width/3*2
        
        imageMessegeNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(width, width/4*3))
        return ASStaticLayoutSpec(children: [self.imageMessegeNode])
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
            if CGRectContainsPoint(self.imageMessegeNode.frame, touchLocation) {
                
                view.becomeFirstResponder()
                
                delay(0.1, closure: {
                    let menuController = UIMenuController.sharedMenuController()
                    menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(ImageContentNode.copySelector))]
                    menuController.setTargetRect(self.imageMessegeNode.frame, inView: self.view)
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
        if let image = self.image {
            UIPasteboard.generalPasteboard().image = image
        }
    }
    
}

