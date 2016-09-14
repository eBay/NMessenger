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
 InputBarView class for NMessenger.
 Define the input bar for NMessenger. This is where the user would type text and open the camera or photo library.
 */
open class NMessengerBarView: InputBarView,UITextViewDelegate,CameraViewDelegate {
    
    //MARK: IBOutlets
    //@IBOutlet for InputBarView
    @IBOutlet open var InputBarView: UIView!
    //@IBOutlet for send button
    @IBOutlet open weak var sendButton: UIButton!
    //@IBOutlets NSLayoutConstraint input area view height
    @IBOutlet open weak var textInputAreaViewHeight: NSLayoutConstraint!
    //@IBOutlets NSLayoutConstraint input view height
    @IBOutlet open weak var textInputViewHeight: NSLayoutConstraint!
    
    //MARK: Public Parameters
    //Rerrence to CameraViewController
    open lazy var cameraVC: CameraViewController = CameraViewController()
    //CGFloat to the fine the number of rows a user can type
    open var numberOfRows:CGFloat = 3
    //String as placeholder text in input view
    open var inputTextViewPlaceholder: String = "NMessenger"
    {
        willSet(newVal)
        {
            self.textInputView.text = newVal
        }
    }
    
    //MARK: Private Parameters
    //CGFloat as defualt height for input view
    fileprivate let textInputViewHeightConst:CGFloat = 30
    
    // MARK: Initialisers
    /**
     Initialiser the view.
     */
    public required init() {
        super.init()
    }
    
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     Calls helper methond to setup the view
     */
    public required init(controller:NMessengerViewController) {
        super.init(controller: controller)
        loadFromBundle()
    }
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     - parameter controller: Must be CGRect. Sets frame for the view.
     Calls helper methond to setup the view
     */
    public required init(controller:NMessengerViewController,frame: CGRect) {
        super.init(controller: controller,frame: frame)
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
    fileprivate func loadFromBundle() {
        _ = Bundle(for: NMessengerViewController.self).loadNibNamed("NMessengerBarView", owner: self, options: nil)?[0] as! UIView
        self.addSubview(InputBarView)
        InputBarView.frame = self.bounds
        textInputView.delegate = self
        self.sendButton.isEnabled = false
        cameraVC.cameraDelegate = self

    }
    
    //MARK: TextView delegate methods
    
    /**
     Implementing textViewShouldBeginEditing in order to set the text indictor at position 0
     */
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        textView.textColor = UIColor.n1DarkestGreyColor()
        UIView.animate(withDuration: 0.1, animations: {
            self.sendButton.isEnabled = true
        }) 
        DispatchQueue.main.async(execute: {
            textView.selectedRange = NSMakeRange(0, 0)
        });
        return true
    }
    /**
     Implementing textViewShouldEndEditing in order to re-add placeholder and hiding send button when lost focus
    */
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if self.textInputView.text.isEmpty {
            self.addInputSelectorPlaceholder()
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.sendButton.isEnabled = false
        }) 
        self.textInputView.resignFirstResponder()
        return true
    }
    /**
     Implementing shouldChangeTextInRange in order to remove placeholder when user starts typing and to show send button
     Re-sizing the text area to default values when the return button is tapped
     Limit the amount of rows a user can write to the value of numberOfRows
    */
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == "" && (text != "\n")
        {
            UIView.animate(withDuration: 0.1, animations: {
                self.sendButton.isEnabled = true
            }) 
            return true
        }
        else if (text == "\n") && textView.text != ""{
            if textView == self.textInputView {
                textInputViewHeight.constant = textInputViewHeightConst
                textInputAreaViewHeight.constant = textInputViewHeightConst+10
                _ = self.controller.sendText(self.textInputView.text,isIncomingMessage: false)
                self.textInputView.text = ""
                return false
            }
        }
        else if (text != "\n")
        {
            
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            
            var textWidth: CGFloat = UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset).width
            
            textWidth -= 2.0 * textView.textContainer.lineFragmentPadding
            
            let boundingRect: CGRect = newText.boundingRect(with: CGSize(width: textWidth, height: 0), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], attributes: [NSFontAttributeName: textView.font!], context: nil)
            
            let numberOfLines = boundingRect.height / textView.font!.lineHeight;
            
            
            return numberOfLines <= numberOfRows
        }
        return false
    }
    /**
     Implementing textViewDidChange in order to resize the text input area
     */
    open func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        textInputViewHeight.constant = newFrame.size.height
        
        textInputAreaViewHeight.constant = newFrame.size.height+10
        
        
        
    }
    
    //MARK: TextView helper methods
    /**
     Adds placeholder text and change the color of textInputView
     */
    fileprivate func addInputSelectorPlaceholder() {
        self.textInputView.text = self.inputTextViewPlaceholder
        self.textInputView.textColor = UIColor.lightGray
    }
    
    //MARK: @IBAction selectors
    /**
     Send button selector
     Sends the text in textInputView to the controller
     */
    @IBAction open func sendButtonClicked(_ sender: AnyObject) {
        textInputViewHeight.constant = textInputViewHeightConst
        textInputAreaViewHeight.constant = textInputViewHeightConst+10
        if self.textInputView.text != ""
        {
            _ = self.controller.sendText(self.textInputView.text,isIncomingMessage: false)
            self.textInputView.text = ""
        }
    }
    /**
     Plus button selector
     Requests camera and photo library permission if needed
     Open camera and/or photo library to take/select a photo
     */
    @IBAction open func plusClicked(_ sender: AnyObject?) {
        let authStatus = cameraVC.cameraAuthStatus
        let photoLibAuthStatus = cameraVC.photoLibAuthStatus
        if(authStatus != AVAuthorizationStatus.authorized) {
            cameraVC.isCameraPermissionGranted({(granted) in
                if(granted) {
                    self.cameraVC.cameraAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.controller.present(self.cameraVC, animated: true, completion: nil)
                    })
                }
                else
                {
                    self.cameraVC.cameraAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                    if(photoLibAuthStatus != PHAuthorizationStatus.authorized) {
                        self.cameraVC.requestPhotoLibraryPermissions({ (granted) in
                            if(granted) {
                                self.cameraVC.photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
                                DispatchQueue.main.async(execute: { () -> Void in
                                    self.controller.present(self.cameraVC, animated: true, completion:
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
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.controller.present(self.cameraVC, animated: true, completion: nil)
                        })
                    }
                }
            })
        } else {//also check if photo gallery permissions are granted
            self.cameraVC.cameraAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            DispatchQueue.main.async(execute: { () -> Void in
                self.controller.present(self.cameraVC, animated: true, completion: nil)
            })
        }
    }
    
    
    //MARK: CameraView delegate methods
    /**
     Implemetning CameraView delegate method
     Close the CameraView and sends the image to the controller
     */
    open func pickedImage(_ image: UIImage!) {
        self.cameraVC.dismiss(animated: true, completion: nil)
        
        _ = self.controller.sendImage(image,isIncomingMessage: false)
    }
    /**
     Implemetning CameraView delegate method
     Close the CameraView
     */
    open func cameraCancelSelection() {
        cameraVC.dismiss(animated: true, completion: nil)
    }

}
