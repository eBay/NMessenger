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
 TextMessageNode class for N Messenger. Extends MessageNode.
 Defines content that is a text.
 */
open class TextContentNode: ContentNode,ASTextNodeDelegate {

    // MARK: Public Variables
    /** Insets for the node */
    open var insets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10) {
        didSet {
            setNeedsLayout()
        }
    }
    /** UIFont for incoming text messages*/
    open var incomingTextFont = UIFont.n1B1Font() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** UIFont for outgoinf text messages*/
    open var outgoingTextFont = UIFont.n1B1Font() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** UIColor for incoming text messages*/
    open var incomingTextColor = UIColor.n1DarkestGreyColor() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** UIColor for outgoinf text messages*/
    open var outgoingTextColor = UIColor.n1WhiteColor() {
        didSet {
            self.updateAttributedText()
        }
    }
    /** String to present as the content of the cell*/
    open var textMessageString: NSAttributedString? {
        get {
            return self.textMessageNode.attributedText
        } set {
            self.textMessageNode.attributedText = newValue
        }
    }
    /** Overriding from super class
     Set backgroundBubble.bubbleColor and the text color when valus is set
     */
    open override var isIncomingMessage: Bool
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
    open fileprivate(set) var textMessageNode:ASTextNode = ASTextNode()
    /** Bool as mutex for handling attributed link long presses*/
    fileprivate var lockKey: Bool = false
    
    
    // MARK: Initialisers
    
    /**
     Initialiser for the cell.
     - parameter textMessageString: Must be String. Sets text for cell.
     Calls helper method to setup cell
     */
    public init(textMessageString: String, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupTextNode(textMessageString)
    }
    /**
     Initialiser for the cell.
     - parameter textMessageString: Must be String. Sets text for cell.
     - parameter currentViewController: Must be an UIViewController. Set current view controller holding the cell.
     Calls helper method to setup cell
     */
    public init(textMessageString: String, currentViewController: UIViewController, bubbleConfiguration: BubbleConfigurationProtocol? = nil)
    {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.currentViewController = currentViewController
        self.setupTextNode(textMessageString)
    }
    
    // MARK: Initialiser helper method
    
    /**
     Creates the text to be display in the cell. Finds links and phone number in the string and creates atrributed string.
      - parameter textMessageString: Must be String. Sets text for cell.
     */
    fileprivate func setupTextNode(_ textMessageString: String)
    {
        self.backgroundBubble = self.bubbleConfiguration.getBubble()
        textMessageNode.delegate = self
        textMessageNode.isUserInteractionEnabled = true
        textMessageNode.linkAttributeNames = ["LinkAttribute","PhoneNumberAttribute"]
        let fontAndSizeAndTextColor = [ NSFontAttributeName: self.isIncomingMessage ? incomingTextFont : outgoingTextFont, NSForegroundColorAttributeName: self.isIncomingMessage ? incomingTextColor : outgoingTextColor]
        let outputString = NSMutableAttributedString(string: textMessageString, attributes: fontAndSizeAndTextColor )
        let types: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        let detector = try! NSDataDetector(types: types.rawValue)
        let matches = detector.matches(in: textMessageString, options: [], range: NSMakeRange(0, textMessageString.characters.count))
        for match in matches {
            if let url = match.url
            {
                outputString.addAttribute("LinkAttribute", value: url, range: match.range)
                outputString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: match.range)
                outputString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: match.range)
            }
            if let phoneNumber = match.phoneNumber
            {
                outputString.addAttribute("PhoneNumberAttribute", value: phoneNumber, range: match.range)
                outputString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: match.range)
                outputString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: match.range)
            }
        }
        self.textMessageNode.attributedText = outputString
        self.textMessageNode.accessibilityIdentifier = "labelMessage"
        self.textMessageNode.isAccessibilityElement = true
        self.addSubnode(textMessageNode)
    }
    
    //MARK: Helper Methods
    /** Updates the attributed string to the correct incoming/outgoing settings and lays out the component again*/
    fileprivate func updateAttributedText() {
        let tmpString = NSMutableAttributedString(attributedString: self.textMessageNode.attributedText!)
        tmpString.addAttributes([NSForegroundColorAttributeName: isIncomingMessage ? incomingTextColor : outgoingTextColor, NSFontAttributeName: isIncomingMessage ? incomingTextFont : outgoingTextFont], range: NSMakeRange(0, tmpString.length))
        self.textMessageNode.attributedText = tmpString
        
        setNeedsLayout()
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width = constrainedSize.max.width * 0.90 - self.insets.left - self.insets.right
        
        textMessageNode.style.maxWidth = ASDimension(unit: .points, value: width)
        textMessageNode.style.maxHeight = ASDimension(unit: .fraction, value: 1)
        
        let textMessageSize = ASStaticLayoutSpec()
        textMessageSize.children = [self.textMessageNode]
        
        return  ASInsetLayoutSpec(insets: insets, child: textMessageSize)
        
    }
    
    // MARK: ASTextNodeDelegate
    
    /**
     Implementing shouldHighlightLinkAttribute - returning true for both link and phone numbers
     */
    
    public func textNode(_ textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
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
    
    /*open func textNode(_ textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: AnyObject, at point: CGPoint) -> Bool {
        if attribute == "LinkAttribute"
        {
            return true
        }
        else if attribute == "PhoneNumberAttribute"
        {
            return true
        }
        return false
    }*/
    
    /**
     Implementing tappedLinkAttribute - handle tap event on links and phone numbers
     */

    //open func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: AnyObject, at point: CGPoint, textRange: NSRange) {
    public func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        if attribute == "LinkAttribute"
        {
            if !self.lockKey
            {
                if let tmpString = self.textMessageNode.attributedText
                {
                    let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                    attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGray, range: textRange)
                    self.textMessageNode.attributedText = attributedString
                    UIApplication.shared.openURL(value as! URL)
                    delay(0.4) {
                        if let tmpString = self.textMessageNode.attributedText
                        {
                            let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                            attributedString.removeAttribute(NSBackgroundColorAttributeName, range: textRange)
                            self.textMessageNode.attributedText = attributedString
                        }
                    }
                }
            }
        }
        else if attribute == "PhoneNumberAttribute"
        {
            let phoneNumber = value as! String
            UIApplication.shared.openURL(URL(string: "tel://\(phoneNumber)")!)
        }
    }
    
    /**
     Implementing shouldLongPressLinkAttribute - returning true for both link and phone numbers
     */
    //open func textNode(_ textNode: ASTextNode, shouldLongPressLinkAttribute attribute: String, value: AnyObject, at point: CGPoint) -> Bool {
    public func textNode(_ textNode: ASTextNode, shouldLongPressLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
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
    //open func textNode(_ textNode: ASTextNode, longPressedLinkAttribute attribute: String, value: AnyObject, at point: CGPoint, textRange: NSRange) {
    public func textNode(_ textNode: ASTextNode, longPressedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        if attribute == "LinkAttribute"
        {
            self.lockKey = true
            if let tmpString = self.textMessageNode.attributedText
            {
                let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGray, range: textRange)
                self.textMessageNode.attributedText = attributedString

                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let openAction = UIAlertAction(title: "Open", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                let addToReadingListAction = UIAlertAction(title: "Add to Reading List", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let copyAction = UIAlertAction(title: "Copy", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                optionMenu.addAction(openAction)
                optionMenu.addAction(addToReadingListAction)
                optionMenu.addAction(copyAction)
                optionMenu.addAction(cancelAction)
                
                if let tmpCurrentViewController = self.currentViewController
                {
                    DispatchQueue.main.async(execute: { () -> Void in
                        tmpCurrentViewController.present(optionMenu, animated: true, completion: nil)
                    })
                    
                }
                
            }
            delay(0.4) {
                if let tmpString = self.textMessageNode.attributedText
                {
                    let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                    attributedString.removeAttribute(NSBackgroundColorAttributeName, range: textRange)
                    self.textMessageNode.attributedText = attributedString
                }
            }
        }
        else if attribute == "PhoneNumberAttribute"
        {
            let phoneNumber = value as! String
            self.lockKey = true
            if let tmpString = self.textMessageNode.attributedText
            {
                let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.lightGray, range: textRange)
                self.textMessageNode.attributedText = attributedString
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let callPhoneNumberAction = UIAlertAction(title: "Call \(phoneNumber)", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                let facetimeAudioAction = UIAlertAction(title: "Facetime Audio", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let sendMessageAction = UIAlertAction(title: "Send Message", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let addToContactsAction = UIAlertAction(title: "Add to Contacts", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let copyAction = UIAlertAction(title: "Copy", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
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
                    DispatchQueue.main.async(execute: { () -> Void in
                        tmpCurrentViewController.present(optionMenu, animated: true, completion: nil)
                    })
                    
                }
                
            }
            delay(0.4) {
                if let tmpString = self.textMessageNode.attributedText
                {
                    let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                    attributedString.removeAttribute(NSBackgroundColorAttributeName, range: textRange)
                    self.textMessageNode.attributedText = attributedString
                }
            }
        }
    }
    
    // MARK: UILongPressGestureRecognizer Selector Methods
    
    
    /**
     Overriding canBecomeFirstResponder to make cell first responder
     */
    override open func canBecomeFirstResponder() -> Bool {
        return true
    }
    /**
     Overriding resignFirstResponder to resign responder
     */
    override open func resignFirstResponder() -> Bool {
        return view.resignFirstResponder()
    }
    
    /**
     Override method from superclass
     */
    open override func messageNodeLongPressSelector(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            let touchLocation = recognizer.location(in: view)
            if self.textMessageNode.frame.contains(touchLocation) {
                becomeFirstResponder()
                delay(0.1, closure: {
                    let menuController = UIMenuController.shared
                    menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(TextContentNode.copySelector))]
                    menuController.setTargetRect(self.textMessageNode.frame, in: self.view)
                    menuController.setMenuVisible(true, animated:true)
                })
            }
        }
    }
    
    /**
     Copy Selector for UIMenuController
     */
    open func copySelector() {
        UIPasteboard.general.string = self.textMessageNode.attributedText!.string
    }
    
}
