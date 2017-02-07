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
import AsyncDisplayKit

@objc public protocol NMessengerDelegate {
    /**
     Triggered when a load batch content should be called. This method is called on a background thread.
     Make sure to add prefetched content with *endBatchFetchWithMessages(messages: [GeneralMessengerCell])*
     */
    @objc optional func batchFetchContent()
    /** Returns a newly created loading Indicator that should be used at the top of the messenger */
    @objc optional func batchFetchLoadingIndicator()->GeneralMessengerCell
}

//MARK: NMessengerSemaphore
/**
 N Messenger Framework. Works in a multithreaded environment + implements prefetching at the head
 */
open class NMessenger: UIView {
    
    //MARK: Messenger enum
    fileprivate enum NMessengerSection: Int {
        case messenger = 0
        case typingIndicator = 1
    }
    
    
    //MARK: Messenger state
    fileprivate struct NMessengerState {
        //Messenger states
        var itemCount: Int
        var lastContentOffset: CGFloat
        var scrollDirection: ASScrollDirection
        
        //Buffers
        var cellBufferStartIndex: Int
        var cellBuffer: [GeneralMessengerCell]
        var typingIndicators: [GeneralMessengerCell]
        
        //Locks
        let messageLock: DispatchSemaphore
        let batchFetchLock: ASBatchContext
        
        //initializer
        static let initialState = NMessengerState(itemCount: 0, lastContentOffset: 0, scrollDirection: ASScrollDirection(), cellBufferStartIndex: Int.max, cellBuffer: [GeneralMessengerCell](), typingIndicators: [GeneralMessengerCell](),messageLock: DispatchSemaphore(value: 1), batchFetchLock: ASBatchContext())
    }
    
    //MARK: Private variables
    
    /** ASTableView for messages*/
    open var messengerNode:ASTableNode = ASTableNode()
    /** Holds a state for the amount of content and if the messenger is fetching or not */
    fileprivate var state: NMessengerState = .initialState
    /** Used internally to prevent unwrapping for every usage*/
    fileprivate var messengerDelegate: NMessengerDelegate {
        get {
            if let delegate = delegate {
                return delegate
            } else {
                fatalError("delegate not implemented")
            }
        }
    }
    /** Gets a generic loading indicator */
    fileprivate var standardLoadingIndicator: GeneralMessengerCell {
        get {
            return HeadLoadingIndicator()
        }
    }
    
    //MARK: Public variables
    
    /**Delegate*/
    open weak var delegate: NMessengerDelegate?
    /**Triggers the delegate batch fetch function when NMessenger determines a batch fetch is needed. Defaults to true. **Note** *batchFetchContent()* must also be implemented */
    open var doesBatchFetch: Bool = false
    
    //MARK: Initializers
    
    public init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    /** Creates the messenger tableview and sets defaults*/
    fileprivate func setupView() {
        
        self.messengerNode.view.keyboardDismissMode = .onDrag
        self.addSubview((messengerNode.view))
        
        messengerNode.delegate = self
        messengerNode.dataSource = self
        
        messengerNode.view.setTuningParameters(ASRangeTuningParameters(leadingBufferScreenfuls: 2, trailingBufferScreenfuls: 1), for: .display)
        
        messengerNode.view.separatorStyle = UITableViewCellSeparatorStyle.none
        messengerNode.view.allowsSelection = false
        messengerNode.view.showsVerticalScrollIndicator = false
        messengerNode.view.automaticallyAdjustsContentOffset = true
    }
    
    //MARK: Public functions
    
