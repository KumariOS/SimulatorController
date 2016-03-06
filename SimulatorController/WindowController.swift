//
//  WindowController.swift
//  SimulatorController
//
//  Created by David Lawson on 5/03/2016.
//

import Foundation
import Cocoa

class WindowController: NSWindowController
{
    override func windowDidLoad()
    {
        super.windowDidLoad()
        self.window!.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
    }
}