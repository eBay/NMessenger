//
//  MessageCellProtocol.swift
//  nMessenger
//
//  Created by Tainter, Aaron on 7/15/16.
//  Copyright © 2016 Ebay Inc. All rights reserved.
//

import Foundation

/** Protocol used by a message cell to handle various message related actions */
@objc protocol MessageCellProtocol {
    /**
     Called when the avatar is clicked. Notifies the delegate of the message cell whose avatar is clicked
     */
    optional func avatarClicked(messageCell: GeneralMessengerCell)
}