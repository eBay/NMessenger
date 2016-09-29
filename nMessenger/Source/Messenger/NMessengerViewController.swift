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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


open class NMessengerViewController: UIViewController, UITextViewDelegate, NMessengerDelegate, UIGestureRecognizerDelegate {
    
    //MARK: Views
    //This is messenger view
    open var messengerView: NMessenger!
    //This is input view
    open var inputBarView: InputBarView!
    
    //MARK: Private Variables
    //Bool to indicate if the keyboard is open
    open fileprivate(set) var isKeyboardIsShown : Bool = false
    //NSLayoutConstraint for the input bar spacing from the bottom
    fileprivate var inputBarBottomSpacing:NSLayoutConstraint = NSLayoutConstraint()
    //MARK: Public Variables
    //UIEdgeInsets for padding for each message
    open var messagePadding: UIEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    /** A shared bubble configuration to use for new messages. Defaults to **SharedBubbleConfiguration***/
    open var sharedBubbleConfiguration: BubbleConfigurationProtocol = StandardBubbleConfiguration()
    
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
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(NMessengerViewController.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    /**
     Removes observer for UIKeyboardWillChangeFrameNotification
     */
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Controller LifeCycle
    /**
     Overriding viewDidLoad to setup the view controller
     Calls helper methods
     */
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        //load views
        loadMessengerView()
        loadInputView()
        setUpConstraintsForViews()
        //swipe down
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(NMessengerViewController.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.inputBarView.textInputAreaView.addGestureRecognizer(swipeDown)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Controller LifeCycle helper methods
    /**
     Creates NMessenger view and adds it to the view
     */
    fileprivate func loadMessengerView() {
        self.messengerView = NMessenger(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 63))
        messengerView.delegate = self
        self.view.addSubview(self.messengerView)
    }
    /**
     Adds BaseInputBarView to the view
     */
    fileprivate func loadInputView()
    {
        self.inputBarView = self.getInputBar()
        self.view.addSubview(inputBarView)
    }
    
    /**
     Override this method to create your own custom InputBarView
     - Returns: A view that extends InputBarView
     */
    open func getInputBar() -> InputBarView
    {
        return NMessengerBarView(controller: self)
    }
    /**
     Adds auto layout constraints for NMessenger and InputBarView
     */
    fileprivate func setUpConstraintsForViews()
    {
        inputBarView.translatesAutoresizingMaskIntoConstraints = false
        self.inputBarBottomSpacing = NSLayoutConstraint(item: self.inputBarView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
        self.view.addConstraint(self.inputBarBottomSpacing)
        self.view.addConstraint(NSLayoutConstraint(item: self.inputBarView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.inputBarView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: inputBarView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.inputBarView.frame.size.height))
        self.view.addConstraint(NSLayoutConstraint(item: inputBarView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 43))
        self.messengerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: self.messengerView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.messengerView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.messengerView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.messengerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.view.frame.size.height-63))
    }
    
