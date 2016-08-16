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
import AVFoundation
import Photos

//MARK: InputBarView
/**
 InputBarView class for NMessaenger.
 Define the input bar for NMessaenger. This is where the user would type text and open the camera or photo library.
 */
public class InputBarView: UIView,UITextViewDelegate,CameraViewDelegate {
    
    //MARK: IBOutlets
    //@IBOutlet for InputBarView
    @IBOutlet public var InputBarView: UIView!
    //@IBOutlets for input area view
    @IBOutlet public weak var textInputAreaView: UIView!
    //@IBOutlets for input view
    @IBOutlet public weak var textInputView: UITextView!
    //@IBOutlet for send button
    @IBOutlet public weak var sendButton: UIButton!
    //@IBOutlets NSLayoutConstraint input area view height
    @IBOutlet public weak var textInputAreaViewHeight: NSLayoutConstraint!
    //@IBOutlets NSLayoutConstraint input view height
    @IBOutlet public weak var textInputViewHeight: NSLayoutConstraint!
    
    //MARK: Public Parameters
    //Rerrence to CameraViewController
    public lazy var cameraVC: CameraViewController = CameraViewController()
    //CGFloat to the fine the number of rows a user can type
    public var numberOfRows:CGFloat = 3
    //String as placeholder text in input view
    public var inputTextViewPlaceholder: String = "NMessenger"
    {
        willSet(newVal)
        {
            self.textInputView.text = newVal
        }
    }
    
    //MARK: Private Parameters
    //CGFloat as defualt height for input view
    private let textInputViewHeightConst:CGFloat = 30
    //NMessengerViewController where to input is sent to
    private var controller:NMessengerViewController = NMessengerViewController()
    
    // MARK: Initialisers
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     Calls helper methond to setup the view
     */
    public init(controller:NMessengerViewController) {
        super.init(frame: CGRectZero)
        self.controller = controller
        loadFromBundle()
    }
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     - parameter controller: Must be CGRect. Sets frame for the view.
     Calls helper methond to setup the view
     */
    public init(controller:NMessengerViewController,frame: CGRect) {
        super.init(frame: frame)
        self.controller = controller
        loadFromBundle()
    }
    /**
     - parameter aDecoder: Must be NSCoder
     Calls helper methond to setup the view
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromBundle()
    }
    
    // MARK: Initialiser helper methods
    /**
     Loads the view from nib file InputBarView and does intial setup.
     */
    private func loadFromBundle() {
        NSBundle.mainBundle().loadNibNamed("InputBarView", owner: self, options: nil)[0] as! UIView
        self.addSubview(InputBarView)
        InputBarView.frame = self.bounds
        textInputView.delegate = self
        self.sendButton.enabled = false
        cameraVC.cameraDelegate = self

    }
    
    //MARK: TextView delegate methods
    
