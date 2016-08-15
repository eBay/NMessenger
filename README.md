# ![./NMessenger](https://github.com/eBay/NMessenger/blob/master/Assets/nmessenger.png)
[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/eBay/NMessenger/blob/master/LICENSE)

NMessenger is a fast, lightweight messenger component built on [AsyncDisplaykit](https://github.com/facebook/AsyncDisplayKit) and written in [Swift](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/). Developers can inherently achieve 60FPS scrolling and smooth transitions with rich content components.

<p align="center">
  <img src="https://github.com/eBay/NMessenger/blob/master/Assets/NMessenger-Overview.png" alt="NMessenger" width="300"/>
</p>

## Features

Built-in support for:
- [Text](https://github.com/eBay/NMessenger#posting-messages)
- [Images (network and local)](https://github.com/eBay/NMessenger#posting-messages)
- [Collection Views](https://github.com/eBay/NMessenger#posting-messages)
- [Rich Content](https://github.com/eBay/NMessenger#posting-messages)
- [Typing Indicators](https://github.com/eBay/NMessenger#typing-indicators)
- [Avatars](https://github.com/eBay/NMessenger#avatars)
- [Custom and Layer Masked Bubbles](https://github.com/eBay/NMessenger#message-bubbles)
- [Bubble Configurations](https://github.com/eBay/NMessenger#bubble-configuration)
- [Extendable Components](https://github.com/eBay/NMessenger#content-nodes-and-custom-components)
- [Async Head Prefetching](https://github.com/eBay/NMessenger#head-prefetching)
- [Message Groups](https://github.com/eBay/NMessenger#message-groups)
- [Adding, Removing, and Updating Messages (with animations)](https://github.com/eBay/NMessenger#adding-removing-and-updating)

## Version Information
* 1.0.0

## Requirements
* iOS 8.2+

## Installation for Cocoapods(https://cocoapods.org)

In the NMessenger directory
```
# For latest release in cocoapods
pod 'NMessenger'
```
Open `nMessenger.xcworkspace` 


## Getting Started

### NMessengerViewController
NMessenger comes with a prebuilt NMessengerViewController that has a few supported features.
- Posting messages
- Input bar with a custom placeholder
- Camera and photo library access
- Typing indicator support


#### Posting Messages
Send a text message.
```
func sendText(text: String, isIncomingMessage:Bool) -> GeneralMessengerCell
```
<p align="center">
<img src="https://github.com/eBay/NMessenger/blob/master/Assets/Text-Message.png" alt="Text Message" width="400"/>
</p>
---

Send a message with an image.
```
func sendImage(image: UIImage, isIncomingMessage:Bool) -> GeneralMessengerCell
```
Send a message with a network image. (Uses AsyncDisplayKit with PINCache to lazyload and cache network images)
```
func sendNetworkImage(imageURL: String, isIncomingMessage:Bool) -> GeneralMessengerCell
```
<p align="center">
<img src="https://github.com/eBay/NMessenger/blob/master/Assets/Image-Message.png" alt="Image Message" width="400"/>
</p>
---

A message with a collection view can be created directly from an array of views or nodes. *Note: Nodes take advantage of ASDK's async rendering capabilities and will make this component scroll more smoothly.*

```
func sendCollectionViewWithViews(views: [UIView], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell
func sendCollectionViewWithNodes(nodes: [ASDisplayNode], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell
```

One line CollectionView

<p align="center">
<img src="https://github.com/eBay/NMessenger/blob/master/Assets/CollectionSingle-Message.png" alt="One line CollectionView" width="400"/>
</p>

Multi line CollectionView

<p align="center">
<img src="https://github.com/eBay/NMessenger/blob/master/Assets/CollectionMulti-Message.png" alt="Multi line CollectionView" width="400"/>
</p>
---

Send a message with a custom view or node. *Note: Nodes take advantage of ASDK's async rendering capabilities and will make this component scroll more smoothly.*

```
func sendCustomView(view: UIView, isIncomingMessage:Bool) -> GeneralMessengerCell
func sendCustomNode(node: ASDisplayNode, isIncomingMessage:Bool) -> GeneralMessengerCell
```
<p align="center">
<img src="https://github.com/eBay/NMessenger/blob/master/Assets/Custom-Message.png" alt="Custom Message" width="400"/>
</p>

These functions are meant to be overridden for network calls and other controller logic.

#### Typing Indicators
Typing indicators signify that incoming messages are being typed. This will be the last message in the messenger by default.
```
/** Adds an incoming typing indicator to the messenger */
func showTypingIndicator(avatar: ASDisplayNode) -> GeneralMessengerCell

/** Removes a typing indicator from the messenger */
func removeTypingIndicator(indicator: GeneralMessengerCell)
```
<p align="center">
<img src="https://github.com/eBay/NMessenger/blob/master/Assets/TypingIndicator.png" alt="Typing Indicator" width="400"/>
</p>

### NMessenger

NMessenger can be added to any view. 
```
self.messengerView = NMessenger(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
messengerView.delegate = self
self.view.addSubview(self.messengerView)
```
With NMessenger, there is no need to manage a data source. Simply add a message and forget about it.

Changing and updating a message relies on a reference. These references can be passed through a delegate method or stored locally in a class. 

```
self.delegate.deleteMessageBtnClick(self)
.
.
.
func deleteMessageBtnClick(message: GeneralMessageCell) {
  self.messengerView.removeMessage(message, .None)
}
```

### Message Bubbles
NMessenger comes with a few prebuilt bubble types. `bubble` can also easily be subclassed to create a new bubble component. 

`SimpleBubble`

<img src="https://github.com/eBay/NMessenger/blob/master/Assets/SimpleBubble.png" alt="Simple Bubble" width="200"/>

`DefaultBubble`

<img src="https://github.com/eBay/NMessenger/blob/master/Assets/DefaultBubble.png" alt="Default Bubble" width="200"/>

`StackedBubble`

<img src="https://github.com/eBay/NMessenger/blob/master/Assets/StackedBubble.png" alt="Stacked Bubble" width="200"/>

`ImageBubble` - Can be used with any [9 Patch Image](https://github.com/chrislondon/9-Patch-Image-for-Websites/wiki/What-Are-9-Patch-Images)

<img src="https://github.com/eBay/NMessenger/blob/master/Assets/ImageBubble.png" alt="Image Bubble" width="200"/>

By setting `hasLayerMask = true`, bubbles will mask their content. This is relevant for images and other rich content components. 

### Bubble Configuration
In order to configure custom bubbles for the messenger, you must create a new class that implements `BubbleConfigurationProtocol`.
```
/** Configures a bubble for a ContentNode. Implement this to create your own bubble configuration */
protocol BubbleConfigurationProtocol {
    var isMasked: Bool {get set}
    
    /** Create and return a UI color representing an incoming message */
    func getIncomingColor() -> UIColor
    
    /** Create and return a UI color representing an outgoing message */
    func getOutgoingColor() -> UIColor
    
    /** Create and return a bubble for the ContentNode */
    func getBubble() -> Bubble
    
    /** Create and return a bubble that is used by the Message group for Message nodes after the first. This is typically used to "stack" messages */
    func getSecondaryBubble() -> Bubble
}
```
This protocol is meant to provide a new instance of the bubble class for primary (messageNode) and secondary (messageGroup) bubble types. By changing `var sharedBubbleConfiguration: BubbleConfigurationProtocol` in `NMessengerViewController`, you can set the configuration for all newly added messages. 

### Content Nodes and Custom Components
#### Content Nodes
A Content Node holds message content in a `MessageNode` (everything inside of the bubble).

<p align="center">
  <img src="https://github.com/eBay/NMessenger/blob/master/Assets/ContentNode.png" alt="Content Node" width="500"/>
</p>

Subclassing `ContentNode` gives you the ability to define your own content. This is particularly useful for creating rich content components that are not in our stock message kit. Alternatively, you can initialize a 'CustomContentNode' with your own view or node. 

Content Nodes can also be given a `BubbleConfigurationProtocol` to customize their bubble. 

#### GeneralMessengerCell
`GeneralMessengerCell` can be subclassed to make any type of component. All messenger cells extend this object.


### Avatars
Custom avatars can be set with an AsyncDisplayKit `ASImageNode`.

```
let nAvatar = ASImageNode()
nAvatar.image = UIImage(named: "nAvatar")
.
.
.
messageNode.avatarNode = nAvatar
```

### Head Prefetching
Many messengers prefetch at the head. This is not trivial with a UITableView or AysncDisplayKit features. NMessenger supports head prefetching out of the box.

To use the head prefetch feature, set `var doesBatchFetch: Bool = true` on NMessenger. NMessengerDelegate will also need to be implemented and set by your controller.

```
@objc protocol NMessengerDelegate {
    /**
     Triggered when a load batch content should be called. This method is called on a background thread.
     Make sure to add prefetched content with *endBatchFetchWithMessages(messages: [GeneralMessengerCell])**/
    optional func batchFetchContent()
    /** Returns a newly created loading Indicator that should be used at the top of the messenger */
    optional func batchFetchLoadingIndicator()->GeneralMessengerCell
}
```

All batch fetch network calls should be done in `batchFetchContent`. Make sure to add your message cells with `endBatchFetchWithMessages(messages: [GeneralMessengerCell])` to end the batch fetch. Calling this function will remove the loading indicator and batch fetch lock.

### Message Groups
Message Groups can be used to stack messages and animate avatars. Like `MessageNode`, `MessageGroup` extends `GeneralMessageCell`. The difference, however is that `MessageGroup` holds a table of `MessageNode`s rather than a `ContentNode`.
```
================
| MessageGroup | -> ===============    ===============
================    | MessageNode | -> | ContentNode | (Primary Bubble)
                    ---------------    ===============
                    | MessageNode | -> | ContentNode | (Secondary Bubble)
                    ---------------    ===============
                    | MessageNode | -> | ContentNode | (Secondary Bubble)
                    ---------------    ===============
                    | MessageNode | -> | ContentNode | (Secondary Bubble)
                    ===============    ===============
```
Additionally, `MessageGroup` determines the bubble type of the `MessageNode`'s content based on the position in the table. The first message's content will have a primary bubble, the rest will have a secondary bubble. Typically, the avatar will be disabled on any `MessagesNode` in the group, but kept for the `MessageGroup`.

<p align="center">
  <img src="https://github.com/eBay/NMessenger/blob/master/Assets/MessageGroup.png" alt="Message Group" width="300"/>
</p>

#### Adding, Removing, and Updating

Message Groups include a few slick animations for Adding, Removing, and Updating MessageNodes in the group. These can be called directly from `MessageGroup` or Added and Removed from `NMessenger`. *Note: These are not surfaced in the `NMessengerViewController` yet*

It is recommended that they are removed from `NMessenger` because of the possibility that the `MessageNode` removed was the last message in the group. If this happens, the `MessageGroup` will remain after the `MessageGroup` was removed. `NMessenger` makes sure that in this case the `MessageGroup` is removed from the messenger.

##### Adding
To add a `MessageNode`. 
```
messageGroup.addMessageToGroup(message: GeneralMessengerCell, completion: (()->Void)?)
```
<p align="center">
  <img src="https://github.com/eBay/NMessenger/blob/master/Assets/Mg-Add.gif" alt="Message Group Add Animation" width="200"/>
</p>

##### Removing
To remove a `MessageNode`.
```
messageGroup.replaceMessage(message: GeneralMessengerCell, withMessage newMessage: GeneralMessengerCell, completion: (()->Void)?)
```
<p align="center">
  <img src="https://github.com/eBay/NMessenger/blob/master/Assets/Mg-Delete.gif" alt="Message Group Remove Animation" width="200"/>
</p>

##### Updating
To update an existing `MessageNode` with a new `MessageNode`.
```
messageGroup.removeMessageFromGroup(message: GeneralMessengerCell, completion: (()->Void)?)
```
<p align="center">
<img src="https://github.com/eBay/NMessenger/blob/master/Assets/Mg-Replace.gif" alt="Message Group Update Animation" width="200"/>
</p>

## Authors
- Aaron Tainter
- David Schechter
