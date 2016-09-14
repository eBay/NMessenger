//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import AsyncDisplayKit

//MARK: ContentNode
/**
 Content node class for NMessenger.
 Define the content a a MessageNode or a MessageGroup
 */
open class ContentNode: ASDisplayNode {
    
    // MARK: Public Parameters
    /** Bubble that defines the background for the message*/
    open var backgroundBubble: Bubble?
    /** UIViewController that holds the cell. Allows the cell the present View Controllers. Generally used for UIMenu or UIAlert Options*/
    open var currentViewController: UIViewController?
    /** MessageConfigurationProtocol hold common definition for all messages. Defaults to **StandardMessageConfiguration***/
    open var bubbleConfiguration : BubbleConfigurationProtocol = StandardBubbleConfiguration() {
        didSet {
            self.updateBubbleConfig(self.bubbleConfiguration)
        }
    }
    /** Bool if the cell is an incoming or out going message.
     Set backgroundBubble.bubbleColor when value is changed
     */
    open var isIncomingMessage = true {
        didSet {
             self.backgroundBubble?.bubbleColor = isIncomingMessage ? bubbleConfiguration.getIncomingColor() : bubbleConfiguration.getOutgoingColor()
            
            self.setNeedsLayout()
        }
    }
    
    // MARK: Initialisers
    /**
     Overriding init to initialise the node
     */    
    public init(bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        if let bubbleConfiguration = bubbleConfiguration {
            self.bubbleConfiguration = bubbleConfiguration
        }
        super.init()
        //make sure the bubble is set correctly
        self.updateBubbleConfig(self.bubbleConfiguration)
    }
    
    //MARK: Node Lifecycle
    /**
     Overriding didLoad and calling helper method addSublayers
     */
    override open func didLoad() {
        super.didLoad()
        self.addSublayers()
    }
    
    //MARK: Node Lifecycle helper methods
    
    /** Updates the bubble config by setting all necessary properties (background bubble, bubble color, layout)
     - parameter newValue: the new BubbleConfigurationProtocol
     */
    open func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol) {
        self.backgroundBubble = self.bubbleConfiguration.getBubble()
        
        self.backgroundBubble?.bubbleColor = isIncomingMessage ? bubbleConfiguration.getIncomingColor() : bubbleConfiguration.getOutgoingColor()
        
        self.setNeedsLayout()
    }
    
    /**
     Called during the initializer and makes sure layers are added on the main thread
     */
    open func addSublayers() {
        if let backgroundBubble = self.backgroundBubble {
            //make sure the layer is at the bottom of the node
            backgroundBubble.layer.removeFromSuperlayer()
            backgroundBubble.maskLayer.removeFromSuperlayer()
            
            self.layer.insertSublayer(backgroundBubble.layer, at: 0)
            
            //If there is a layer mask, add it
            if backgroundBubble.hasLayerMask {
                self.layer.insertSublayer(backgroundBubble.maskLayer, below: backgroundBubble.layer)
                self.layer.mask = backgroundBubble.maskLayer
            }
        }
    }

    
    //MARK: Override AsycDisaplyKit Methods
    
    /**
     Draws the content in the bubble. This is called on a background thread.
     */
    open func drawRect(_ bounds: CGRect, withParameters parameters: NSObjectProtocol!,
                  isCancelled isCancelledBlock: asdisplaynode_iscancelled_block_t, isRasterizing: Bool) {
        self.isOpaque = false
        if !isRasterizing {
            self.calculateLayerPropertiesThatFit(bounds)
            
            //call the main queue
            DispatchQueue.main.async {
                self.layoutLayers()
            }
        }
    }
    
    
    //MARK: Override AsycDisaplyKit helper methods
    
    /**
     Called through the draw rect function. This should be used to create a background layer off the main thread. This layer should be added in layout.
     - parameter bounds: Must be CGRect
     */
    open func calculateLayerPropertiesThatFit(_ bounds: CGRect) {
        if let backgroundBubble = self.backgroundBubble {
             backgroundBubble.sizeToBounds(bounds)
        }
    }
    
    /**
     Called on the main thread
     */
    open func layoutLayers() {
        if let backgroundBubble = self.backgroundBubble {
            backgroundBubble.createLayer()
            
            //TODO: this is slightly hacky, will need to rethink
            if isIncomingMessage {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                backgroundBubble.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(-1, 1, 1), -backgroundBubble.calculatedBounds.width, 0, 0)
                backgroundBubble.maskLayer.transform = CATransform3DTranslate(CATransform3DMakeScale(-1, 1, 1), -backgroundBubble.calculatedBounds.width, 0, 0)
                CATransaction.commit()
            }
        }
    }
    
    /**
     Calls closer after a time delay
     - parameter delay: Must be Double.
     - parameter closure: Must be an ()->()
     */
    open func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }

    
    //MARK: UITapGestureRecognizer Selector
    
    /**
     Selector to handle long press on message and show custom menu
     - parameter recognizer: Must be UITapGestureRecognizer
     */
    open func messageNodeLongPressSelector(_ recognizer: UITapGestureRecognizer) {
    }

}
