//
//  FlippedClipView.swift
//  SimulatorController
//
//  Created by David Lawson on 5/03/2016.
//

import Foundation
import Cocoa

@IBDesignable
class FlippedClipView: NSClipView
{
    override var flipped: Bool { get { return true } }
}