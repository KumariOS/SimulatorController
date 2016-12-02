//
//  FlippedClipView.swift
//  SimulatorController
//
//  Created by David Lawson on 5/03/2016.
//

import Foundation
import Cocoa

class FlippedClipView: NSClipView
{
    override var isFlipped: Bool { get { return true } }
}
