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
import AsyncDisplayKit

//MARK: GeneralMessengerCell
/**
 GeneralMessengerCell class for NMessenger. Extends ASCellNode.
 Defines the base class for all messages in NMessenger.
 */
public class GeneralMessengerCell: ASCellNode {
    
    // MARK: Public Variables
    /** UIEdgeInsets for cell*/
    public var cellPadding: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    /** UIViewController that holds the cell. Allows the cell the present View Controllers*/
    public var currentViewController: UIViewController?
    /** The current table in which this node resides*/
    public var currentTableNode: ASTableNode?
    /** message incoming/outgoing */
    public var isIncomingMessage:Bool = true
    
    // MARK: Initialisers
    /**
     Default Init
     Sets cellPadding to 0 and selectionStyle to None
     */
    public override init() {
        super.init()
        selectionStyle = .None
        cellPadding = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    /**
     Initialiser for the cell
     - parameter cellPadding: Can be UIEdgeInsets. Sets padding for cell.
     - parameter currentViewController: Can be an UIViewController. Set current view controller holding the cell.
     */
    public convenience init(cellPadding: UIEdgeInsets?, currentViewController: UIViewController?) {
        self.init()
        
        //set cell padding
        if let cellPadding = cellPadding {
            self.cellPadding = cellPadding
        }
        
        //set current view controller
        self.currentViewController = currentViewController
    }
    
}