    /** Override layoutSubviews to update messenger table frame*/
    override open func layoutSubviews() {
        super.layoutSubviews()
        //update frame
        messengerNode.frame = self.bounds
        messengerNode.view.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    //MARK: Adding messages
    /**
     Adds a message to the messenger. (Fire and forget)
     - parameter message: Must be a GeneralMessengerCell
     - parameter scrollsToMessage: If marked true, the tableview will scroll to the newly added
     message
     */
    open func addMessage(_ message: GeneralMessengerCell, scrollsToMessage: Bool) {
         self.addMessages([message], scrollsToMessage: scrollsToMessage, withAnimation: .none)
    }
    
    /**
     Adds a message to the messenger. (Fire and forget)
     - parameter message: Must be a GeneralMessengerCell
     - parameter scrollsToMessage: If marked true, the tableview will scroll to the newly added
     message
     - parameter animation: An animation for newly added cell
     */
    open func addMessage(_ message: GeneralMessengerCell, scrollsToMessage: Bool, withAnimation animation: UITableViewRowAnimation) {
        self.addMessages([message], scrollsToMessage: scrollsToMessage, withAnimation: animation)
    }
    
    /**
     Adds an array of messages to the messenger. (Fire and forget)
     - parameter messages: An array of messages
     - parameter scrollsToMessage: If marked true, the tableview will scroll to the newly added
     message
     */
    open func addMessages(_ messages: [GeneralMessengerCell], scrollsToMessage: Bool) {
        self.waitForMessageLock {
            self.addMessages(messages, atIndex: self.state.itemCount, scrollsToMessage: scrollsToMessage, animation: .none, completion:  nil)
        }
    }
    
    /**
     Adds an array of messages to the messenger. (Fire and forget)
     - parameter messages: An array of messages
     - parameter scrollsToMessage: If marked true, the tableview will scroll to the newly added
     - parameter animation: An animation for newly added cell
     message
     */
    open func addMessages(_ messages: [GeneralMessengerCell], scrollsToMessage: Bool, withAnimation animation: UITableViewRowAnimation) {
        self.waitForMessageLock {
            self.addMessages(messages, atIndex: self.state.itemCount, scrollsToMessage: scrollsToMessage, animation: animation, completion:  nil)
        }
    }
    
    /**
     Adds an array of messages to the messenger.
     - parameter messages: An array of messages
     - parameter scrollsToMessage: If marked true, the tableview will scroll to the newly added
     - parameter animation: An animation for newly added cell
     message
     - parameter completion: A completion handler
     */
    open func addMessagesWithBlock(_ messages: [GeneralMessengerCell], scrollsToMessage: Bool, withAnimation animation: UITableViewRowAnimation, completion: (()->Void)?) {
        self.waitForMessageLock {
            self.addMessages(messages, atIndex: self.state.itemCount, scrollsToMessage: scrollsToMessage, animation: animation, completion:  completion)
        }
    }
    /**
     Adds batch fetched messages to the head of the messenger. This **MUST BE** called to end a batch fetch operation. (Fire and forget)
     If no data was received, use an empty array for messages. Calling this outside when a batch fetch has not
     been triggered will result in a NOOP
     
     - parameter messages: messages to add to the head of the tableview
     */
    open func endBatchFetchWithMessages(_ messages: [GeneralMessengerCell]) {
        //make sure we are in the process of a batch fetch
        if self.state.batchFetchLock.isFetching() {
            self.waitForMessageLock {
                self.removeCells(atIndexes: [IndexPath(row: 0, section: NMessengerSection.messenger.rawValue)], animation: .none, completion: {
                    self.addMessages(messages, atIndex: 0, scrollsToMessage: false, animation: .none, completion: {
                        self.state.batchFetchLock.completeBatchFetching(true)
                    })
                })
            }
        }
    }
    
    //MARK: Removing messages
    /**
     Clears all messages in the messenger. (Fire and forget)
     */
    open func clearALLMessages() {
        self.waitForMessageLock {
            DispatchQueue.main.async {
                let oldState = self.state
                self.state.itemCount = 0
                self.renderDiff(oldState, startIndex: 0, animation: .none, completion: {
                    //must decrement the semaphore
                    self.state.messageLock.signal()
                })
            }
        }
    }
    
    /**
     Removes a message from the messenger. This message must be the reference to the same object that was created. It is recommended that the controller does not hold a reference to these cells, but implement a delegate that references the cell when an action is taken on it. This will conserve memory. (Fire and forget)
     
     - parameter message: the message that should be deleted
     - parameter animation: a row animation for deleting the cell
     */
    open func removeMessage(_ message: GeneralMessengerCell, animation: UITableViewRowAnimation) {
        self.removeMessages([message], animation: animation)
    }
    
    /**
     Removes several messages from the messenger. This message must be the reference to the same object that was created. It is recommended that the controller does not hold a reference to these cells, but implement a delegate that references the cell when an action is taken on it. This will conserve memory. (Fire and forget)
     
     - parameter messages: the messages that should be deleted
     - parameter animation: a row animation for deleting the cell
     */
    open func removeMessages(_ messages: [GeneralMessengerCell], animation: UITableViewRowAnimation) {
        self.removeMessagesWithBlock(messages, animation: animation, completion: nil)
    }
    
    /**
     Removes several messages from the messenger. This message must be the reference to the same object that was created. It is recommended that the controller does not hold a reference to these cells, but implement a delegate that references the cell when an action is taken on it. This will conserve memory.
     
     - parameter messages: the messages that should be deleted
     - parameter animation: a row animation for deleting the cell
     */
    open func removeMessagesWithBlock(_ messages: [GeneralMessengerCell], animation: UITableViewRowAnimation, completion: (()->Void)?) {
        self.waitForMessageLock {
            DispatchQueue.main.async {
                var indexPaths = [IndexPath]()
                for message in messages {
                    if let indexPath = self.messengerNode.view.indexPath(for: message) {
                        indexPaths.append(indexPath)
                    }
                    //remove current table node
                    message.currentTableNode = nil
                }
                self.removeCells(atIndexes: indexPaths, animation: animation, completion: {
                    //unlock the semaphore
                    self.state.messageLock.signal()
                    completion?()
                })
            }
        }
    }
    
    //MARK: Scrolling
    /**
     Scrolls to the last message in the messenger. (Fire and forget)
     - parameter animated: The move is animated or not
     */
    open func scrollToLastMessage(animated: Bool) {
        waitForMessageLock {
            DispatchQueue.main.async {
                if let indexPath = self.pickLastIndexPath() {
                    self.scrollToIndex((indexPath as NSIndexPath).row, inSection: (indexPath as NSIndexPath).section, atPosition: .bottom, animated: animated)
                }
                //unlock the semaphore
                self.state.messageLock.signal()
            }
        }
    }
    
    /**
     Scrolls to the message in the messenger. Does nothing if the message does not exist. (Fire and forget)
     - parameter message: The message to scroll to
     - parameter atPosition: The location to scroll to
     - parameter animated: The move is animated or not
     */
    open func scrollToMessage(_ message: GeneralMessengerCell, atPosition position: UITableViewScrollPosition, animated: Bool) {
        waitForMessageLock {
            DispatchQueue.main.async {
                if let indexPath = self.messengerNode.view.indexPath(for: message) {
                    self.scrollToIndex((indexPath as NSIndexPath).row, inSection: (indexPath as NSIndexPath).section, atPosition: position, animated: animated)
                }
                //unlock the semaphore
                self.state.messageLock.signal()
            }
        }
    }
    
    //MARK: Typing Indicators
    /**
     Adds a typing indicator to the messenger
     - parameter indicator: the indicator to add
     - parameter scrollsToLast: should the messenger scroll to the bottom
     - parameter animated: If the scroll is animated
     */
    open func addTypingIndicator(_ indicator: GeneralMessengerCell, scrollsToLast: Bool, animated: Bool, completion: (()->Void)?) {
        waitForMessageLock {
            DispatchQueue.main.async {
                self.state.typingIndicators.append(indicator)
                let set = IndexSet(integer: NMessengerSection.typingIndicator.rawValue)
                CATransaction.begin()
                CATransaction.setCompletionBlock(completion)
                self.messengerNode.view.beginUpdates()
                self.messengerNode.view.reloadSections(set, with: .left)
                self.messengerNode.view.endUpdates(animated: true, completion: { (completed: Bool) -> Void in
                    if scrollsToLast {
                        if let indexPath = self.pickLastIndexPath() {
                            self.scrollToIndex((indexPath as NSIndexPath).row, inSection: (indexPath as NSIndexPath).section, atPosition: .bottom, animated: true)
                        }
                    }
                    //unlock the semaphore
                    self.state.messageLock.signal()
                })
                CATransaction.commit()
            }
        }
    }
    
    /**
     Removes a typing indicator to the messenger. NOP if typing indicator does not exist.
     - parameter indicator: the indicator to remove
     - parameter scrollsToLast: should the messenger scroll to the bottom
     - parameter animated: If the scroll is animated
     */
    open func removeTypingIndicator(_ indicator: GeneralMessengerCell, scrollsToLast: Bool, animated: Bool) {
        self.removeTypingIndicator(indicator, scrollsToLast: scrollsToLast, animated: animated, completion: nil)
    }
    
    /**
     Removes a typing indicator to the messenger. NOP if typing indicator does not exist.
     - parameter indicator: the indicator to remove
     - parameter scrollsToLast: should the messenger scroll to the bottom
     - parameter animated: If the scroll is animated
     */
    open func removeTypingIndicator(_ indicator: GeneralMessengerCell, scrollsToLast: Bool, animated: Bool, completion: (()->Void)?) {
        waitForMessageLock {
            DispatchQueue.main.async {
                if let index = self.state.typingIndicators.index(of: indicator){

                    self.state.typingIndicators.remove(at: index)
                    
                    let set = IndexSet(integer: NMessengerSection.typingIndicator.rawValue)
                    CATransaction.begin()
                    CATransaction.setCompletionBlock(completion)
                    self.messengerNode.view.beginUpdates()
                    self.messengerNode.view.reloadSections(set, with: .fade)
                    self.messengerNode.view.endUpdates(animated: true, completion: { (completed: Bool) -> Void in
                        if scrollsToLast {
                            if let indexPath = self.pickLastIndexPath() {
                                self.scrollToIndex((indexPath as NSIndexPath).row, inSection: (indexPath as NSIndexPath).section, atPosition: .bottom, animated: true)
                            }
                        }
                        //unlock the semaphore
                        self.state.messageLock.signal()
                    })
                    CATransaction.commit()
                }
            }
        }
    }
    
    /**
     - returns: true if the messenger contains the loading indicator
     */
    open func hasIndicator(_ indicator: GeneralMessengerCell) -> Bool {
        return self.state.typingIndicators.contains(indicator)
    }
    
    //MARK: Utility functions
    /**
     Checks for a message in the messenger. **Warning** this is very costly when there are many nodes in the messenger. **Note** This is not called during the message lock because of its potential use in an add/remove function. For accurate results, make sure this is not called while updating the messenger.
     
     - parameter message: A GeneralMessengerCell that could or could not exist in the messenger
     - returns: A Bool indicating whether or not the cell exists in the messenger
     */
    open func hasMessage(_ message: GeneralMessengerCell) -> Bool {
        let hasNode = (self.messengerNode.view.indexPath(for: message) != nil)
        return hasNode
    }
    
    /**
    Gets all messages in the messenger. **Warning** this is very costly when there are many nodes in the messenger. **Note** This is not called during the message lock because of its potential use in an add/remove function. For accurate results, make sure this is not called while updating the messenger.
     
     - returns: An array containing all of the messages in the messager. These are in order as they appear.
     */
    open func allMessages() -> [GeneralMessengerCell] {
        var retArray = [GeneralMessengerCell]()
        for index in 0..<self.state.itemCount {
            let indexPath = IndexPath(row: index, section: NMessengerSection.messenger.rawValue)
            if let message = self.messengerNode.view.nodeForRow(at: indexPath) as? GeneralMessengerCell {
                retArray.append(message)
            }
        }
        
        return retArray
    }
    
    //MARK: Private functions
    
    /**
     Waits for the messageLock(semaphore) to expire. **Warning** dispatch_semaphore_signal(self.messageLock) must be called
     after the block
     - parameter competion: called once the semaphore has expired
     */
    fileprivate func waitForMessageLock(_ completion: @escaping ()->Void) {
        //DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            
        DispatchQueue.global().async {
            _ = self.state.messageLock.wait(timeout: DispatchTime.distantFuture)
            completion()
        }
    }
    
    /**
     *We DO NOT wait for the semaphore here because of the possible change in state. Use waitForMessageLock before calling this.*
     
     Adds messages at a particular index. Updates *currentTableNode*
     - parameter messages: An array of messages
     -parameter index: an index in the tableview at which to start adding messages
     - parameter scrollsToMessage: If marked true, the tableview will scroll to the newly added
     message
     */
    fileprivate func addMessages(_ messages: [GeneralMessengerCell], atIndex index: Int, scrollsToMessage: Bool, animation: UITableViewRowAnimation, completion: (()->Void)?) {
        DispatchQueue.main.async {
            if messages.count > 0 {
                //set the new state
                let oldState = self.state
                self.state.itemCount += messages.count
                //add new cells to the buffer and set their start index
                self.state.cellBufferStartIndex = index
                self.state.cellBuffer = messages
                //set current table
                for message in messages {
                    message.currentTableNode = self.messengerNode
                }
                //render new cells
                self.renderDiff(oldState, startIndex: self.state.cellBufferStartIndex, animation: animation, completion: {
                    DispatchQueue.main.async {
                        //reset start index
                        self.state.cellBufferStartIndex = Int.max
                        self.state.cellBuffer = [GeneralMessengerCell]()
                        //scroll to the message
                        if scrollsToMessage {
                            if let indexPath = self.pickLastIndexPath() {
                                self.scrollToIndex((indexPath as NSIndexPath).row, inSection: (indexPath as NSIndexPath).section, atPosition: .bottom, animated: true)
                            }
                        }
                        //unlock the semaphore
                        self.state.messageLock.signal()
                        completion?()
                    }
                })
            } else {
                //unlock the semaphore
                self.state.messageLock.signal()
                completion?()
            }
        }
    }
    
    /**
     Picks the last index path in the messenger. Used when there are typing indicators in the messenger
     - returns: An NSIndexPath representing the last element
     */
    fileprivate func pickLastIndexPath()-> IndexPath? {
        
        if self.state.typingIndicators.isEmpty { //if there are no tying indicators
            let lastMessage = self.state.itemCount-1
            if lastMessage >= 0 {
                return IndexPath(item: lastMessage, section: NMessengerSection.messenger.rawValue)
            }
        } else {
            return IndexPath(item: self.state.typingIndicators.count - 1, section: NMessengerSection.typingIndicator.rawValue)
        }
        return nil
    }
    
    /**
     Helper function to scroll to the index, section
     - parameter index: an index to scroll to
     - parameter section: a section for the index
     - parameter position: a position to scroll to
     - parameter animated: bool indicating if the scroll should be animated
     */
    fileprivate func scrollToIndex(_ index: Int, inSection section: Int, atPosition position: UITableViewScrollPosition, animated: Bool) {
        let indexPath = (IndexPath(row: index, section: section))
        self.messengerNode.view.scrollToRow(at: indexPath, at: position, animated: animated)
    }
    
    /**
     Determines if a batch fetch can occur, then calls batchFetchDataInBackground.
     Offest is from the top of the messengerNode ASTableView
     - parameter offset: the offset from the top of the scrollview
     */
    fileprivate func shouldHandleBatchFetch(_ offset: CGPoint) {
        if doesBatchFetch && self.messengerDelegate.batchFetchContent != nil {
            if shouldBatchFetch(self.state.batchFetchLock, direction: self.state.scrollDirection, bounds: messengerNode.view.bounds, contentSize: messengerNode.view.contentSize, targetOffset: offset, leadingScreens: messengerNode.view.leadingScreensForBatching) {
                
                //lock and fetch
                self.state.batchFetchLock.beginBatchFetching()
                self.batchFetchDataInBackground()
            }
        }
    }
    
    /**
     Triggers a batch fetch on a background thread.
     */
    fileprivate func batchFetchDataInBackground() {
        waitForMessageLock {
            //add a loading spinner to the top
            if let loadingIndicator = self.messengerDelegate.batchFetchLoadingIndicator?() { //if delegate method
                self.addMessages([loadingIndicator], atIndex: 0, scrollsToMessage: false, animation: .none, completion: nil)
            } else { //standard nmessenger indicator
                self.addMessages([self.standardLoadingIndicator], atIndex: 0, scrollsToMessage: false, animation: .none, completion: nil)
            }
        }
        
        //run this on a background thread
        DispatchQueue.global().async {
            self.messengerDelegate.batchFetchContent?()
        }
        
        
        //DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
        //    self.messengerDelegate.batchFetchContent?()
        //}
    }
    
    /**
     *We DO NOT wait for the semaphore here because of the possible change in state. Use waitForMessageLock before calling this.*
     
     Removes a cell at an index in the tableview
     - parameter indexes: indexes to remove the cells
     - parameter animation: an animation to remove the cells
     - parameter completion: closure to signify the end of the remove event
     */
    fileprivate func removeCells(atIndexes indexes: [IndexPath], animation: UITableViewRowAnimation, completion: (()->Void)?) {
        DispatchQueue.main.async {
            //update the state
            self.state.itemCount -= indexes.count
            
            //remove rows
            let tableView = self.messengerNode.view
            tableView?.beginUpdates()
            tableView?.deleteRows(at: indexes, with: animation)
            
            //done animating
            let animated = animation != .none
            tableView.endUpdates(animated: animated) { (success) in
                completion?()
            }
        }
    }
    
    /**
     Adds or removes cells for newly added messages. Make sure that there is enough data in the cell
     buffer, or the messenger will crash. Works by comparing the old state to the current state.
     - parameter oldState: The previous state
     - parameter startIndex: Where to insert or delete the cells
     - parameter completion: Closure which notifies that the table is done adding cells
     */
    fileprivate func renderDiff(_ oldState: NMessengerState, startIndex: Int, animation: UITableViewRowAnimation, completion: (()->Void)?) {
        let tableView = messengerNode.view
        tableView.beginUpdates()
        
        // Add or remove items
        let rowCountChange = state.itemCount - oldState.itemCount
        if rowCountChange > 0 {
            let indexPaths = (startIndex..<startIndex + rowCountChange).map { index in
                IndexPath(row: index, section: NMessengerSection.messenger.rawValue)
            }
            tableView.insertRows(at: indexPaths, with: animation)
        } else if rowCountChange < 0 {
            let indexPaths = (startIndex..<startIndex - rowCountChange).map { index in
                IndexPath(row: index, section: NMessengerSection.messenger.rawValue)
            }
            tableView.deleteRows(at: indexPaths, with: animation)
        }
        
        //done animating
        let animated = animation != .none
        tableView.endUpdates(animated: animated) { (success) in
            completion?()
        }
    }
    
    /**
     Checks if a batch fetch should occur. Slightly modified from FB code to
     */
    fileprivate func shouldBatchFetch(_ context: ASBatchContext, direction: ASScrollDirection, bounds: CGRect, contentSize: CGSize, targetOffset: CGPoint, leadingScreens: CGFloat) -> Bool {
        
        if context.isFetching() {
            return false
        }
        
        if direction != .up {
            return false
        }
        
        if leadingScreens <= 0 || bounds.equalTo(CGRect.zero) {
            return false
        }
        
        let viewLength = bounds.size.height;
        let offset = contentSize.height - targetOffset.y;
        let contentLength = contentSize.height;
        //TODO: should we not load when the content is smaller than the screen?
       // let smallContent = (offset == 0) && (contentLength < viewLength)
        let smallContent = (contentLength < viewLength)
        let triggerDistance = viewLength * leadingScreens
        
        let remainingDistance = contentLength - viewLength - offset
        
       // return smallContent || remainingDistance <= triggerDistance
        return !smallContent && remainingDistance <= triggerDistance
    }
}

//MARK: Message Groups
extension NMessenger {
    /**
     Adds content to the end of a message group. (fire and forget)
     - parameter message: The message to add to the messenger group
     - parameter messageGroup: A message group that must exist in the messenger
     - parameter scrollsToLastMessage: A that indicates whether the tableview should scroll to the last message in the group
     - paramter toPosition: the position to scroll to
     */
    public func addMessageToMessageGroup(_ message: GeneralMessengerCell, messageGroup: MessageGroup, scrollsToLastMessage: Bool) {
        self.addMessageToMessageGroup(message, messageGroup: messageGroup, scrollsToLastMessage: scrollsToLastMessage,  completion: nil)
    }
    
