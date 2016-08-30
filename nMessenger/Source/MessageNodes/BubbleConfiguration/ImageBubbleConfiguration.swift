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

/** Uses a simple bubble as primary and a simple bubble as secondary. Incoming color is pale grey and outgoing is mid grey */
public class ImageBubbleConfiguration: BubbleConfigurationProtocol {
    
    public var isMasked = false
    
    public init() {}
    
    public func getIncomingColor() -> UIColor
    {
        return UIColor.n1PaleGreyColor()
    }
    
    public func getOutgoingColor() -> UIColor
    {
        return UIColor.n1ActionBlueColor()
    }
    
    public func getBubble() -> Bubble
    {
        let newBubble = ImageBubble()
        newBubble.bubbleImage = UIImage(named: "MessageBubble", inBundle: NSBundle(forClass: NMessengerViewController.self), compatibleWithTraitCollection: nil)
        newBubble.cutInsets = UIEdgeInsetsMake(29, 32, 25, 43)
        newBubble.hasLayerMask = isMasked
        return newBubble
    }
    
    public func getSecondaryBubble() -> Bubble
    {
        let newBubble = ImageBubble()
        newBubble.bubbleImage = UIImage(named: "MessageBubble", inBundle: NSBundle(forClass: NMessengerViewController.self), compatibleWithTraitCollection: nil)
        newBubble.cutInsets = UIEdgeInsetsMake(29, 32, 25, 43)
        newBubble.hasLayerMask = isMasked
        return newBubble
    }
}