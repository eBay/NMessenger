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

//MARK: ImageBubble class
/**
Image as background for messages in NMessenger
Uses 9-Patch logic to resize image to appropriate size.
 */
class ImageBubble : Bubble {
    
    // MARK: Public variables
    /** Image 9-Patch used for bubble. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    var bubbleImage: UIImage?
    /** Image 9-Patch cut insets. When this is set, you will need to call setNeedsLayout on your message for changes to take effect if the bubble has already been drawn*/
    var cutInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    
    // MARK: Initialisers
    
    /**
     Initialiser class.
     Sets hasLayerMask to true
     */
    override init() {
        super.init()
        self.hasLayerMask = true
    }
    
    // MARK: Class methods
    
    /**
     Overriding sizeToBounds from super class
     -parameter bounds: The bounds of the content
     */
    override func sizeToBounds(bounds: CGRect) {
        super.sizeToBounds(bounds)
        
    }
    
    /**
     Overriding createLayer from super class
     */
    override func createLayer() {
        super.createLayer()
        
        if let image = bubbleImage {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
            let context = UIGraphicsGetCurrentContext();
            self.bubbleColor.setFill()
            CGContextTranslateCTM(context, 0, image.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
            CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
            
            var coloredImg = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            
            let insets = self.cutInsets
            coloredImg = coloredImg.resizableImageWithCapInsets(insets, resizingMode: .Stretch)
            
            self.layer.contents = coloredImg.CGImage
            self.layer.position = CGPointZero
            self.layer.frame = CGRect(x: 0, y: 0, width: self.calculatedBounds.width, height: self.calculatedBounds.height)
            self.layer.contentsCenter = CGRectMake(insets.left/coloredImg.size.width,
                                                   insets.top/coloredImg.size.height,
                                                   1.0/coloredImg.size.width,
                                                   1.0/coloredImg.size.height);
            
            self.maskLayer.contents = coloredImg.CGImage
            self.maskLayer.position = CGPointZero
            self.maskLayer.frame = CGRect(x: 0, y: 0, width: self.calculatedBounds.width, height: self.calculatedBounds.height)
            self.maskLayer.contentsCenter = CGRectMake(insets.left/coloredImg.size.width,
                                                   insets.top/coloredImg.size.height,
                                                   1.0/coloredImg.size.width,
                                                   1.0/coloredImg.size.height);
        }
    }
    
    
}