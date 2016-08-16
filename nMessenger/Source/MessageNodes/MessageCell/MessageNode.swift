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

//MARK: MessageNode
/**
 Base message class for N Messanger. Extends GeneralMessengerCell. Holds one message
 */
public class MessageNode: GeneralMessengerCell {
    
    // MARK: Public Variables
    public var delegate: MessageCellProtocol?
    
    /** ASDisplayNode as the content of the cell*/
    public var contentNode: ContentNode?
        {
        willSet{
            if let contentNode = newValue {
                if let oldContent = self.contentNode {
                    self.insertSubnode(contentNode, aboveSubnode: oldContent)
                    oldContent.removeFromSupernode()
                } else {
                    addSubnode(contentNode)
                }
            }
        }
        
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /** ASDisplayNode as the avatar of the cell*/
    public var avatarNode: ASDisplayNode?
        {
        willSet{
            if let avatarNode = newValue {
                if let oldAvatar = self.avatarNode {
                    self.insertSubnode(avatarNode, aboveSubnode: oldAvatar)
                    oldAvatar.removeFromSupernode()
                } else {
                    self.addSubnode(avatarNode)
                }
            }
        }
        didSet {
            self.setNeedsLayout()
        }

    }
    
    /** ASDisplayNode as the header of the cell*/
    public var headerNode: ASDisplayNode?
        {
        willSet{
            if let headerNode = newValue {
                if let oldHeader = self.headerNode {
                    self.insertSubnode(headerNode, aboveSubnode: oldHeader)
                    oldHeader.removeFromSupernode()
                } else {
                    self.addSubnode(headerNode)
                }
            }
        }
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /** ASDisplayNode as the footer of the cell*/
    public var footerNode: ASDisplayNode? {
            willSet{
                if let footerNode = newValue {
                    if let oldFooter = self.footerNode {
                        self.insertSubnode(footerNode, aboveSubnode: oldFooter)
                        oldFooter.removeFromSupernode()
                    } else {
                        self.addSubnode(footerNode)
                    }
                }
            }
            didSet {
                self.setNeedsLayout()
            }
    }
    
    /**
     Spacing around the avatar. Defaults to UIEdgeInsetsMake(0, 0, 0, 10)
     */
    public var avatarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /** Message offset from edge (edge->offset->message content). Defaults to 10*/
    public var messageOffset: CGFloat = 10 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /** Spacing under the header. Defaults to 10*/
    public var headerSpacing: CGFloat = 10 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /** Spacing above the footer. Defaults to 10*/
    public var footerSpacing: CGFloat = 10 {
        didSet {
            self.setNeedsLayout()
        }
    }

    /** Bool if the cell is an incoming or out going message cell*/
    public override var isIncomingMessage:Bool {
        didSet {
            self.contentNode?.isIncomingMessage = isIncomingMessage
        }
    }
    
    // MARK: Private Variables
    /** Button node to handle avatar click*/
    private var avatarButtonNode: ASControlNode = ASControlNode()
    
    // MARK: Initializers
    
    /**
     Initialiser for the cell
     */
    public init(content: ContentNode) {
        super.init()
        self.setupMessageNode(withContent: content)
    }
    
    
    // MARK: Initializer helper method
    
    /**
    Creates background node and avatar node if they do not exist
     */
    private func setupMessageNode(withContent content: ContentNode)
    {
        
        self.avatarButtonNode.addTarget(self, action:  #selector(MessageNode.avatarClicked), forControlEvents: .TouchUpInside)
        self.avatarButtonNode.exclusiveTouch = true
        
        self.contentNode = content
        
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override public func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var layoutSpecs: ASLayoutSpec!
        let spacer = ASLayoutSpec()
        
        //location dependent on sender
        let justifyLocation = isIncomingMessage ? ASStackLayoutJustifyContent.Start : ASStackLayoutJustifyContent.End
        
        if let tmpAvatar = self.avatarNode {
            let tmpSizeMesuare = tmpAvatar.measure(constrainedSize.max)
            let avatarSizeLayout = ASStaticLayoutSpec(children: [tmpAvatar])
            self.avatarButtonNode.preferredFrameSize = tmpSizeMesuare
            let avatarButtonSizeLayout = ASStaticLayoutSpec(children: [self.avatarButtonNode])
            let avatarBackStack = ASBackgroundLayoutSpec(child: avatarButtonSizeLayout, background: avatarSizeLayout)
            let width = constrainedSize.max.width - tmpSizeMesuare.width - self.cellPadding.left - self.cellPadding.right - avatarInsets.left - avatarInsets.right - self.messageOffset
            let tmpSizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeZero), ASRelativeSizeMake(ASRelativeDimensionMakeWithPoints(width),ASRelativeDimensionMakeWithPercent(1)))
            self.contentNode!.sizeRange = tmpSizeRange
            let contentSizeLayout = ASStaticLayoutSpec(children: [self.contentNode!])
            
            let ins = ASInsetLayoutSpec(insets: self.avatarInsets, child: avatarBackStack)
            
            let cellOrientation = isIncomingMessage ? [ins, contentSizeLayout] : [contentSizeLayout,ins]
            
            layoutSpecs = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: justifyLocation, alignItems: .End, children: cellOrientation)
            contentSizeLayout.flexShrink = true
        } else {
            let width = constrainedSize.max.width - self.cellPadding.left - self.cellPadding.right - self.messageOffset
            let tmpSizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeZero), ASRelativeSizeMake(ASRelativeDimensionMakeWithPoints(width),ASRelativeDimensionMakeWithPercent(1)))
            self.contentNode!.sizeRange = tmpSizeRange
            let contentSizeLayout = ASStaticLayoutSpec(children: [self.contentNode!])
            
