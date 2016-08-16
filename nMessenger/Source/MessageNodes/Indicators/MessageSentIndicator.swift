//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import AsyncDisplayKit
import UIKit

//MARK: HeadLoadingIndicator class
/**
 Spinning loading indicator class. Used by the NMessenger prefetch.
 */
public class MessageSentIndicator: GeneralMessengerCell {
    /** Horizontal spacing between text and spinner. Defaults to 20.*/
    public var contentPadding:CGFloat = 20 {
        didSet {
            self.setNeedsLayout()
        }
    }
    /** Loading text node*/
    public let text = ASTextNode()
    /** Sets the loading attributed text for the spinner. Defaults to *"Loading..."* */
    public var messageSentAttributedText:NSAttributedString? {
        set {
            text.attributedString = newValue
            self.setNeedsLayout()
        } get {
            return text.attributedText
        }
    }
    public var messageSentText: String? {
        set {
            text.attributedString = NSAttributedString(
                string: newValue != nil ? newValue! : "",
                attributes: [
                    NSFontAttributeName: UIFont.systemFontOfSize(14),
                    NSForegroundColorAttributeName: UIColor.lightGrayColor(),
                    NSKernAttributeName: -0.3
                ])
            self.setNeedsLayout()
        } get {
            return text.attributedString?.string
        }
    }
    
    public override init() {
        super.init()
        addSubnode(text)
    }
    
    override public func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackLayout = ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: contentPadding,
            justifyContent: .Center,
            alignItems: .Center,
            children: [ text ])
        let paddingLayout = ASInsetLayoutSpec(insets: cellPadding, child: stackLayout)
        return paddingLayout
    }
}