    /**
     Adds content to the end of a message group.
     - parameter message: The message to add to the messenger group
     - parameter messageGroup: A message group that must exist in the messenger
     - parameter scrollsToLastMessage: A that indicates whether the tableview should scroll to the last message in the group
     - paramter toPosition: the position to scroll to
     - parameter completion: a block to be called after the content has been added
     */
    public func addMessageToMessageGroup(_ message: GeneralMessengerCell, messageGroup: MessageGroup, scrollsToLastMessage: Bool, completion: (()->Void)?) {
        messageGroup.addMessageToGroup(message, completion: {
                if scrollsToLastMessage {
                    self.scrollToLastMessage(animated: true)
                }
                completion?()
            })
    }
    
    /**
     Adds content to the end of a message group.
     - parameter message: The message to add to the messenger group
     - parameter messageGroup: A message group that must exist in the messenger
     - parameter scrollsToMessage: A that indicates whether the tableview should scroll to the last message in the group
     - paramter toPosition: the position to scroll to
     - parameter completion: a block to be called after the content has been added
     */
    public func addMessageToMessageGroup(_ message: GeneralMessengerCell, messageGroup: MessageGroup, scrollsToMessage: Bool, toPosition position: UITableViewScrollPosition?, completion: (()->Void)?) {
         messageGroup.addMessageToGroup(message, completion: {
            if scrollsToMessage {
                if let position = position {
                    self.scrollToMessage(messageGroup, atPosition: position, animated: true)
                } else {
                    self.scrollToMessage(messageGroup, atPosition: .bottom, animated: true)
                }
            }
            
            completion?()
        })
    }
    
