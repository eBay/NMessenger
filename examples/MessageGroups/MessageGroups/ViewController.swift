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
import NMessenger
import AsyncDisplayKit

class ViewController: NMessengerViewController {
    
    let segmentedControlPadding:CGFloat = 10
    let segmentedControlHeight: CGFloat = 30
    
    let senderSegmentedControl = UISegmentedControl(items: ["incoming", "outgoing"])
    
    private(set) var lastMessageGroup:MessageGroup? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderSegmentedControl.frame = CGRect(x: self.segmentedControlPadding, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.width-2*self.segmentedControlPadding, height: self.segmentedControlHeight)
        self.senderSegmentedControl.selectedSegmentIndex = 0
        self.navigationController?.view.addSubview(self.senderSegmentedControl)
        
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        
        //create a new text message
        let textContent = TextContentNode(textMessageString: text, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
        let newMessage = MessageNode(content: textContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        
        //add message to correct group
        if (self.senderSegmentedControl.selectedSegmentIndex == 0) { //incoming
            self.postText(newMessage, isIncomingMessage: true)
        } else { //outgoing
            self.postText(newMessage, isIncomingMessage: false)
        }
        
        return newMessage
    }
    
    //MARK: Helper Functions
    /**
     Posts a text to the correct message group. Creates a new message group *isIncomingMessage* is different than the last message group.
     - parameter message: The message to add
     - parameter isIncomingMessage: If the message is incoming or outgoing.
     */
    private func postText(_ message: MessageNode, isIncomingMessage: Bool) {
        if self.lastMessageGroup == nil || self.lastMessageGroup?.isIncomingMessage == !isIncomingMessage {
            self.lastMessageGroup = self.createMessageGroup()
            
            //add avatar if incoming message
            if isIncomingMessage {
                self.lastMessageGroup?.avatarNode = self.createAvatar()
            }
            
            self.lastMessageGroup!.isIncomingMessage = isIncomingMessage
            self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: false)
            self.messengerView.addMessage(self.lastMessageGroup!, scrollsToMessage: true, withAnimation: isIncomingMessage ? .left : .right)
            
        } else {
            self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: true)
        }
    }
    
    /** 
     Creates a new message group for *lastMessageGroup*
     -returns: MessageGroup
     */
    private func createMessageGroup()->MessageGroup {
        let newMessageGroup = MessageGroup()
        newMessageGroup.currentViewController = self
        newMessageGroup.cellPadding = self.messagePadding
        return newMessageGroup
    }
    
    /**
     Creates mock avatar with an AsyncDisplaykit *ASImageNode*.
     - returns: ASImageNode
     */
    private func createAvatar()->ASImageNode {
        let avatar = ASImageNode()
        avatar.backgroundColor = UIColor.lightGray
        avatar.preferredFrameSize = CGSize(width: 20, height: 20)
        avatar.layer.cornerRadius = 10
        return avatar
    }
}

