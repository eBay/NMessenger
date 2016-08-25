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

//MARK: MessageGroup
/**
 Holds a group of messages. Extends GeneralMessengerCell.
 */
public class MessageGroup: GeneralMessengerCell {
    
    /** Used for current state of new/old messages*/
    public enum MessageGroupState {
        case Added
        case Removed
        case Replaced
        case None
    }
    
    // MARK: Public Variables
    public var delegate: MessageCellProtocol?
    /** Holds a table of GeneralMessengerCells*/
    public private(set) var messageTable = ASTableNode(style: .Plain)
    /** Set to true when the after the component has laid out for the first time*/
    public private(set) var hasLaidOut = false
    /** Data set for messages in the group */
    public private(set) var messages = [GeneralMessengerCell]()
    /** Delay before add/remove animation begins*/
    public var animationDelay: NSTimeInterval = 0
    /** Avatar new message animation speed */
    public var avatarAnimationSpeed: NSTimeInterval = 0.15
    
    /**
     Spacing around the avatar
     */
    public var avatarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /**
     Message offset spacing from the edge (avatar or messenger bounds)
     */
    public var messageOffset: CGFloat = 10 {
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
                    self.insertSubnode(self.avatarButtonNode, aboveSubnode: avatarNode)
                    oldAvatar.removeFromSupernode()
                    self.avatarButtonNode.removeFromSupernode()
                } else {
                    self.addSubnode(avatarNode)
                    self.addSubnode(self.avatarButtonNode)
                }
            }
        }
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /** Bool if the cell is an incoming or out going message cell*/
    public override var isIncomingMessage:Bool {
        didSet {
            for message in messages {
                if let message = message as? MessageNode {
                    message.isIncomingMessage = isIncomingMessage
                }
            }
        }
    }
    
    //MARK: Private variables
    /** Layout completion block for adding/removing messages*/
    private var layoutCompletionBlock: (()->Void)?
    /** Current state of new/old messages*/
    private var state: MessageGroupState?
    /** Default animation delay time for ASTableView*/
    private let tableviewAnimationDelay:NSTimeInterval = 0.3
    /** Button node to handle avatar click*/
    private var avatarButtonNode: ASControlNode = ASControlNode()
    
    //MARK: Initializers
    
    public override init() {
        super.init()
        self.setupTable()
        self.setupAvatarButton()
    }
    
    /** Initializes the ASTableNode for a group of messages*/
    private func setupTable() {
        self.messageTable.delegate = self
        self.messageTable.dataSource = self
        
        self.messageTable.view.separatorStyle = .None
        self.messageTable.view.scrollEnabled = false
        self.messageTable.view.showsVerticalScrollIndicator = false
        
        self.addSubnode(self.messageTable)
    }
    
    /** Creates a listener for the avatar button */
    private func setupAvatarButton() {
        self.avatarButtonNode.addTarget(self, action:  #selector(MessageGroup.avatarClicked), forControlEvents: .TouchUpInside)
        self.avatarButtonNode.exclusiveTouch = true
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override public func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var tableWidth:CGFloat = 0
        
        let justifyLocation = isIncomingMessage ? ASStackLayoutJustifyContent.Start : ASStackLayoutJustifyContent.End
        
        //make a space for the avatar if needed
        if let avatarNode = self.avatarNode {
            let size = avatarNode.measure(constrainedSize.max)
            tableWidth = constrainedSize.max.width - size.width - self.avatarInsets.left - self.avatarInsets.right - self.cellPadding.left - self.cellPadding.right - messageOffset
        } else {
            tableWidth = constrainedSize.max.width - self.cellPadding.left - self.cellPadding.right - self.messageOffset
        }
        
        var elementHeight:CGFloat = 0
        
        //get the size of every message in the group to calculate height
        for message in messages {
            let newSize = ASSizeRange(min: constrainedSize.min, max: CGSizeMake(tableWidth, constrainedSize.max.height))
            let size = message.measureWithSizeRange(newSize).size
            elementHeight += size.height
        }
        self.messageTable.preferredFrameSize = CGSizeMake(tableWidth, elementHeight)
        
        var retLayout:ASLayoutSpec = ASStaticLayoutSpec(children: [self.messageTable])
        
        var stackLayout: ASStackLayoutSpec?
        var insetLayout: ASInsetLayoutSpec?
        let spacer = ASLayoutSpec()
        
        //add the avatar to the layout
        if let avatarNode = self.avatarNode {
            let avatarSizeLayout = ASStaticLayoutSpec(children: [avatarNode])
            
            //create avatar button
            self.avatarButtonNode.preferredFrameSize = avatarNode.measure(constrainedSize.max)
            let avatarButtonSizeLayout = ASStaticLayoutSpec(children: [self.avatarButtonNode])
            let avatarBackStack = ASBackgroundLayoutSpec(child: avatarButtonSizeLayout, background: avatarSizeLayout)
            
            let ins = ASInsetLayoutSpec(insets: self.avatarInsets, child: avatarBackStack)
            
            //layout horizontal stack
            let cellOrientation = self.isIncomingMessage ? [ins, retLayout] : [retLayout, ins]
            stackLayout = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: justifyLocation, alignItems: .End, children: cellOrientation)
            retLayout = stackLayout!
        }
        
        let cellOrientation = self.isIncomingMessage ? [spacer, retLayout] : [retLayout, spacer]
        stackLayout = ASStackLayoutSpec(direction: .Horizontal, spacing: self.messageOffset, justifyContent: justifyLocation, alignItems: .End, children: cellOrientation)
        insetLayout = ASInsetLayoutSpec(insets: self.cellPadding, child: stackLayout!)
        
        return insetLayout!
    }
    
    /**
     Overriding animateLayoutTransition to animate add/remove transitions
     */
    override public func animateLayoutTransition(context: ASContextTransitioning) {
        if let state = self.state {
            switch(state) {
            case .Added:
                if let _ = self.avatarNode {
                    self.avatarNode?.frame = context.initialFrameForNode(self.avatarNode!)
                }
                
                UIView.animateWithDuration(self.avatarAnimationSpeed, delay: self.tableviewAnimationDelay + self.animationDelay, options: [], animations: {
                    if let _ = self.avatarNode {
                        self.avatarNode?.frame = context.finalFrameForNode(self.avatarNode!)
                    }
                }) { (finished) in
                    //complete transition
                    context.completeTransition(finished)
                }
                
                //wait for layout animation
                dispatch_after(dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(self.animationDelay)*1000 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue()) {
                    //layout to reflect changes
                    self.setNeedsLayout()
                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(self.tableviewAnimationDelay)*1000 * Int64(NSEC_PER_MSEC))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        let tableView = self.messageTable.view
                        tableView.endUpdates()
                        self.callLayoutCompletionBlock()
                    }
                }
                break
            case .Removed:
                if let _ = self.avatarNode {
                    self.avatarNode?.frame = context.initialFrameForNode(self.avatarNode!)
                }
                
                UIView.animateWithDuration(self.tableviewAnimationDelay, delay: 0, options: [], animations: {
                    if let _ = self.avatarNode {
                        self.avatarNode?.frame = context.finalFrameForNode(self.avatarNode!)
                    }
                }) { (finished) in
                    //call completion block and reset
                    self.callLayoutCompletionBlock()
                    //finish the transition
                    context.completeTransition(finished)
                }
                break
            case .Replaced:
                if let _ = self.avatarNode {
                    self.avatarNode?.frame = context.initialFrameForNode(self.avatarNode!)
                }
                
                UIView.animateWithDuration(self.avatarAnimationSpeed, delay: self.tableviewAnimationDelay, options: [], animations: {
                    if let _ = self.avatarNode {
                        self.avatarNode?.frame = context.finalFrameForNode(self.avatarNode!)
                    }
                }) { (finished) in
                    //complete transition
                    context.completeTransition(finished)
                }
                
                //layout to reflect changes
                self.setNeedsLayout()
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(self.tableviewAnimationDelay)*1000 * Int64(NSEC_PER_MSEC))
                dispatch_after(time, dispatch_get_main_queue()) {
                    let tableView = self.messageTable.view
                    tableView.endUpdates()
                    self.callLayoutCompletionBlock()
                }
                
                break
            default:
                //no animation
                context.completeTransition(true)
            }
        }
    }
    
    /**
     Overriding layoutDidFinish to flag first layout
     */
    override public func layoutDidFinish() {
        super.layoutDidFinish()
        self.hasLaidOut = true
    }
    
    //MARk: Public functions
    
    /**
     Add a message to this group
     - parameter message: the message to add
     - parameter layoutCompletionBlock: The block to be called once the new node has been added
     */
    public func addMessageToGroup(message: GeneralMessengerCell, completion: (()->Void)?) {
        self.updateMessage(message)
        self.layoutCompletionBlock = completion
        
        //if the component is already on the screen
        if self.hasLaidOut {
            //set state
            self.state = .Added
            //update table
            let tableView = self.messageTable.view
            tableView.beginUpdates()
            let indexPath = NSIndexPath(forRow: self.messages.count, inSection:0)
            self.messages.append(message)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            //transition avatar + tableview cells
            self.transitionLayoutWithAnimation(true, shouldMeasureAsync: false, measurementCompletion: nil)
        } else {
            self.messages.append(message)
        }
    }
    
    /**
     If the message exists in the group, it will be replaced with the new message. **Unimplemented**
     - parameter message: The message to replace
     - parameter withMessage: The message that will replace the old one
     - parameter layoutCompletionBlock: The block to be called once the old node has been replaced
     */
    public func replaceMessage(message: GeneralMessengerCell, withMessage newMessage: GeneralMessengerCell, completion: (()->Void)?) {
        if self.messages.contains(message) {
            if let index = self.messages.indexOf(message) {
                self.updateMessage(newMessage)
                self.layoutCompletionBlock = completion
                message.currentTableNode = nil
                
                //make sure the group has been laid out so that animations will work
                if self.hasLaidOut {
                    //set state
                    self.state = .Replaced
                    
                    //update table
                    let tableView = self.messageTable.view
                    tableView.beginUpdates()
                    self.messages[index] = newMessage
                    let indexPath = NSIndexPath(forRow: index, inSection:0)
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(self.animationDelay)*1000 * Int64(NSEC_PER_MSEC))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        tableView.endUpdatesAnimated(true, completion: { (done) in
                            self.transitionLayoutWithAnimation(true, shouldMeasureAsync: false, measurementCompletion:nil)
                        })
                    }
                } else { //replace message
                    self.messages[index] = newMessage
                }
            }
        }
    }
    
    /**
     Remove a message from this group
     - parameter message: the message to remove
     - parameter layoutCompletionBlock: The block to be called once the new node has been removed
     */
    public func removeMessageFromGroup(message: GeneralMessengerCell, completion: (()->Void)?) {
        
        if self.messages.contains(message) {
            if let index = self.messages.indexOf(message) {
                let isLastMessage = self.messages.last == message
                self.layoutCompletionBlock = completion
                message.currentTableNode = nil
                
                //make sure the group has been laid out so that animations will work
                if self.hasLaidOut {
                    //set state
                    self.state = .Removed
                    
                    //update table
                    let tableView = self.messageTable.view
                    tableView.beginUpdates()
                    self.messages.removeAtIndex(index)
                    let indexPath = NSIndexPath(forRow: index, inSection:0)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                    //use a special animation if it is the last message
                    if isLastMessage && self.avatarNode != nil {
                        UIView.animateWithDuration(self.avatarAnimationSpeed, delay: self.animationDelay, options: [], animations: {
                            if let avatarNode = self.avatarNode {
                                avatarNode.frame.origin.y = self.messageTable.view.rectForRowAtIndexPath(NSIndexPath(forItem: index-1, inSection: 0)).maxY - avatarNode.frame.height + self.cellPadding.top
                            }
                            }, completion: nil)
                    }
                    
                    let extraDelay = isLastMessage && self.avatarNode != nil ? self.avatarAnimationSpeed : 0
                    
                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(extraDelay + self.animationDelay)*1000 * Int64(NSEC_PER_MSEC))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        tableView.endUpdatesAnimated(true, completion: { (done) in
                            self.transitionLayoutWithAnimation(true, shouldMeasureAsync: false, measurementCompletion:nil)
                        })
                    }
                } else { //message shouldn't be in this group
                    self.messages.removeAtIndex(index)
                }
            }
        }
    }
    
    //MARK: helper methods
    
    /**
     Updates message UI features to reflect sender. These features are pulled from the message configuration. Also updates *currentTableNode* property to the message group's table
     - parameter message: the message to update
     */
    private func updateMessage(message: GeneralMessengerCell) {
        message.currentTableNode = self.messageTable
        
        //message specific UI
        if messages.first == nil { //will be the first message
            message.cellPadding = UIEdgeInsetsZero
            if let message = message as? MessageNode {
                message.contentNode?.backgroundBubble = message.contentNode?.bubbleConfiguration.getBubble()
                message.isIncomingMessage = self.isIncomingMessage
                //set the offset to 0 to prevent spacing issues
                message.messageOffset = 0
            }
        } else {
            message.cellPadding = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
            if let message = message as? MessageNode {
                message.contentNode?.backgroundBubble = message.contentNode?.bubbleConfiguration.getSecondaryBubble()
                message.isIncomingMessage = self.isIncomingMessage
                //set the offset to 0 to prevent spacing issues
                message.messageOffset = 0
            }
        }
    }
    
    
    /** Calls and resets the layout completion block */
    private func callLayoutCompletionBlock() {
        self.state = .None
        self.layoutCompletionBlock?()
        self.layoutCompletionBlock = nil
    }
    
}

/** Delegate functions extension */
extension MessageGroup {
    /**
     Notifies the delegate that the avatar was clicked
     */
    public func avatarClicked() {
        self.delegate?.avatarClicked?(self)
    }
}

/** TableView functions extension */
extension MessageGroup: ASTableDelegate, ASTableDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    public func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        return messages[indexPath.row]
    }
}