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
import Photos
import AVFoundation
//MARK: CameraViewController
/**
 CameraViewDelegate protocol for NMessenger.
 Defines methods to be implemented inorder to use the CameraViewController
 */
public protocol CameraViewDelegate {
    /**
     Should define behavior when a photo is selected
     */
    func pickedImage(_ image: UIImage!)
    /**
     Should define behavior cancel button is tapped
     */
    func cameraCancelSelection()
}
//MARK: SelectionType
/**
 SelectionType enum for NMessenger.
 Defines type of selection the user is making - camera of photo library
 */
public enum SelectionType {
    case camera
    case library
}
//MARK: CameraViewController
/**
 CameraViewController class for NMessenger.
 Defines the camera view for NMessenger. This is where the user will take photos or select them from the library.
 */
open class CameraViewController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Public Parameters
    //CameraViewDelegate that implemets the delegate methods
    open var cameraDelegate: CameraViewDelegate!
    //SelectionType type of selection the user is making  - defualt is camera
    open var selection = SelectionType.camera
    //AVAuthorizationStatus authorization status for the camera
    open var cameraAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
    //PHAuthorizationStatus authorization status for the library
    open var photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
    //MARK: Private Parameters
    //UIButton to change to gallery mode
    fileprivate var gallery: UIButton!
    //UIImageView image from the gallery
    fileprivate var galleryImage: UIImageView!
    //UIButton to take a photo
    fileprivate var capturePictureButton: UIButton!
    //UIButton to flip camera between front and back
    fileprivate var flipCamera:UIButton!
    //UIToolbar to hold buttons above the live camera view
    fileprivate var cameraToolbar: UIToolbar!
    //UIButton to enable/disable flash
    fileprivate var flashButton:UIButton!
    //CGFloat to define size for capture button
    fileprivate let captureButtonSize:CGFloat = 80
    //CGFloat to define size for buttons under the live camera view
    fileprivate let sideButtonSize:CGFloat = 50
    //CGFloat to define padding for bottom view
    fileprivate let bottomPadding:CGFloat = 40
    //Bool if user gave permission for the camera
    fileprivate let isCameraAvailable = UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) ||
        UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front)
    
    //MARK: View Lifecycle
    /**
     Ovreriding viewDidLoad to setup the controller
     Calls helper method
     */
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.allowsEditing = true
        self.delegate = self
        initView()
    }
    
    /**
     Ovreriding viewDidAppear to setup the camera view if there are permissions for the camera
     */
    override open func viewDidAppear(_ animated: Bool) {
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            if (self.sourceType == UIImagePickerControllerSourceType.camera) {
                orientCamera(flipCamera)
                setFlash(flashButton)
            }
        }
    }
    
    //MARK: View Lifecycle helper methods
    /**
     Initialise the view and request for permissions if necessary
     */
    fileprivate func initView() {
        //check if the camera is available
        if ((UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) && (cameraAuthStatus == AVAuthorizationStatus.authorized)){
            self.sourceType = UIImagePickerControllerSourceType.camera
            self.showsCameraControls = false
            self.selection = SelectionType.camera
            self.renderCameraElements()
            
        } else
            {
                self.cameraAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                if(photoLibAuthStatus != PHAuthorizationStatus.authorized) {
                    self.requestPhotoLibraryPermissions({ (granted) in
                        if(granted) {
                            self.sourceType = UIImagePickerControllerSourceType.photoLibrary
                            self.selection = SelectionType.library
                        }
                        else
                        {
                            self.photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
                            self.dismiss(animated: true, completion: {
                                let presentingViewController = self.cameraDelegate as! NMessengerViewController
                                ModalAlertUtilities.postGoToSettingToEnableLibraryModal(fromController: presentingViewController)
                            })
                        }
                    })
                }
                else
                {
                    self.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    self.selection = SelectionType.library
                }
            }
    }
    /**
     Adds all the buttons for the custom camera view
     */
    fileprivate func renderCameraElements() {
        addGalleryButton()
        //set gallery image thumbnail
        if(photoLibAuthStatus != PHAuthorizationStatus.authorized) {
            requestPhotoLibraryPermissions({ (granted) in
                if(granted) {
                    self.getGalleryThumbnail()
                }
                else
                {
                    self.photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
                    ModalAlertUtilities.postGoToSettingToEnableLibraryModal(fromController: self)
                }
            })
            
        } else {
            self.getGalleryThumbnail()
        }
        //CAPTURE BUTTON
        addCaptureButton()
        //FLIP CAMERA BUTTON
        addFlipCameraButton()
        //CAMERA TOOLBAR
        addCameraToolBar()
        //Flash Button
        addFlashButton()
        //ADD ELEMENTS TO SUBVIEW
        addCameraElements()
    }
    
    //MARK: Camera Button Elements
    /**
     Adds the gallery button for the custom camera view
     */
    fileprivate func addGalleryButton() {
        //GALLERY BUTTON
        gallery = UIButton(frame: CGRect(x: self.view.frame.width - sideButtonSize - bottomPadding, y: self.view.frame.height - sideButtonSize - bottomPadding, width: sideButtonSize, height: sideButtonSize))
        gallery.addTarget(self, action: #selector(CameraViewController.changePictureMode), for: UIControlEvents.touchUpInside)
        gallery.setImage(UIImage(named: "cameraRollIcon", in: Bundle(for: NMessengerViewController.self), compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
        gallery.tintColor = UIColor.white
        galleryImage = UIImageView(frame: gallery.frame)
        galleryImage.contentMode = UIViewContentMode.scaleAspectFill
        galleryImage.clipsToBounds = true
        galleryImage.isHidden = true
    }
    /**
     Adds the gallery thumbnail for the custom camera view
     */
    fileprivate func getGalleryThumbnail() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors =  [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        let lastAsset = fetchResult.lastObject as PHAsset!
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = PHImageRequestOptionsVersion.current
        PHImageManager.default().requestImage(for: lastAsset!, targetSize: self.galleryImage.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, info) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.galleryImage.image = image
            })
        }
    }
    /**
     Adds the capture button for the custom camera view
     */
    fileprivate func addCaptureButton() {
        
        //CAPTURE BUTTON
        capturePictureButton = UIButton(frame: CGRect(x: self.view.frame.width/2 - bottomPadding, y: self.view.frame.height - captureButtonSize - bottomPadding, width: captureButtonSize, height: captureButtonSize))
        capturePictureButton.setImage(UIImage(named: "shutterBtn", in: Bundle(for: NMessengerViewController.self), compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
        capturePictureButton.tintColor = UIColor.white
        
        //call the uiimagepickercontroller method takePicture()
        capturePictureButton.addTarget(self, action: #selector(CameraViewController.capture(_:)), for: UIControlEvents.touchUpInside)
        
    }
    /**
     Adds the flip button for the custom camera view
     */
    fileprivate func addFlipCameraButton() {
        //FLIP CAMERA BUTTON
        flipCamera = UIButton(frame: CGRect(x: bottomPadding, y: self.view.frame.height - sideButtonSize - bottomPadding, width: sideButtonSize, height: sideButtonSize))
        flipCamera.addTarget(self, action: #selector(CameraViewController.flipCamera(_:)), for: UIControlEvents.touchUpInside)
        flipCamera.setImage(UIImage(named: "flipCameraIcon", in: Bundle(for: NMessengerViewController.self), compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
        flipCamera.tintColor = UIColor.white
    }
    /**
     Adds the toolbar for the custom camera view
     */
    fileprivate func addCameraToolBar() {
        //CAMERA TOOLBAR
        cameraToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        cameraToolbar.barStyle = UIBarStyle.blackTranslucent
        cameraToolbar.isTranslucent = true
        let exitButton = UIButton(frame: CGRect(x: 20, y: 10, width: 40, height: 40))
        exitButton.setImage(UIImage(named: "exitIcon", in: Bundle(for: NMessengerViewController.self), compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
        exitButton.tintColor = UIColor.white
        exitButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        exitButton.addTarget(self, action: #selector(CameraViewController.exitButtonPressed), for: UIControlEvents.touchUpInside)
        cameraToolbar.addSubview(exitButton)
    }
    /**
     Adds the flash button for the custom camera view
     */
    open func addFlashButton() {
        //Flash Button
        flashButton = UIButton(frame: CGRect(x: self.view.frame.width - 60, y: 10, width: 40, height: 40))
        flashButton.setImage(UIImage(named: "flashIcon", in: Bundle(for: NMessengerViewController.self), compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
        flashButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flashButton.tintColor = UIColor.white
        flashButton.addTarget(self, action: #selector(CameraViewController.toggleFlash(_:)), for: UIControlEvents.touchUpInside)
        cameraToolbar.addSubview(flashButton)
    }
    
    //MARK: ImagePickerDelegate Methods
    /**
     Implementing didFinishPickingMediaWithInfo to send the selected image to the cameraDelegate
     */
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var myImage:UIImage? = nil
        
        if let tmpImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            myImage = tmpImage
        } else{
            print("Something went wrong")
        }
        
        if myImage == nil {
            if let tmpImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                myImage = tmpImage
            } else{
                print("Something went wrong")
            }
            //myImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            /* Correctly flip the mirrored image of front-facing camera */
            if self.cameraDevice == UIImagePickerControllerCameraDevice.front {
                if let im = myImage, let cgImage = im.cgImage {
                    myImage = UIImage(cgImage: cgImage, scale: im.scale, orientation: UIImageOrientation.leftMirrored)
                }
            }
        }
        
        if (cameraDelegate != nil) {
            cameraDelegate.pickedImage(myImage)
        }
    }
    /**
     Implementing imagePickerControllerDidCancel to go back to camera view or close the view
     */
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        switch selection {
        case .camera where !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) :
            cameraDelegate.cameraCancelSelection()
        case .library:
            changePictureMode()
        default:
            break
        }
    }
    
    //MARK: Selectors
    /**
     Changes between camera view and gallery view
     */
    open func changePictureMode() {
        
        switch selection {
        case .camera:
            selection = SelectionType.library
            removeCameraElements()
            self.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case .library where (isCameraAvailable &&  (cameraAuthStatus == AVAuthorizationStatus.authorized)):
            selection = SelectionType.camera
            addCameraElements()
            self.sourceType = UIImagePickerControllerSourceType.camera
            orientCamera(flipCamera)
            setFlash(flashButton)
        default:
            cameraDelegate.cameraCancelSelection()
        }
    }
    /**
     Adds buttons for the camera view
     */
    fileprivate func addCameraElements() {
        if (self.selection == SelectionType.camera) {
            self.view.addSubview(galleryImage)
            self.view.addSubview(gallery)
            self.view.addSubview(flipCamera)
            self.view.addSubview(capturePictureButton)
            self.view.addSubview(cameraToolbar)
        }
    }
    /**
     Removes from the camera view
     */
    fileprivate func removeCameraElements() {
        if (self.selection != SelectionType.camera) {
            galleryImage.removeFromSuperview()
            gallery.removeFromSuperview()
            flipCamera.removeFromSuperview()
            capturePictureButton.removeFromSuperview()
            cameraToolbar.removeFromSuperview()
        }
    }
    /**
     Closes the view
     */
    open func exitButtonPressed() {
        cameraDelegate.cameraCancelSelection()
    }
    /**
     Takes a photo
     */
    open func capture(_ sender: UIButton) {
        self.takePicture()
    }
    /**
     Enables/disables flash
     */
    open func toggleFlash(_ sender: UIButton) {
        if (sender.isSelected == false) {
            sender.tintColor = UIColor.n1ActionBlueColor()
            sender.isSelected = true
        } else {
            sender.tintColor = UIColor.white
            sender.isSelected = false
        }
        setFlash(sender)
    }
    /**
     Enables/disables flash
     */
    fileprivate func setFlash(_ sender: UIButton) {
        if (sender.isSelected == true) {
            self.cameraFlashMode = UIImagePickerControllerCameraFlashMode.on
        } else {
            self.cameraFlashMode = UIImagePickerControllerCameraFlashMode.off
        }
    }
    /**
     Changes the camera from front to back
     */
    open func flipCamera(_ sender: UIButton) {
        if (sender.isSelected == false) {
            sender.tintColor = UIColor.n1ActionBlueColor()
            sender.isSelected = true
        } else {
            sender.tintColor = UIColor.white
            sender.isSelected = false
        }
        orientCamera(sender)
    }
    /**
     Changes the camera from front to back
     */
    fileprivate func orientCamera(_ sender:UIButton) {
        if (sender.isSelected == true) {
            self.cameraDevice = UIImagePickerControllerCameraDevice.front
        } else {
            self.cameraDevice = UIImagePickerControllerCameraDevice.rear
        }
    }
    
    //MARK: Camera Permissions with completion
    /**
     Requests access for the camera and calls completion block
     - parameter completion: Must be (granted : Bool) -> Void
     */
    open func isCameraPermissionGranted(_ completion:@escaping (_ granted : Bool) -> Void) {
        requestAccessForCamera({ (granted) in
            completion(granted)
        })
    }
    /**
     Requests access for the camera and calls completion block
     - parameter completion: Must be (granted : Bool) -> Void
     */
    open func requestAccessForCamera(_ completion:@escaping (_ granted : Bool) -> Void) {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (granted) in
            completion(granted)
        }
    }
    
    //MARK: Photolibrary Permissions
    /**
     Requests access for the library and calls completion block
     - parameter completion: Must be (granted : Bool) -> Void
     */
    open func requestPhotoLibraryPermissions(_ completion: @escaping (_ granted : Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
                case .authorized: completion(true)
                case .denied, .notDetermined, .restricted : completion(false)
            }
        }
    }
}