    /**
     Removes content from a message group. (fire and forget)
     - parameter message: The message to remove from the messenger group
     - parameter messageGroup: A message group that must exist in the messenger
     - parameter scrollsToLastMessage: A that indicates whether the tableview should scroll to the last message in the group
     - paramter toPosition: the position to scroll to
     */
    public func removeMessageFromMessageGroup(_ message: GeneralMessengerCell, messageGroup: MessageGroup, scrollsToLastMessage: Bool, toPosition position: UITableViewScrollPosition?) {
        self.removeMessageFromMessageGroup(message, messageGroup: messageGroup, scrollsToLastMessage: scrollsToLastMessage, toPosition: position, completion: nil)
    }
    
    /**
     Removes content from a message group. (fire and forget)
     - parameter message: The message to remove from the messenger group
     - parameter messageGroup: A message group that must exist in the messenger
     - parameter scrollsToLastMessage: A that indicates whether the tableview should scroll to the last message in the group
     - paramter toPosition: the position to scroll to
     - parameter completion: a block to be called after the content has been removed
     */
    public func removeMessageFromMessageGroup(_ message: GeneralMessengerCell, messageGroup: MessageGroup, scrollsToLastMessage: Bool, toPosition position: UITableViewScrollPosition?, completion: (()->Void)?) {
        
        //If it is the last message, remove it
        if self.hasMessage(messageGroup) {
            if messageGroup.messages.count == 1 && messageGroup.messages.first == message {
                let animation = messageGroup.isIncomingMessage ? UITableViewRowAnimation.left : UITableViewRowAnimation.right
                self.removeMessagesWithBlock([messageGroup], animation: animation, completion: { 
                    completion?()
                })
                return
            }
        }
        
        //otherwise delete it from the group
        messageGroup.removeMessageFromGroup(message, completion: {
            if scrollsToLastMessage {
                if let position = position {
                    self.scrollToMessage(messageGroup, atPosition: position, animated: true)
                } else {
                    self.scrollToMessage(messageGroup, atPosition: .bottom, animated: true)
                }
            }
            completion?()
        })
    }
}

//MARK: ASTableView Delegates/DataSource
extension NMessenger: ASTableViewDelegate, ASTableViewDataSource {
    
