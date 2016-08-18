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
import AVFoundation
import Photos
import AsyncDisplayKit

public class NMessengerViewController: UIViewController, UITextViewDelegate, NMessengerDelegate, UIGestureRecognizerDelegate {
    
    //MARK: IBOutlets
    //@IBOutlet that is messanger view
    public var messengerView: NMessenger!
    //@IBOutlet that is input view
    public var inputBarView: BaseInputBarView!
    
    //MARK: Private Variables
    //Bool to idicate if the keyboard is open
    public private(set) var isKeyboardIsShown : Bool = false
    //NSLayoutConstraint for the input bar spacing from the bottom
    private var inputBarBottomSpacing:NSLayoutConstraint = NSLayoutConstraint()
    //NSLayoutConstraint for the messenger spacing from the input bar
    private var messengerBottomSpacing:NSLayoutConstraint = NSLayoutConstraint()
    //MARK: Public Variables
    //UIEdgeInsets for padding for each message
    public var messagePadding: UIEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    /** A shared bubble configuration to use for new messages. Defaults to **SharedBubbleConfiguration***/
    public var sharedBubbleConfiguration: BubbleConfigurationProtocol = StandardBubbleConfiguration()
    
    // MARK: Initialisers
    
    /**
     Initialiser for the controller.
     Adds observers
     */
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.addObservers()
    }
    // MARK: Initialisers
    
    /**
     Initialiser for the controller.
     - parameter nibNameOrNil: Can be String
     - parameter nibBundleOrNil: Can be NSBundle
     Adds observers
     */
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.addObservers()
    }
    /**
     Initialiser from xib
     Adds observers
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addObservers()
    }
    
    /**
     Deinitialiser for controller.
     Removes observers
     */
    deinit {
        self.removeObservers()
    }
    
    // MARK: Initialisers helper methods
    /**
     Adds observer for UIKeyboardWillChangeFrameNotification
     */
    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NMessengerViewController.keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    /**
     Removes observer for UIKeyboardWillChangeFrameNotification
     */
    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Controller LifeCycle
    /**
     Overriding viewDidLoad to setup the view contoller
     Calls helper methods
     */
    override public func viewDidLoad() {
        super.viewDidLoad()
        //load views
        loadMessengerView()
        loadInputView()
        setUpConstriantsForViews()
        //swipe down
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(NMessengerViewController.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.inputBarView.textInputAreaView.addGestureRecognizer(swipeDown)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Controller LifeCycle helper methods
    /**
     Creates NMessenger view and adds it to the view
     */
    private func loadMessengerView() {
        self.messengerView = NMessenger(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 63))
        messengerView.delegate = self
        self.view.addSubview(self.messengerView)
    }
    /**
     Adds BaseInputBarView to the view
     */
    private func loadInputView()
    {
        self.inputBarView = self.customInputBar()
        self.view.addSubview(inputBarView)
    }
    
    /**
     Methods sbould be ovverride if creating a custom input bar
     - Returns: A view that extends BaseInputBarView
     */
    public func customInputBar() -> BaseInputBarView
    {
        return InputBarView(controller: self)
    }
    /**
     Adds auto layout constraints for NMessenger and InputBarView
     */
    private func setUpConstriantsForViews()
    {
        inputBarView.translatesAutoresizingMaskIntoConstraints = false
        self.inputBarBottomSpacing = NSLayoutConstraint(item: self.inputBarView, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0)
        self.view.addConstraint(self.inputBarBottomSpacing)
        self.view.addConstraint(NSLayoutConstraint(item: self.inputBarView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.inputBarView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: inputBarView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.inputBarView.frame.size.height))
        self.messengerView.translatesAutoresizingMaskIntoConstraints = false
        self.messengerBottomSpacing = NSLayoutConstraint(item: self.messengerView, attribute: .Bottom, relatedBy: .Equal, toItem: self.inputBarView, attribute: .Top, multiplier: 1, constant: 0)
        self.view.addConstraint(self.messengerBottomSpacing)
        self.view.addConstraint(NSLayoutConstraint(item: self.messengerView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.messengerView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.messengerView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1, constant: 0))
    }
    
    //MARK: UIKeyboardWillChangeFrameNotification Selector
    /**
     Moves InputBarView up and down accoridng to the location of the keyboard
     */
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrame?.origin.y >= UIScreen.mainScreen().bounds.size.height {
                self.inputBarBottomSpacing.constant = 0
                self.isKeyboardIsShown = false
            } else {
                if self.inputBarBottomSpacing.constant==0
                {
                    self.inputBarBottomSpacing.constant -= endFrame?.size.height ?? 0.0
                }
                else
                {
                    self.inputBarBottomSpacing.constant = 0
                    self.inputBarBottomSpacing.constant -= endFrame?.size.height ?? 0.0
                }
                self.isKeyboardIsShown = true
            }
            UIView.animateWithDuration(duration,
                                       delay: NSTimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded()
                                        if self.isKeyboardIsShown {
                                            self.messengerView.scrollToLastMessage(true)
                                        }
                },
                                       completion: nil)
        }
    }
    
    //MARK: Gesture Recognizers Selector
    
    /**
     Closes the messenger on swipe on InputBarView
     */
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.inputBarView.textInputView.resignFirstResponder()
    }
    
    //MARK: NMessengerViewController - override to create custom behavior
    /**
     Called when adding a text to the meesenger. Override this function to add your message to the VC
     */
    public func sendText(text: String, isIncomingMessage:Bool) -> GeneralMessengerCell {
        return self.postText(text,isIncomingMessage: isIncomingMessage)
    }
    /**
     Called  when adding an image to the meesenger. Override this function to add your message to the VC
     */
    public func sendImage(image: UIImage, isIncomingMessage:Bool) -> GeneralMessengerCell {
        return self.postImage(image,isIncomingMessage: isIncomingMessage)
    }
    /**
     Called when adding a network image to the meesenger. Override this function to add your message to the VC
     */
    public func sendNetworkImage(imageURL: String, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postNetworkImage(imageURL,isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a collection view with views to the meesenger. Override this function to add your message to the VC
     */
    public func sendCollectionViewWithViews(views: [UIView], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postCollectionView(views, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a collection view with nodes to the meesenger. Override this function to add your message to the VC
     */
    public func sendCollectionViewWithNodes(nodes: [ASDisplayNode], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postCollectionView(nodes, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
    }
    
    
    /**
     Called when adding a a custom view to the meesenger. Override this function to add your message to the VC
     */
    public func sendCustomView(view: UIView, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postCustomContent(view, isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a a custom node to the meesenger. Override this function to add your message to the VC
     */
    public func sendCustomNode(node: ASDisplayNode, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postCustomContent(node, isIncomingMessage: isIncomingMessage)
    }
    
    //MARK: NMessengerViewController - Add messege methods - DO NOT OVVERRIDE
    /**
     DO NOT OVVERRIDE
     Adds a message to the messanger
     - parameter message: MessageNode
     */
    public func addMessgeToMessenger(message:MessageNode)
    {
        message.currentViewController = self
        if message.isIncomingMessage == false
        {
            self.messengerView.addMessage(message, scrollsToMessage: true, withAnimation: .Right)
        }
        else
        {
            self.messengerView.addMessage(message, scrollsToMessage: true, withAnimation: .Left)
        }
    }
    
    /**
     Adds a message group to the messanger
     - parameter messageGroup: MessageGroup
     */
    public func addMessageGroupToMessenger(messageGroup:MessageGroup)
    {
        messageGroup.currentViewController = self
        if messageGroup.isIncomingMessage == false
        {
            self.messengerView.addMessage(messageGroup, scrollsToMessage: true, withAnimation: .Right)
        }
        else
        {
            self.messengerView.addMessage(messageGroup, scrollsToMessage: true, withAnimation: .Left)
        }
    }
    
    /**
     Adds a general message to the messanger. Default animation is fade.
     - parameter messageGroup: MessageGroup
     */
    public func addGeneralMessengeToMessenger(message: GeneralMessengerCell) {
        message.currentViewController = self
        self.messengerView.addMessage(message, scrollsToMessage: false, withAnimation: .Fade)
    }
    
    /**
     Adds an incoming typing indicator to the messenger
     */
    public func showTypingIndicator(avatar: ASDisplayNode?) -> GeneralMessengerCell
    {
        let typing = TypingIndicatorContent(bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: typing)
        newMessage.avatarNode = avatar
        messengerView.addTypingIndicator(newMessage, scrollsToLast: false, animated: true, completion: nil)
        return newMessage
    }
    
    /**
     removes a typing indicator from the messenger
     */
    public func removeTypingIndicator(indicator: GeneralMessengerCell) {
        messengerView.removeTypingIndicator(indicator, scrollsToLast: false, animated: true)
    }
    
    //MARK: NMessengerViewController Helper methods
    /**
     Adds a text message as outgoing
     - parameter text: the text content to post
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    private func postText(text: String, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let textContent = TextContentNode(textMessegeString: text, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: textContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        self.addMessgeToMessenger(newMessage)
        return newMessage
    }
    
    /**
     Adds an image message as outgoing
     - parameter image: the image to be displayed
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    private func postImage(image: UIImage, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let imageContent = ImageContentNode(image: image, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: imageContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        self.addMessgeToMessenger(newMessage)
        return newMessage
    }
    
    /**
     Adds an image message as outgoing
     - parameter image: the image to be displayed
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    private func postNetworkImage(url: String, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let networkImageContent = NetworkImageContentNode(imageURL: url, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: networkImageContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        self.addMessgeToMessenger(newMessage)
        return newMessage
    }
    
    
    /**
     Adds an image message as outgoing
     - parameter views: a [UIView] that are the view for the collection view
     - parameter numberOfRows: CGFloat number of rows in the collection view
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    private func postCollectionView(views: [UIView], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let collectionViewContent = CollectionViewContentNode(withCustomViews: views, andNumberOfRows: numberOfRows, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: collectionViewContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        self.addMessgeToMessenger(newMessage)
        return newMessage
    }
    
    /**
     Adds an image message as outgoing
     - parameter views: a [ASDisplayNode] that are the view for the collection view
     - parameter numberOfRows: CGFloat number of rows in the collection view
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    private func postCollectionView(nodes: [ASDisplayNode], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let collectionViewContent = CollectionViewContentNode(withCustomNodes: nodes, andNumberOfRows: numberOfRows, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: collectionViewContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        self.addMessgeToMessenger(newMessage)
        return newMessage
    }
    
    
    /**
     Adds an image message as outgoing
     - parameter view: a UIView that is the view for the message
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    private func postCustomContent(view: UIView, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let customView = CustomContentNode(withCustomView: view, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: customView)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        self.addMessgeToMessenger(newMessage)
        return newMessage
    }
    
    /**
     Adds an image message as outgoing
     - parameter view: a ASDisplayNode that is the view for the message
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    private func postCustomContent(node: ASDisplayNode, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let customView = CustomContentNode(withCustomNode: node, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: customView)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        self.addMessgeToMessenger(newMessage)
        return newMessage
    }

}