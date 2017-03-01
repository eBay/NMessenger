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
open class MessageGroup: GeneralMessengerCell {
    
    /** Used for current state of new/old messages*/
    public enum MessageGroupState {
        case added
        case removed
        case replaced
        case none
    }
    
    // MARK: Public Variables
    open weak var delegate: MessageCellProtocol?
    /** Holds a table of GeneralMessengerCells*/
    open fileprivate(set) var messageTable = ASTableNode(style: .plain)
    /** Set to true when the after the component has laid out for the first time*/
    open fileprivate(set) var hasLaidOut = false
    /** Data set for messages in the group */
    open fileprivate(set) var messages = [GeneralMessengerCell]()
    /** Delay before add/remove animation begins*/
    open var animationDelay: TimeInterval = 0
    /** Avatar new message animation speed */
    open var avatarAnimationSpeed: TimeInterval = 0.15
    
    /**
     Spacing around the avatar
     */
    open var avatarInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /**
     Message offset spacing from the edge (avatar or messenger bounds)
     */
    open var messageOffset: CGFloat = 10 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /** ASDisplayNode as the avatar of the cell*/
    open var avatarNode: ASDisplayNode?
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
    open override var isIncomingMessage:Bool {
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
    fileprivate var layoutCompletionBlock: (()->Void)?
    /** Current state of new/old messages*/
    fileprivate var state: MessageGroupState?
    /** Default animation delay time for ASTableView*/
    fileprivate let tableviewAnimationDelay:TimeInterval = 0.3
    /** Button node to handle avatar click*/
    fileprivate var avatarButtonNode: ASControlNode = ASControlNode()
    
    //MARK: Initializers
    
    public override init() {
        super.init()
        self.setupTable()
        self.setupAvatarButton()
    }
    
    /** Initializes the ASTableNode for a group of messages*/
    fileprivate func setupTable() {
        self.messageTable.delegate = self
        self.messageTable.dataSource = self
        
        self.messageTable.view.separatorStyle = .none
        self.messageTable.view.isScrollEnabled = false
        self.messageTable.view.showsVerticalScrollIndicator = false
        
        self.addSubnode(self.messageTable)
    }
    
    /** Creates a listener for the avatar button */
    fileprivate func setupAvatarButton() {
        self.avatarButtonNode.addTarget(self, action:  #selector(MessageGroup.avatarClicked), forControlEvents: .touchUpInside)
        self.avatarButtonNode.isExclusiveTouch = true
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var tableWidth:CGFloat = 0
        
        let justifyLocation = isIncomingMessage ? ASStackLayoutJustifyContent.start : ASStackLayoutJustifyContent.end
        
        //make a space for the avatar if needed
        if let avatarNode = self.avatarNode {
            let layoutSize = avatarNode.layoutThatFits(ASSizeRangeMake(CGSize.zero, constrainedSize.max))
            tableWidth = constrainedSize.max.width - layoutSize.size.width - self.avatarInsets.left - self.avatarInsets.right - self.cellPadding.left - self.cellPadding.right - messageOffset
        } else {
            tableWidth = constrainedSize.max.width - self.cellPadding.left - self.cellPadding.right - self.messageOffset
        }
        
        var elementHeight:CGFloat = 0
        
        //get the size of every message in the group to calculate height
        for message in messages {
            let newSize = ASSizeRange(min: constrainedSize.min, max: CGSize(width: tableWidth, height: constrainedSize.max.height))
            let size = message.layoutThatFits(newSize).size
            print(size)
            elementHeight += size.height
        }
        self.messageTable.style.preferredSize = CGSize(width: tableWidth, height: elementHeight)
        
        var retLayout:ASLayoutSpec = ASStaticLayoutSpec()
        retLayout.children = [self.messageTable]
        
        var stackLayout: ASStackLayoutSpec?
        var insetLayout: ASInsetLayoutSpec?
        let spacer = ASLayoutSpec()
        
        //add the avatar to the layout
        if let avatarNode = self.avatarNode {
            let avatarSizeLayout = ASStaticLayoutSpec()
            avatarSizeLayout.children = [avatarNode]
            
            //create avatar button
            self.avatarButtonNode.style.preferredSize = avatarNode.layoutThatFits(ASSizeRange(min: CGSize.zero, max: constrainedSize.max)).size
            let avatarButtonSizeLayout = ASStaticLayoutSpec()
            avatarButtonSizeLayout.children = [self.avatarButtonNode]
            let avatarBackStack = ASBackgroundLayoutSpec(child: avatarButtonSizeLayout, background: avatarSizeLayout)
            
            let ins = ASInsetLayoutSpec(insets: self.avatarInsets, child: avatarBackStack)
            
            //layout horizontal stack
            let cellOrientation = self.isIncomingMessage ? [ins, retLayout] : [retLayout, ins]
            stackLayout = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: justifyLocation, alignItems: .end, children: cellOrientation)
            retLayout = stackLayout!
        }
        
        let cellOrientation = self.isIncomingMessage ? [spacer, retLayout] : [retLayout, spacer]
        stackLayout = ASStackLayoutSpec(direction: .horizontal, spacing: self.messageOffset, justifyContent: justifyLocation, alignItems: .end, children: cellOrientation)
        insetLayout = ASInsetLayoutSpec(insets: self.cellPadding, child: stackLayout!)
        
        return insetLayout!
    }
    
    /**
     Overriding animateLayoutTransition to animate add/remove transitions
     */
    override open func animateLayoutTransition(_ context: ASContextTransitioning) {
        if let state = self.state {
            switch(state) {
            case .added:
                if let _ = self.avatarNode {
                    self.avatarNode?.frame = context.initialFrame(for: self.avatarNode!)
                }
                
                UIView.animate(withDuration: self.avatarAnimationSpeed, delay: self.tableviewAnimationDelay + self.animationDelay, options: [], animations: {
                    if let _ = self.avatarNode {
                        self.avatarNode?.frame = context.finalFrame(for: self.avatarNode!)
                    }
                }) { (finished) in
                    //complete transition
                    context.completeTransition(finished)
                }
                
                //wait for layout animation
                let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(self.animationDelay)*1000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    //layout to reflect changes
                    self.setNeedsLayout()
                    let time: DispatchTime = DispatchTime.now() + Double(Int64(self.tableviewAnimationDelay)*1000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time) {
                        let tableView = self.messageTable.view
                        tableView.endUpdates()
                        self.callLayoutCompletionBlock()
                    }
                }
                break
            case .removed:
                if let _ = self.avatarNode {
                    self.avatarNode?.frame = context.initialFrame(for: self.avatarNode!)
                }
                
                UIView.animate(withDuration: self.tableviewAnimationDelay, delay: 0, options: [], animations: {
                    if let _ = self.avatarNode {
                        self.avatarNode?.frame = context.finalFrame(for: self.avatarNode!)
                    }
                }) { (finished) in
                    //call completion block and reset
                    self.callLayoutCompletionBlock()
                    //finish the transition
                    context.completeTransition(finished)
                }
                break
            case .replaced:
                if let _ = self.avatarNode {
                    self.avatarNode?.frame = context.initialFrame(for: self.avatarNode!)
                }
                
                UIView.animate(withDuration: self.avatarAnimationSpeed, delay: self.tableviewAnimationDelay, options: [], animations: {
                    if let _ = self.avatarNode {
                        self.avatarNode?.frame = context.finalFrame(for: self.avatarNode!)
                    }
                }) { (finished) in
                    //complete transition
                    context.completeTransition(finished)
                }
                
                //layout to reflect changes
                self.setNeedsLayout()
                let time: DispatchTime = DispatchTime.now() + Double(Int64(self.tableviewAnimationDelay)*1000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
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
    override open func layoutDidFinish() {
        super.layoutDidFinish()
        self.hasLaidOut = true
    }
    
    //MARk: Public functions
    
    /**
     Add a message to this group
     - parameter message: the message to add
     - parameter layoutCompletionBlock: The block to be called once the new node has been added
     */
    open func addMessageToGroup(_ message: GeneralMessengerCell, completion: (()->Void)?) {
        self.updateMessage(message)
        self.layoutCompletionBlock = completion
        
        //if the component is already on the screen
        if self.hasLaidOut {
            //set state
            self.state = .added
            //update table
            let tableView = self.messageTable.view
            tableView.beginUpdates()
            let indexPath = IndexPath(row: self.messages.count, section:0)
            self.messages.append(message)
            tableView.insertRows(at: [indexPath], with: .fade)
            //transition avatar + tableview cells
            self.transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
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
    open func replaceMessage(_ message: GeneralMessengerCell, withMessage newMessage: GeneralMessengerCell, completion: (()->Void)?) {
        if self.messages.contains(message) {
            if let index = self.messages.index(of: message) {
                self.updateMessage(newMessage)
                self.layoutCompletionBlock = completion
                message.currentTableNode = nil
                
                //make sure the group has been laid out so that animations will work
                if self.hasLaidOut {
                    //set state
                    self.state = .replaced
                    
                    //update table
                    let tableView = self.messageTable.view
                    tableView.beginUpdates()
                    self.messages[index] = newMessage
                    let indexPath = IndexPath(row: index, section:0)
                    tableView.reloadRows(at: [indexPath], with: .fade)
                    
                    let time: DispatchTime = DispatchTime.now() + Double(Int64(self.animationDelay)*1000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time) {
                        tableView.endUpdates(animated: true, completion: { (done) in
                            self.transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion:nil)
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
    open func removeMessageFromGroup(_ message: GeneralMessengerCell, completion: (()->Void)?) {
        
        if self.messages.contains(message) {
            if let index = self.messages.index(of: message) {
                let isLastMessage = self.messages.last == message
                self.layoutCompletionBlock = completion
                message.currentTableNode = nil
                
                //make sure the group has been laid out so that animations will work
                if self.hasLaidOut {
                    //set state
                    self.state = .removed
                    
                    //update table
                    let tableView = self.messageTable.view
                    tableView.beginUpdates()
                    self.messages.remove(at: index)
                    let indexPath = IndexPath(row: index, section:0)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    //use a special animation if it is the last message
                    if isLastMessage && self.avatarNode != nil {
                        UIView.animate(withDuration: self.avatarAnimationSpeed, delay: self.animationDelay, options: [], animations: {
                            if let avatarNode = self.avatarNode {
                                avatarNode.frame.origin.y = (self.messageTable.view.rectForRow(at: IndexPath(item: index-1, section: 0)).maxY) - avatarNode.frame.height + self.cellPadding.top
                            }
                            }, completion: nil)
                    }
                    
                    let extraDelay = isLastMessage && self.avatarNode != nil ? self.avatarAnimationSpeed : 0
                    
                    let time: DispatchTime = DispatchTime.now() + Double(Int64(extraDelay + self.animationDelay)*1000 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time) {
                        tableView.endUpdates(animated: true, completion: { (done) in
                            self.transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion:nil)
                        })
                    }
                } else { //message shouldn't be in this group
                    self.messages.remove(at: index)
                }
            }
        }
    }
    
    //MARK: helper methods
    
    /**
     Updates message UI features to reflect sender. These features are pulled from the message configuration. Also updates *currentTableNode* property to the message group's table
     - parameter message: the message to update
     */
    fileprivate func updateMessage(_ message: GeneralMessengerCell) {
        message.currentTableNode = self.messageTable
        
        //message specific UI
        if messages.first == nil { //will be the first message
            message.cellPadding = UIEdgeInsets.zero
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
    fileprivate func callLayoutCompletionBlock() {
        self.state = .none
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
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    public func tableView(_ tableView: ASTableView, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        return messages[(indexPath as NSIndexPath).row]
    }
}