            layoutSpecs = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: justifyLocation, alignItems: .End, children: [spacer, contentSizeLayout])
            contentSizeLayout.flexShrink = true
        }
        
        if let headerNode = self.headerNode
        {
            layoutSpecs = ASStackLayoutSpec(direction: .Vertical, spacing: self.headerSpacing, justifyContent: .Start, alignItems: isIncomingMessage ? .Start : .End, children: [headerNode, layoutSpecs])
        }
        
        if let footerNode = self.footerNode {
            layoutSpecs = ASStackLayoutSpec(direction: .Vertical, spacing: self.footerSpacing, justifyContent: .Start, alignItems: isIncomingMessage ? .Start : .End, children: [layoutSpecs, footerNode])
        }
        
        let cellOrientation = self.isIncomingMessage ? [spacer, layoutSpecs!] : [layoutSpecs!, spacer]
        layoutSpecs = ASStackLayoutSpec(direction: .Horizontal, spacing: self.messageOffset, justifyContent: justifyLocation, alignItems: .End, children: cellOrientation)
        layoutSpecs = ASInsetLayoutSpec(insets: self.cellPadding, child: layoutSpecs)
        return layoutSpecs
    }
    
    
    // MARK: UILongPressGestureRecognizer Override Methods
    
    /**
     Overriding didLoad to add UILongPressGestureRecognizer to view
     */
    override public func didLoad() {
        super.didLoad()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(messageNodeLongPressSelector(_:)))
        view.addGestureRecognizer(longPressRecognizer)
    }
    
    /**
     Overriding canBecomeFirstResponder to make cell first responder
     */
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    /**
     Overriding touchesBegan to make to close UIMenuController
     */
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if UIMenuController.sharedMenuController().menuVisible == true {
            UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
        }
    }
    
    /**
     Overriding touchesEnded to make to handle events with UIMenuController
     */
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if UIMenuController.sharedMenuController().menuVisible == false {
            
        }
    }
    /**
     Overriding touchesCancelled to make to handle events with UIMenuController
     */
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
        if UIMenuController.sharedMenuController().menuVisible == false {
            
        }
    }
    
    
    // MARK: UILongPressGestureRecognizer Selector Methods
    
    /**
     UILongPressGestureRecognizer selector
     - parameter recognizer: Must be an UITapGestureRecognizer.
     Can be be overritten when subclassed
     */
    public func messageNodeLongPressSelector(recognizer: UITapGestureRecognizer) {
        contentNode?.messageNodeLongPressSelector(recognizer)
    }
}

/** Delegate functions extension */
extension MessageNode {
    /**
     Notifies the delegate that the avatar was clicked
     */
    public func avatarClicked()
    {
        self.delegate?.avatarClicked?(self)
    }
}