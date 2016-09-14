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
import UIKit
import AsyncDisplayKit

//MARK: Bubble class
/**
 'Abstract' Bubble class. Subclass for creating a custom bubble
 */
open class Bubble {
    
    // MARK: Public Parameters
    open var bubbleColor : UIColor = UIColor.n1PaleGreyColor()
    
    /** When this is set, the layer mask will mask the ContentNode.*/
    open var hasLayerMask = false
    
    /**
     A layer for the bubble. Make sure this property is first accessed on the main thread.
     */
    open lazy var layer: CAShapeLayer = CAShapeLayer()
    /**
     A layer that holds a mask which is the same shape as the bubble. This can be used to mask anything in the ContentNode to the same shape as the bubble.
     */
    open lazy var maskLayer: CAShapeLayer = CAShapeLayer()
        
    /** Bounds of the bubble*/
    open var calculatedBounds = CGRect.zero
    
    // MARK: Initialisers
    public init() {}
    
    // MARK: Class methods
    /**
     Sizes the layer accordingly. This function should **always** be thread safe.
     -parameter bounds: The bounds of the content
     */
    open func sizeToBounds(_ bounds: CGRect) {
        self.calculatedBounds = bounds
    }
    
    
    /**
     This function should be called on the  main thread. It makes creates the layer with the calculated values from *sizeToBounds*
     */
    open func createLayer() {
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.maskLayer.shouldRasterize = true
        self.maskLayer.rasterizationScale = UIScreen.main.scale
    }
    
}