    /**
     Implementing textViewShouldBeginEditing in order to set the text indictor at position 0
     */
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.text = ""
        textView.textColor = UIColor.n1DarkestGreyColor()
        UIView.animateWithDuration(0.1) {
            self.sendButton.enabled = true
        }
        dispatch_async(dispatch_get_main_queue(), {
            textView.selectedRange = NSMakeRange(0, 0)
        });
        return true
    }
    /**
     Implementing textViewShouldEndEditing in order to re-add placeholder and hiding send button when lost focus
    */
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if self.textInputView.text.isEmpty {
            self.addInputSelectorPlaceholder()
        }
        UIView.animateWithDuration(0.1) {
            self.sendButton.enabled = false
        }
        self.textInputView.resignFirstResponder()
        return true
    }
    /**
     Implementing shouldChangeTextInRange in order to remove placeholder when user starts typing and to show send button
     Re-sizing the text area to default values when the return button is tapped
     Limit the amount of rows a user can write to the value of numberOfRows
    */
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView.text == "" && (text != "\n")
        {
            UIView.animateWithDuration(0.1) {
                self.sendButton.enabled = true
            }
            return true
        }
        else if (text == "\n") && textView.text != ""{
            if textView == self.textInputView {
                textInputViewHeight.constant = textInputViewHeightConst
                textInputAreaViewHeight.constant = textInputViewHeightConst+10
                self.controller.sendText(self.textInputView.text,isIncomingMessage: false)
                self.textInputView.text = ""
                return false
            }
        }
        else if (text != "\n")
        {
            
            let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
            
            var textWidth: CGFloat = CGRectGetWidth(UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset))
            
            textWidth -= 2.0 * textView.textContainer.lineFragmentPadding
            
            let boundingRect: CGRect = newText.boundingRectWithSize(CGSizeMake(textWidth, 0), options: [NSStringDrawingOptions.UsesLineFragmentOrigin,NSStringDrawingOptions.UsesFontLeading], attributes: [NSFontAttributeName: textView.font!], context: nil)
            
            let numberOfLines = CGRectGetHeight(boundingRect) / textView.font!.lineHeight;
            
            
            return numberOfLines <= numberOfRows
        }
        return false
    }
    /**
     Implementing textViewDidChange in order to resize the text input area
     */
    public func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        textInputViewHeight.constant = newFrame.size.height
        
        textInputAreaViewHeight.constant = newFrame.size.height+10
        
        
        
    }
    
    //MARK: TextView helper methods
    /**
     Adds placeholder text and change the color of textInputView
     */
    private func addInputSelectorPlaceholder() {
        self.textInputView.text = self.inputTextViewPlaceholder
        self.textInputView.textColor = UIColor.lightGrayColor()
    }
    
    //MARK: @IBAction selectors
    /**
     Send button selector
     Sends the text in textInputView to the contoller
     */
    @IBAction public func sendButtonClicked(sender: AnyObject) {
        textInputViewHeight.constant = textInputViewHeightConst
        textInputAreaViewHeight.constant = textInputViewHeightConst+10
        if self.textInputView.text != ""
        {
            self.controller.sendText(self.textInputView.text,isIncomingMessage: false)
            self.textInputView.text = ""
        }
    }
    /**
     Plus button selector
     Requests camera and photo library permission if needed
     Open camera and/or photo library to take/select a photo
     */
    @IBAction public func plusClicked(sender: AnyObject?) {
        let authStatus = cameraVC.cameraAuthStatus
        let photoLibAuthStatus = cameraVC.photoLibAuthStatus
        if(authStatus != AVAuthorizationStatus.Authorized) {
            cameraVC.isCameraPermissionGranted({(granted) in
                if(granted) {
                    self.cameraVC.cameraAuthStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.controller.presentViewController(self.cameraVC, animated: true, completion: nil)
                    })
                }
                else
                {
                    self.cameraVC.cameraAuthStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
                    if(photoLibAuthStatus != PHAuthorizationStatus.Authorized) {
                        self.cameraVC.requestPhotoLibraryPermissions({ (granted) in
                            if(granted) {
                                self.cameraVC.photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.controller.presentViewController(self.cameraVC, animated: true, completion:
                                        {
                                            ModalAlertUtilities.postGoToSettingToEnableCameraModal(fromController: self.cameraVC)
                                    })
                                })
                                
                            }
                            else
                            {
                                self.cameraVC.photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
                                ModalAlertUtilities.postGoToSettingToEnableCameraAndLibraryModal(fromController: self.controller)
                            }
                        })
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.controller.presentViewController(self.cameraVC, animated: true, completion: nil)
                        })
                    }
                }
            })
        } else {//also check if photo gallery permissions are granted
            self.cameraVC.cameraAuthStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.controller.presentViewController(self.cameraVC, animated: true, completion: nil)
            })
        }
    }
    
    
    //MARK: CameraView delegate methods
    /**
     Implemetning CameraView delegate method
     Close the CameraView and sends the image to the contoller
     */
    public func pickedImage(image: UIImage!) {
        self.cameraVC.dismissViewControllerAnimated(true, completion: nil)
        
        self.controller.sendImage(image,isIncomingMessage: false)
    }
    /**
     Implemetning CameraView delegate method
     Close the CameraView
     */
    public func cameraCancelSelection() {
        cameraVC.dismissViewControllerAnimated(true, completion: nil)
    }

}
