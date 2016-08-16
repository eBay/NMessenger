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

/** Configures a bubble for a ContentNode. Implement this to create your own bubble configuration */
public protocol BubbleConfigurationProtocol {
    var isMasked: Bool {get set}
    
    /** Create and return a UI color representing an incoming message */
    func getIncomingColor() -> UIColor
    
    /** Create and return a UI color representing an outgoing message */
    func getOutgoingColor() -> UIColor
    
    /** Create and return a bubble for the ContentNode */
    func getBubble() -> Bubble
    
    /** Create and return a bubble that is used by the Message group for Message nodes after the first. This is typically used to "stack" messages */
    func getSecondaryBubble() -> Bubble
}
