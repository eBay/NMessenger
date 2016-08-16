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

//MARK: StackedBubble class
/**
 Bubble when stacked for succeeding messages. The two outmost corners are rounded.
 */
class StackedBubble: Bubble {
    
    //MARK: Public Variables
    
    /** Radius of the corners for the bubble. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    var radius : CGFloat = 16
    /** Should be less or equal to the *radius* property. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    var borderWidth : CGFloat = 0
    /** The color of the border around the bubble. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    var bubbleBorderColor : UIColor = UIColor.clearColor()
    /** Path used to cutout the bubble*/
    private(set) var path: CGMutablePath = CGPathCreateMutable()

    override init() {
        super.init()
    }
    
    // MARK: Class methods
    
    /**
     Overriding sizeToBounds from super class
     -parameter bounds: The bounds of the content
     */
    override func sizeToBounds(bounds: CGRect) {
        super.sizeToBounds(bounds)
        var rect = CGRectZero
        var radius2: CGFloat = 0
        
        if bounds.width < 2*radius || bounds.height < 2*radius { //if the rect calculation yeilds a negative result
            let newRadiusW = bounds.width/2
            let newRadiusH = bounds.height/2
            
            let newRadius = newRadiusW>newRadiusH ? newRadiusH : newRadiusW
            
            rect = CGRectMake(newRadius, newRadius, bounds.width - 2*newRadius, bounds.height - 2*newRadius)
            radius2 = newRadius - borderWidth / 2
        } else {
            rect = CGRectMake(radius, radius, bounds.width - 2*radius, bounds.height - 2*radius)
            radius2 = radius - borderWidth / 2
        }
        
        
        self.path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, nil, rect.minX, rect.minY - radius2)
        CGPathAddLineToPoint(path, nil, rect.maxX + radius2, rect.minY - radius2)
        CGPathAddLineToPoint(path, nil, rect.maxX + radius2, rect.maxY + radius2)
        CGPathAddArc(path, nil, rect.minX, rect.maxY, radius2, CGFloat(M_PI_2), CGFloat(M_PI), false)
        CGPathAddArc(path, nil, rect.minX, rect.minY, radius2, CGFloat(M_PI), CGFloat(-M_PI_2), false)
        CGPathCloseSubpath(path)
        
    }
    
    /**
     Overriding createLayer from super class
     */
    override func createLayer() {
        super.createLayer()
      
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.layer.path = path
        self.layer.fillColor = self.bubbleColor.CGColor
        self.layer.strokeColor = self.bubbleBorderColor.CGColor
        self.layer.lineWidth = self.borderWidth
        self.layer.position = CGPoint.zero
        
        self.maskLayer.fillColor = UIColor.blackColor().CGColor
        self.maskLayer.path = path
        self.maskLayer.position = CGPoint.zero
        CATransaction.commit()
    }
}