    open override var shouldAutorotate: Bool {
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
            UIDevice.current.orientation == UIDeviceOrientation.landscapeRight) {
            return false;
        }
        else {
            return true;
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait]
    }
    
    //MARK: UIKeyboardWillChangeFrameNotification Selector
    /**
     Moves InputBarView up and down accoridng to the location of the keyboard
     */
    func keyboardNotification(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrame?.origin.y >= UIScreen.main.bounds.size.height {
                self.inputBarBottomSpacing.constant = 0
                self.messengerView.messengerNode.view.contentInset = UIEdgeInsets.zero
                self.isKeyboardIsShown = false
            } else {
                if self.inputBarBottomSpacing.constant==0
                {
                    self.inputBarBottomSpacing.constant -= endFrame?.size.height ?? 0.0
                    self.messengerView.messengerNode.view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame?.size.height ?? 0.0, right: 0)
                }
                else
                {
                    self.inputBarBottomSpacing.constant = 0
                    self.inputBarBottomSpacing.constant -= endFrame?.size.height ?? 0.0
                    self.messengerView.messengerNode.view.contentInset = UIEdgeInsets.zero
                }
                self.isKeyboardIsShown = true
            }
            
            self.messengerView.messengerNode.view.scrollIndicatorInsets = self.messengerView.messengerNode.view.contentInset
            
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
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
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        self.inputBarView.textInputView.resignFirstResponder()
    }
    
    //MARK: NMessengerViewController - override to create custom behavior
    /**
     Called when adding a text to the messenger. Override this function to add your message to the VC
     */
    open func sendText(_ text: String, isIncomingMessage:Bool) -> GeneralMessengerCell {
        return self.postText(text,isIncomingMessage: isIncomingMessage)
    }
    /**
     Called  when adding an image to the messenger. Override this function to add your message to the VC
     */
    open func sendImage(_ image: UIImage, isIncomingMessage:Bool) -> GeneralMessengerCell {
        return self.postImage(image,isIncomingMessage: isIncomingMessage)
    }
    /**
     Called when adding a network image to the messenger. Override this function to add your message to the VC
     */
    open func sendNetworkImage(_ imageURL: String, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postNetworkImage(imageURL,isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a collection view with views to the messenger. Override this function to add your message to the VC
     */
    open func sendCollectionViewWithViews(_ views: [UIView], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postCollectionView(views, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a collection view with nodes to the messenger. Override this function to add your message to the VC
     */
    open func sendCollectionViewWithNodes(_ nodes: [ASDisplayNode], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postCollectionView(nodes, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
    }
    
    
    /**
     Called when adding a a custom view to the messenger. Override this function to add your message to the VC
     */
    open func sendCustomView(_ view: UIView, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postCustomContent(view, isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a a custom node to the messenger. Override this function to add your message to the VC
     */
    open func sendCustomNode(_ node: ASDisplayNode, isIncomingMessage:Bool) -> GeneralMessengerCell
    {
        return self.postCustomContent(node, isIncomingMessage: isIncomingMessage)
    }
    
    //MARK: NMessengerViewController - Add message methods - DO NOT OVERRIDE
    /**
     DO NOT OVERRIDE
     Adds a message to the messenger
     - parameter message: GeneralMessageCell
     */
    open func addMessageToMessenger(_ message:GeneralMessengerCell)
    {
        message.currentViewController = self
        if message.isIncomingMessage == false {
            self.messengerView.addMessage(message, scrollsToMessage: true, withAnimation: .right)
        } else {
            self.messengerView.addMessage(message, scrollsToMessage: true, withAnimation: .left)
        }
    }
    
    /**
     Adds a general message to the messenger. Default animation is fade.
     - parameter messageGroup: MessageGroup
     */
    open func addGeneralMessengerToMessenger(_ message: GeneralMessengerCell) {
        message.currentViewController = self
        self.messengerView.addMessage(message, scrollsToMessage: false, withAnimation: .fade)
    }
    
    /**
     Creates an incoming typing indicator
     - parameter avatar: an avatar to add to the typing indicator message
     */
    open func createTypingIndicator(_ avatar: ASDisplayNode?) -> GeneralMessengerCell
    {
        let typing = TypingIndicatorContent(bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: typing)
        newMessage.avatarNode = avatar
        
        return newMessage
    }
    
    /**
     Adds an incoming typing indicator to the messenger
     - parameter avatar: an avatar to add to the typing indicator message
     */
    open func showTypingIndicator(_ avatar: ASDisplayNode?) -> GeneralMessengerCell
    {
        let newMessage = self.createTypingIndicator(avatar)
        messengerView.addTypingIndicator(newMessage, scrollsToLast: false, animated: true, completion: nil)
        return newMessage
    }
    
    /**
     removes a typing indicator from the messenger
     */
    open func removeTypingIndicator(_ indicator: GeneralMessengerCell) {
        messengerView.removeTypingIndicator(indicator, scrollsToLast: false, animated: true)
    }
    
    //MARK: NMessengerViewController Helper methods
    
    /**
     Creates a new text message
     - parameter text: the text to add to the message
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    open func createTextMessage(_ text: String, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let textContent = TextContentNode(textMessageString: text, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: textContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    /**
     Adds a text message to the messenger
     - parameter text: the text content to post
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    fileprivate func postText(_ text: String, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let newMessage = createTextMessage(text, isIncomingMessage: isIncomingMessage)
        self.addMessageToMessenger(newMessage)
        return newMessage
    }
    
    /**
     Creates a new image message
     - parameter image: the image to be displayed
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    open func createImageMessage(_ image: UIImage, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let imageContent = ImageContentNode(image: image, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: imageContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    /**
     Adds an image message to the messenger
     - parameter image: the image to be displayed
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    fileprivate func postImage(_ image: UIImage, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let newMessage = self.createImageMessage(image, isIncomingMessage: isIncomingMessage)
        self.addMessageToMessenger(newMessage)
        return newMessage
    }
    
    
    /**
     Creates a new image message
     - parameter url: the image url to be displayed
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    open func createNetworkImageMessage(_ url: String, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let networkImageContent = NetworkImageContentNode(imageURL: url, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: networkImageContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
    
        return newMessage
    }
    
    /**
     Adds an image message to the messenger
     - parameter url: the image url to be displayed
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    fileprivate func postNetworkImage(_ url: String, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let newMessage = self.createNetworkImageMessage(url, isIncomingMessage: isIncomingMessage)
        self.addMessageToMessenger(newMessage)
        return newMessage
    }
    
    /**
     Creates a new collection view message
     - parameter views: a [UIView] that are the view for the collection view
     - parameter numberOfRows: CGFloat number of rows in the collection view
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    open func createCollectionViewMessage(_ views: [UIView], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let collectionViewContent = CollectionViewContentNode(withCustomViews: views, andNumberOfRows: numberOfRows, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: collectionViewContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    /**
     Adds a collection view message to the messenger
     - parameter views: a [UIView] that are the view for the collection view
     - parameter numberOfRows: CGFloat number of rows in the collection view
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    fileprivate func postCollectionView(_ views: [UIView], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let newMessage = self.createCollectionViewMessage(views, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
        self.addMessageToMessenger(newMessage)
        return newMessage
    }
    
    /**
     Creates a new collection view message
     - parameter views: a [ASDisplayNode] that are the view for the collection view
     - parameter numberOfRows: CGFloat number of rows in the collection view
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    open func createCollectionNodeMessage(_ nodes: [ASDisplayNode], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let collectionViewContent = CollectionViewContentNode(withCustomNodes: nodes, andNumberOfRows: numberOfRows, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: collectionViewContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
    
        return newMessage
    }
    
    /**
     Adds a collection view message to the messenger
     - parameter views: a [ASDisplayNode] that are the view for the collection view
     - parameter numberOfRows: CGFloat number of rows in the collection view
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    fileprivate func postCollectionView(_ nodes: [ASDisplayNode], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let newMessage = self.createCollectionNodeMessage(nodes, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
        self.addMessageToMessenger(newMessage)
        return newMessage
    }
    
    /**
     Creates a custom content message
     - parameter view: a UIView that is the view for the message
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    open func createCustomContentViewMessage(_ view: UIView, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let customView = CustomContentNode(withCustomView: view, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: customView)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
    
        return newMessage
    }
    
    /**
     Adds a custom content message to the messenger
     - parameter view: a UIView that is the view for the message
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    fileprivate func postCustomContent(_ view: UIView, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let newMessage = self.createCustomContentViewMessage(view, isIncomingMessage: isIncomingMessage)
        self.addMessageToMessenger(newMessage)
        return newMessage
    }
    
    
    /**
     Creates a custom content message
     - parameter view: a ASDisplayNode that is the view for the message
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    open func createCustomContentNodeMessage(_ node: ASDisplayNode, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let customView = CustomContentNode(withCustomNode: node, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: customView)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
    
        return newMessage
    }
    
    /**
     Adds a custom content message to the messenger
     - parameter view: a ASDisplayNode that is the view for the message
     - parameter isIncomingMessage: if message is incoming or outgoing
     - returns: the newly created message
     */
    fileprivate func postCustomContent(_ node: ASDisplayNode, isIncomingMessage:Bool) -> GeneralMessengerCell {
        let newMessage = self.createCustomContentNodeMessage(node, isIncomingMessage: isIncomingMessage)
        self.addMessageToMessenger(newMessage)
        return newMessage
    }

}
