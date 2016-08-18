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
import UIKit

@objc public protocol InputBarViewProtocol
{
    /* Superview of textInputView - can hold send button and/or attachment button*/
    var textInputAreaView: UIView! {get set}
    /* UITextView where the user will input the text*/
    var textInputView: UITextView! {get set}
    /*init method for the class*/
    init()
    /*init method for the class with passing in NMessengerViewController*/
    init(controller:NMessengerViewController)
     /*init method for the class with passing in NMessengerViewController and a frame*/
    init(controller:NMessengerViewController,frame: CGRect)
    //NMessengerViewController where to input is sent to
    var controller:NMessengerViewController! {get set}
}