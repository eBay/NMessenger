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

//MARK: TextMessageNode
/**
 TextMessageNode class for N Messanger. Extends MessageNode.
 Defines content that is a text.
 */
public class TextContentNode: ContentNode,ASTextNodeDelegate {

    // MARK: Public Variables
    /** Insets for the node */
    public var insets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10) {
        didSet {
            setNeedsLayout()
        }
    }
    /** UIFont for incoming text messages*/
    public var incomingTextFont = UIFont.n1B1Font() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** UIFont for outgoinf text messages*/
    public var outgoingTextFont = UIFont.n1B1Font() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** UIColor for incoming text messages*/
    public var incomingTextColor = UIColor.n1DarkestGreyColor() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** UIColor for outgoinf text messages*/
    public var outgoingTextColor = UIColor.n1WhiteColor() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** String to present as the content of the cell*/
    public var textMessegeString: NSAttributedString? {
        get {
            return self.textMessegeNode.attributedString
        } set {
            self.textMessegeNode.attributedString = newValue
        }
    }
    /** Overriding from super class
     Set backgroundBubble.bubbleColor and the text color when valus is set
     */
    public override var isIncomingMessage: Bool
        {
        didSet {
            if isIncomingMessage
            {
                self.backgroundBubble?.bubbleColor = self.bubbleConfiguration.getIncomingColor()
                self.updateAttributedText()
            } else {
                self.backgroundBubble?.bubbleColor = self.bubbleConfiguration.getOutgoingColor()
                self.updateAttributedText()
            }
        }
    }
    
    // MARK: Private Variables
    /** ASTextNode as the content of the cell*/
    private(set) var textMessegeNode:ASTextNode = ASTextNode()
    /** Bool as mutex for handling attributed link long presses*/
    private var lockKey: Bool = false
    
    
    // MARK: Initialisers
    
    /**
     Initialiser for the cell.
     - parameter textMessegeString: Must be String. Sets text for cell.
     Calls helper methond to setup cell
     */
    public init(textMessegeString: String, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupTextNode(textMessegeString)
    }
    /**
     Initialiser for the cell.
     - parameter textMessegeString: Must be String. Sets text for cell.
     - parameter currentViewController: Must be an UIViewController. Set current view controller holding the cell.
     Calls helper methond to setup cell
     */
    public init(textMessegeString: String, currentViewController: UIViewController, bubbleConfiguration: BubbleConfigurationProtocol? = nil)
    {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.currentViewController = currentViewController
        self.setupTextNode(textMessegeString)
    }
    
    // MARK: Initialiser helper method
    
    /**
     Creates the text to be display in the cell. Finds links and phone number in the string and creates atrributed string.
      - parameter textMessegeString: Must be String. Sets text for cell.
     */
    private func setupTextNode(textMessegeString: String)
    {
        self.backgroundBubble = self.bubbleConfiguration.getBubble()
        textMessegeNode.delegate = self
        textMessegeNode.userInteractionEnabled = true
        textMessegeNode.linkAttributeNames = ["LinkAttribute","PhoneNumberAttribute"]
        let fontAndSizeAndTextColor = [ NSFontAttributeName: self.isIncomingMessage ? incomingTextFont : outgoingTextFont, NSForegroundColorAttributeName: self.isIncomingMessage ? incomingTextColor : outgoingTextColor]
        let outputString = NSMutableAttributedString(string: textMessegeString, attributes: fontAndSizeAndTextColor )
        let types: NSTextCheckingType = [.Link, .PhoneNumber]
        let detector = try! NSDataDetector(types: types.rawValue)
        let matches = detector.matchesInString(textMessegeString, options: [], range: NSMakeRange(0, textMessegeString.characters.count))
        for match in matches {
            if let url = match.URL
            {
                outputString.addAttribute("LinkAttribute", value: url, range: match.range)
                outputString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: match.range)
                outputString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: match.range)
            }
            if let phoneNumber = match.phoneNumber
            {
                outputString.addAttribute("PhoneNumberAttribute", value: phoneNumber, range: match.range)
                outputString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: match.range)
                outputString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: match.range)
            }
        }
        self.textMessegeNode.attributedString = outputString
        self.textMessegeNode.accessibilityIdentifier = "labelMessage"
        self.textMessegeNode.isAccessibilityElement = true
        self.addSubnode(textMessegeNode)
    }
    
    //MARK: Helper Methods
    /** Updates the attributed string to the correct incoming/outgoing settings and lays out the component again*/
    private func updateAttributedText() {
        let tmpString = NSMutableAttributedString(attributedString: self.textMessegeNode.attributedString!)
        tmpString.addAttributes([NSForegroundColorAttributeName: isIncomingMessage ? incomingTextColor : outgoingTextColor, NSFontAttributeName: isIncomingMessage ? incomingTextFont : outgoingTextFont], range: NSMakeRange(0, tmpString.length))
        self.textMessegeNode.attributedString = tmpString
        
        setNeedsLayout()
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override public func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width = constrainedSize.max.width * 0.90 - self.insets.left - self.insets.right
        
        let tmp = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSizeZero), ASRelativeSizeMake(ASRelativeDimensionMakeWithPoints(width),ASRelativeDimensionMakeWithPercent(1)))
        
        textMessegeNode.sizeRange = tmp
        
        let textMessegeSize = ASStaticLayoutSpec(children: [self.textMessegeNode])
        
        return  ASInsetLayoutSpec(insets: insets, child: textMessegeSize)
        
    }
    
    // MARK: ASTextNodeDelegate
    
    /**
     Implementing shouldHighlightLinkAttribute - returning true for both link and phone numbers
     */
    public func textNode(textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: AnyObject, atPoint point: CGPoint) -> Bool {
        if attribute == "LinkAttribute"
        {
            return true
        }
        else if attribute == "PhoneNumberAttribute"
        {
            return true
        }
        return false
    }
    
    /**
     Implementing tappedLinkAttribute - handle tap event on links and phone numbers
     */
    public func textNode(textNode: ASTextNode, tappedLinkAttribute attribute: String, value: AnyObject, atPoint point: CGPoint, textRange: NSRange) {
        if attribute == "LinkAttribute"
        {
            if !self.lockKey
            {
                if let tmpString = self.textMessegeNode.attributedString
                {
                    let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                    attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGrayColor(), range: textRange)
                    self.textMessegeNode.attributedString = attributedString
                    UIApplication.sharedApplication().openURL(value as! NSURL)
                    delay(0.4) {
                        if let tmpString = self.textMessegeNode.attributedString
                        {
                            let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                            attributedString.removeAttribute(NSBackgroundColorAttributeName, range: textRange)
                            self.textMessegeNode.attributedString = attributedString
                        }
                    }
                }
            }
        }
        else if attribute == "PhoneNumberAttribute"
        {
            let phoneNumber = value as! String
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
        }
    }
    
    /**
     Implementing shouldLongPressLinkAttribute - returning true for both link and phone numbers
     */
    public func textNode(textNode: ASTextNode, shouldLongPressLinkAttribute attribute: String, value: AnyObject, atPoint point: CGPoint) -> Bool {
        if attribute == "LinkAttribute"
        {
            return true
        }
        else if attribute == "PhoneNumberAttribute"
        {
            return true
        }
        return false
    }
    
    /**
     Implementing longPressedLinkAttribute - handles long tap event on links and phone numbers
     */
    public func textNode(textNode: ASTextNode, longPressedLinkAttribute attribute: String, value: AnyObject, atPoint point: CGPoint, textRange: NSRange) {
        if attribute == "LinkAttribute"
        {
            self.lockKey = true
            if let tmpString = self.textMessegeNode.attributedString
            {
                let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGrayColor(), range: textRange)
                self.textMessegeNode.attributedString = attributedString

                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                
                let openAction = UIAlertAction(title: "Open", style: .Default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                let addToReadingListAction = UIAlertAction(title: "Add to Reading List", style: .Default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let copyAction = UIAlertAction(title: "Copy", style: .Default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                optionMenu.addAction(openAction)
                optionMenu.addAction(addToReadingListAction)
                optionMenu.addAction(copyAction)
                optionMenu.addAction(cancelAction)
                
                if let tmpCurrentViewController = self.currentViewController
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        tmpCurrentViewController.presentViewController(optionMenu, animated: true, completion: nil)
                    })
                    
                }
                
            }
            delay(0.4) {
                if let tmpString = self.textMessegeNode.attributedString
                {
                    let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                    attributedString.removeAttribute(NSBackgroundColorAttributeName, range: textRange)
                    self.textMessegeNode.attributedString = attributedString
                }
            }
        }
        else if attribute == "PhoneNumberAttribute"
        {
            let phoneNumber = value as! String
            self.lockKey = true
            if let tmpString = self.textMessegeNode.attributedString
            {
                let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGrayColor(), range: textRange)
                self.textMessegeNode.attributedString = attributedString
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                
                let callPhoneNumberAction = UIAlertAction(title: "Call \(phoneNumber)", style: .Default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                let facetimeAudioAction = UIAlertAction(title: "Facetime Audio", style: .Default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let sendMessageAction = UIAlertAction(title: "Send Message", style: .Default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let addToContactsAction = UIAlertAction(title: "Add to Contacts", style: .Default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let copyAction = UIAlertAction(title: "Copy", style: .Default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                    (alert: UIAlertAction) -> Void in
                    //print("Cancelled")
                    self.lockKey = false
                })
                
                optionMenu.addAction(callPhoneNumberAction)
                optionMenu.addAction(facetimeAudioAction)
                optionMenu.addAction(sendMessageAction)
                optionMenu.addAction(addToContactsAction)
                optionMenu.addAction(copyAction)
                optionMenu.addAction(cancelAction)
                
                if let tmpCurrentViewController = self.currentViewController
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        tmpCurrentViewController.presentViewController(optionMenu, animated: true, completion: nil)
                    })
                    
                }
                
            }
            delay(0.4) {
                if let tmpString = self.textMessegeNode.attributedString
                {
                    let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                    attributedString.removeAttribute(NSBackgroundColorAttributeName, range: textRange)
                    self.textMessegeNode.attributedString = attributedString
                }
            }
        }
    }
    
    // MARK: UILongPressGestureRecognizer Selector Methods
    
    
    /**
     Overriding canBecomeFirstResponder to make cell first responder
     */
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    /**
     Overriding resignFirstResponder to resign responder
     */
    override public func resignFirstResponder() -> Bool {
        return view.resignFirstResponder()
    }
    
    /**
     Override method from superclass
     */
    public override func messageNodeLongPressSelector(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            let touchLocation = recognizer.locationInView(view)
            if CGRectContainsPoint(self.textMessegeNode.frame, touchLocation) {
                becomeFirstResponder()
                delay(0.1, closure: {
                    let menuController = UIMenuController.sharedMenuController()
                    menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(TextContentNode.copySelector))]
                    menuController.setTargetRect(self.textMessegeNode.frame, inView: self.view)
                    menuController.setMenuVisible(true, animated:true)
                })
            }
        }
    }
    
    /**
     Copy Selector for UIMenuController
     */
    public func copySelector() {
        UIPasteboard.generalPasteboard().string = self.textMessegeNode.attributedString!.string
    }
    
}
