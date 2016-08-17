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
    /* IBOutlet for superview of textInputView */
    var textInputAreaView: UIView! {get set}
    /* IBOutlet the view where the user input the text*/
    var textInputView: UITextView! {get set}
    /*init method for the class with passing in NMessengerViewController*/
    init(controller:NMessengerViewController)
     /*init method for the class with passing in NMessengerViewController and a frame*/
    init(controller:NMessengerViewController,frame: CGRect)
}

// we can constrain the shake method to only UIViews!
extension InputBarViewProtocol where Self: UIView {
    
}