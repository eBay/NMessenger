//
//  InputBarViewProtocol.swift
//  nMessenger
//
//  Created by Schechter, David on 8/17/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol InputBarViewProtocol
{
    /* Superview of textInputView - can hold send button and/or attachment button*/
    var textInputAreaView: UIView! {get set}
    /* UITextView where the user will input the text*/
    var textInputView: UITextView! {get set}
    /*init method for the class with passing in NMessengerViewController*/
    init(controller:NMessengerViewController)
     /*init method for the class with passing in NMessengerViewController and a frame*/
    init(controller:NMessengerViewController,frame: CGRect)
}