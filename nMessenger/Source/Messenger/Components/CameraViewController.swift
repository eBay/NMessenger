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
    func pickedImage(image: UIImage!)
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
    case Camera
    case Library
}
//MARK: CameraViewController
/**
 CameraViewController class for NMessenger.
 Defines the camera view for NMessenger. This is where the user will take photos or select them from the library.
 */
public class CameraViewController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Public Parameters
    //CameraViewDelegate that implemets the delegate methods
    public var cameraDelegate: CameraViewDelegate!
    //SelectionType type of selection the user is making  - defualt is camera
    public var selection = SelectionType.Camera
    //AVAuthorizationStatus authorization status for the camera
    public var cameraAuthStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
    //PHAuthorizationStatus authorization status for the library
    public var photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
    //MARK: Private Parameters
    //UIButton to change to gallery mode
    private var gallery: UIButton!
    //UIImageView image from the gallery
    private var galleryImage: UIImageView!
    //UIButton to take a photo
    private var capturePictureButton: UIButton!
    //UIButton to flip camera between front and back
    private var flipCamera:UIButton!
    //UIToolbar to hold buttons above the live camera view
    private var cameraToolbar: UIToolbar!
    //UIButton to enable/disable flash
    private var flashButton:UIButton!
    //CGFloat to define size for capture button
    private let captureButtonSize:CGFloat = 80
    //CGFloat to define size for buttons under the live camera view
    private let sideButtonSize:CGFloat = 50
    //CGFloat to define padding for bottom view
    private let bottomPadding:CGFloat = 40
    //Bool if user gave permission for the camera
    private let isCameraAvailable = UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) ||
        UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)
    
    //MARK: View Lifecycle
    /**
     Ovreriding viewDidLoad to setup the controller
     Calls helper method
     */
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.allowsEditing = true
        self.delegate = self
        initView()
    }
    
    /**
     Ovreriding viewDidAppear to setup the camera view if there are permissions for the camera
     */
    override public func viewDidAppear(animated: Bool) {
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            if (self.sourceType == UIImagePickerControllerSourceType.Camera) {
                orientCamera(flipCamera)
                setFlash(flashButton)
            }
        }
    }
    
    //MARK: View Lifecycle helper methods
    /**
     Initialise the view and request for permissions if necessary
     */
    private func initView() {
        //check if the camera is available
        if ((UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) && (cameraAuthStatus == AVAuthorizationStatus.Authorized)){
            self.sourceType = UIImagePickerControllerSourceType.Camera
            self.showsCameraControls = false
            self.selection = SelectionType.Camera
            self.renderCameraElements()
            
        } else
            {
                self.cameraAuthStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
                if(photoLibAuthStatus != PHAuthorizationStatus.Authorized) {
                    self.requestPhotoLibraryPermissions({ (granted) in
                        if(granted) {
                            self.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                            self.selection = SelectionType.Library
                        }
                        else
                        {
                            self.photoLibAuthStatus = PHPhotoLibrary.authorizationStatus()
                            self.dismissViewControllerAnimated(true, completion: {
                                let presentingViewController = self.cameraDelegate as! NMessengerViewController
                                ModalAlertUtilities.postGoToSettingToEnableLibraryModal(fromController: presentingViewController)
                            })
                        }
                    })
                }
                else
                {
                    self.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                    self.selection = SelectionType.Library
                }
            }
    }
    /**
     Adds all the buttons for the custom camera view
     */
    private func renderCameraElements() {
        addGalleryButton()
        //set gallery image thumbnail
        if(photoLibAuthStatus != PHAuthorizationStatus.Authorized) {
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
    private func addGalleryButton() {
        //GALLERY BUTTON
        gallery = UIButton(frame: CGRectMake(self.view.frame.width - sideButtonSize - bottomPadding, self.view.frame.height - sideButtonSize - bottomPadding, sideButtonSize, sideButtonSize))
        gallery.addTarget(self, action: #selector(CameraViewController.changePictureMode), forControlEvents: UIControlEvents.TouchUpInside)
        gallery.setImage(UIImage(named: "cameraRollIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        gallery.tintColor = UIColor.whiteColor()
        galleryImage = UIImageView(frame: gallery.frame)
        galleryImage.contentMode = UIViewContentMode.ScaleAspectFill
        galleryImage.clipsToBounds = true
        galleryImage.hidden = true
    }
    /**
     Adds the gallery thumbnail for the custom camera view
     */
    private func getGalleryThumbnail() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors =  [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        let lastAsset = fetchResult.lastObject as! PHAsset
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = PHImageRequestOptionsVersion.Current
        PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: self.galleryImage.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions) { (image, info) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.galleryImage.image = image
            })
        }
    }
    /**
     Adds the capture button for the custom camera view
     */
    private func addCaptureButton() {
        
        //CAPTURE BUTTON
        capturePictureButton = UIButton(frame: CGRectMake(self.view.frame.width/2 - bottomPadding, self.view.frame.height - captureButtonSize - bottomPadding, captureButtonSize, captureButtonSize))
        capturePictureButton.setImage(UIImage(named: "shutterBtn")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        capturePictureButton.tintColor = UIColor.whiteColor()
        
        //call the uiimagepickercontroller method takePicture()
        capturePictureButton.addTarget(self, action: #selector(CameraViewController.capture(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    /**
     Adds the flip button for the custom camera view
     */
    private func addFlipCameraButton() {
        //FLIP CAMERA BUTTON
        flipCamera = UIButton(frame: CGRectMake(bottomPadding, self.view.frame.height - sideButtonSize - bottomPadding, sideButtonSize, sideButtonSize))
        flipCamera.addTarget(self, action: #selector(CameraViewController.flipCamera(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        flipCamera.setImage(UIImage(named: "flipCameraIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        flipCamera.tintColor = UIColor.whiteColor()
    }
    /**
     Adds the toolbar for the custom camera view
     */
    private func addCameraToolBar() {
        //CAMERA TOOLBAR
        cameraToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.width, 60))
        cameraToolbar.barStyle = UIBarStyle.BlackTranslucent
        cameraToolbar.translucent = true
        let exitButton = UIButton(frame: CGRectMake(20, 10, 40, 40))
        exitButton.setImage(UIImage(named: "exitIcon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        exitButton.tintColor = UIColor.whiteColor()
        exitButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        exitButton.addTarget(self, action: #selector(CameraViewController.exitButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        cameraToolbar.addSubview(exitButton)
    }
    /**
     Adds the flash button for the custom camera view
     */
    public func addFlashButton() {
        //Flash Button
        flashButton = UIButton(frame: CGRectMake(self.view.frame.width - 60, 10, 40, 40))
        flashButton.setImage(UIImage(named: "flashIcon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        flashButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flashButton.tintColor = UIColor.whiteColor()
        flashButton.addTarget(self, action: #selector(CameraViewController.toggleFlash(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cameraToolbar.addSubview(flashButton)
    }
    
    //MARK: ImagePickerDelegate Methods
    /**
     Implementing didFinishPickingMediaWithInfo to send the selected image to the cameraDelegate
     */
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var myImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if myImage == nil {
            myImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            /* Correctly flip the mirrored image of front-facing camera */
            if self.cameraDevice == UIImagePickerControllerCameraDevice.Front {
                if let im = myImage, cgImage = im.CGImage {
                    myImage = UIImage(CGImage: cgImage, scale: im.scale, orientation: UIImageOrientation.LeftMirrored)
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
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        switch selection {
        case .Camera where !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) :
            cameraDelegate.cameraCancelSelection()
        case .Library:
            changePictureMode()
        default:
            break
        }
    }
    
    //MARK: Selectors
    /**
     Changes between camera view and gallery view
     */
    public func changePictureMode() {
        
        switch selection {
        case .Camera:
            selection = SelectionType.Library
            removeCameraElements()
            self.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        case .Library where (isCameraAvailable &&  (cameraAuthStatus == AVAuthorizationStatus.Authorized)):
            selection = SelectionType.Camera
            addCameraElements()
            self.sourceType = UIImagePickerControllerSourceType.Camera
            orientCamera(flipCamera)
            setFlash(flashButton)
        default:
            cameraDelegate.cameraCancelSelection()
        }
    }
    /**
     Adds buttons for the camera view
     */
    private func addCameraElements() {
        if (self.selection == SelectionType.Camera) {
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
    private func removeCameraElements() {
        if (self.selection != SelectionType.Camera) {
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
    public func exitButtonPressed() {
        cameraDelegate.cameraCancelSelection()
    }
    /**
     Takes a photo
     */
    public func capture(sender: UIButton) {
        self.takePicture()
    }
    /**
     Enables/disables flash
     */
    public func toggleFlash(sender: UIButton) {
        if (sender.selected == false) {
            sender.tintColor = UIColor.n1ActionBlueColor()
            sender.selected = true
        } else {
            sender.tintColor = UIColor.whiteColor()
            sender.selected = false
        }
        setFlash(sender)
    }
    /**
     Enables/disables flash
     */
    private func setFlash(sender: UIButton) {
        if (sender.selected == true) {
            self.cameraFlashMode = UIImagePickerControllerCameraFlashMode.On
        } else {
            self.cameraFlashMode = UIImagePickerControllerCameraFlashMode.Off
        }
    }
    /**
     Changes the camera from front to back
     */
    public func flipCamera(sender: UIButton) {
        if (sender.selected == false) {
            sender.tintColor = UIColor.n1ActionBlueColor()
            sender.selected = true
        } else {
            sender.tintColor = UIColor.whiteColor()
            sender.selected = false
        }
        orientCamera(sender)
    }
    /**
     Changes the camera from front to back
     */
    private func orientCamera(sender:UIButton) {
        if (sender.selected == true) {
            self.cameraDevice = UIImagePickerControllerCameraDevice.Front
        } else {
            self.cameraDevice = UIImagePickerControllerCameraDevice.Rear
        }
    }
    
    //MARK: Camera Permissions with completion
    /**
     Requests access for the camera and calls completion block
     - parameter completion: Must be (granted : Bool) -> Void
     */
    public func isCameraPermissionGranted(completion:(granted : Bool) -> Void) {
        requestAccessForCamera({ (granted) in
            completion(granted: granted)
        })
    }
    /**
     Requests access for the camera and calls completion block
     - parameter completion: Must be (granted : Bool) -> Void
     */
    public func requestAccessForCamera(completion:(granted : Bool) -> Void) {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { (granted) in
            completion(granted: granted)
        }
    }
    
    //MARK: Photolibrary Permissions
    /**
     Requests access for the library and calls completion block
     - parameter completion: Must be (granted : Bool) -> Void
     */
    public func requestPhotoLibraryPermissions(completion: (granted : Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
                case .Authorized: completion(granted : true)
                case .Denied, .NotDetermined, .Restricted : completion(granted : false)
            }
        }
    }
}