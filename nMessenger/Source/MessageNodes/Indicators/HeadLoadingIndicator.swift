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
class HeadLoadingIndicator: GeneralMessengerCell {
    /** Horizontal spacing between text and spinner. Defaults to 20.*/
    var contentPadding:CGFloat = 20 {
        didSet {
            self.setNeedsLayout()
        }
    }
    /** Animated spinner node*/
    let spinner = SpinnerNode()
    /** Loading text node*/
    let text = ASTextNode()
    /** Sets the loading attributed text for the spinner. Defaults to *"Loading..."* */
    var loadingAttributedText:NSAttributedString? {
        set {
            text.attributedString = newValue
            self.setNeedsLayout()
        } get {
            return text.attributedText
        }
    }
    
    override init() {
        super.init()
        addSubnode(text)
        text.attributedString = NSAttributedString(
            string: "Loading…",
            attributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(12),
                NSForegroundColorAttributeName: UIColor.lightGrayColor(),
                NSKernAttributeName: -0.3
            ])
        addSubnode(spinner)
    }

    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackLayout = ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: contentPadding,
            justifyContent: .Center,
            alignItems: .Center,
            children: [ text, spinner ])
        let paddingLayout = ASInsetLayoutSpec(insets: cellPadding, child: stackLayout)
        return paddingLayout
    }
}

//MARK: SpinnerNode class
/**
 Animated spinner. Used by HeadLoadingIndicator. Defaults to *preferredFrameSize.height=32*
 */
class SpinnerNode: ASDisplayNode {
    var activityIndicatorView: UIActivityIndicatorView {
        return view as! UIActivityIndicatorView
    }

    override init() {
        super.init(viewBlock: { UIActivityIndicatorView(activityIndicatorStyle: .Gray) }, didLoadBlock: nil)
        preferredFrameSize.height = 32
    }
    
    override func didLoad() {
        super.didLoad()
        activityIndicatorView.startAnimating()
    }
}