    //MARK: footer
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == NMessengerSection.messenger.rawValue {
            return 5
        }
        
        return 0
    }
    
    //MARK: header
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == NMessengerSection.messenger.rawValue {
            return 5
        }
        
        return 0
    }
    
    //MARK: ASTableNode
    public func shouldBatchFetch(for tableView: ASTableView) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: ASTableView, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        
        switch (indexPath as NSIndexPath).section {
        case NMessengerSection.messenger.rawValue:
            if (indexPath as NSIndexPath).row >= self.state.cellBufferStartIndex {
                return self.state.cellBuffer[(indexPath as NSIndexPath).row - self.state.cellBufferStartIndex]
            }
            return tableView.nodeForRow(at: indexPath)!
        case NMessengerSection.typingIndicator.rawValue:
            return self.state.typingIndicators[(indexPath as NSIndexPath).row]
        default: //should never come here
            return ASCellNode()
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.state.itemCount
        } else {
            return self.state.typingIndicators.count
        }
    }
    
    
    //MARK: TableView Scroll
    /**
     When this is triggered, we decide if a prefetch is needed
     */
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //if targetContentOffset != nil {
            shouldHandleBatchFetch((targetContentOffset.pointee))
        //}
    }
    
    /*public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>?) {
        if targetContentOffset != nil {
            shouldHandleBatchFetch((targetContentOffset?.pointee)!)
        }
    }*/
    
    /**
     Keeps track of the current scroll direction. This state can be obtained
     by accessing the scrollDirection property
     */
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //is scrolling down
        if self.state.lastContentOffset < scrollView.contentOffset.y {
            self.state.scrollDirection = .down
        }
            //is scrolling up
        else if self.state.lastContentOffset > scrollView.contentOffset.y {
            self.state.scrollDirection = .up
        }
        
        //set to compare against next scroll action
        self.state.lastContentOffset = scrollView.contentOffset.y;
    }
}
