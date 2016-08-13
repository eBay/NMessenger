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

//MARK: TypingIndicatorContent
/**
 TypingIndicatorContent class for NMessenger. Extends MessageNode.
 Defines content that is a loading indicator.
 */
class TypingIndicatorContent: ContentNode {
    
    // MARK: Private Variables
    /** gifNode holds the animated typing indicator*/
    private(set) var gifNode = ASDisplayNode()
    
    override func didLoad() {
        super.didLoad()
        
        let imageNames = ["loadBubble_0038_Layer-1", "loadBubble_0037_Layer-2", "loadBubble_0036_Layer-3", "loadBubble_0035_Layer-4", "loadBubble_0034_Layer-5", "loadBubble_0033_Layer-6", "loadBubble_0032_Layer-7", "loadBubble_0031_Layer-8", "loadBubble_0030_Layer-9", "loadBubble_0029_Layer-10", "loadBubble_0028_Layer-11", "loadBubble_0027_Layer-12", "loadBubble_0026_Layer-13", "loadBubble_0025_Layer-14", "loadBubble_0024_Layer-15", "loadBubble_0023_Layer-16", "loadBubble_0022_Layer-17", "loadBubble_0021_Layer-18", "loadBubble_0020_Layer-19", "loadBubble_0019_Layer-20", "loadBubble_0018_Layer-21", "loadBubble_0017_Layer-22", "loadBubble_0016_Layer-23", "loadBubble_0015_Layer-24", "loadBubble_0014_Layer-25", "loadBubble_0013_Layer-26", "loadBubble_0012_Layer-27", "loadBubble_0011_Layer-28", "loadBubble_0010_Layer-29", "loadBubble_0009_Layer-30", "loadBubble_0008_Layer-31", "loadBubble_0007_Layer-32", "loadBubble_0006_Layer-33", "loadBubble_0005_Layer-34", "loadBubble_0004_Layer-35", "loadBubble_0003_Layer-36", "loadBubble_0002_Layer-37", "loadBubble_0001_Layer-38", "loadBubble_0000_Layer-39"]
        var images = [UIImage]()
        
        for imageName in imageNames {
            if let image = UIImage(named: imageName) {
                images.append(image)
            }
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: images[0].size.width - 1, height: images[0].size.height - 1))
        imageView.backgroundColor = UIColor.orangeColor()
        imageView.contentMode = UIViewContentMode.Center
        imageView.clipsToBounds = true
        imageView.animationImages = images
        imageView.animationDuration = 1
        imageView.startAnimating()
        
        self.gifNode.view.addSubview(imageView)
        self.gifNode.preferredFrameSize = imageView.frame.size

        self.addSubnode(gifNode)
        
        self.setNeedsLayout()
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [self.gifNode])
    }
    
}

