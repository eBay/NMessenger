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

//MARK: SimpleBubble class
/**
 Simple bubble with no layer effects which is the bounds of the content it holds
 */
open class SimpleBubble: Bubble {
    
    //MARK: Public Variables
    /** The color of the border around the bubble. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    open var bubbleBorderColor : UIColor = UIColor.clear
    /** Path used to cutout the bubble*/
    open fileprivate(set) var path: CGMutablePath = CGMutablePath()
    
    public override init() {
        super.init()
    }
    
    // MARK: Class methods
    
    /**
     Overriding sizeToBounds from super class
     -parameter bounds: The bounds of the content
     */
    open override func sizeToBounds(_ bounds: CGRect) {
        super.sizeToBounds(bounds)
        
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    
        path = CGMutablePath()
    
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
       // CGPathMoveToPoint(path, nil, rect.minX, rect.minY)
       // CGPathAddLineToPoint(path, nil, rect.maxX, rect.minY)
       // CGPathAddLineToPoint(path, nil, rect.maxX, rect.maxY)
       // CGPathAddLineToPoint(path, nil, rect.minX, rect.maxY)
        
        path.closeSubpath()
    }
    
    /**
     Overriding createLayer from super class
     */
    open override func createLayer() {
        super.createLayer()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.layer.path = path
        self.layer.fillColor = self.bubbleColor.cgColor
        self.layer.strokeColor = self.bubbleBorderColor.cgColor
        self.layer.position = CGPoint.zero
        
        self.maskLayer.fillColor = UIColor.black.cgColor
        self.maskLayer.path = path
        self.maskLayer.position = CGPoint.zero
        CATransaction.commit()
        
    }
}
