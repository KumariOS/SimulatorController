//
//  InstallAction.swift
//  SimulatorController
//
//  Created by David Lawson on 6/03/2016.
//

import Cocoa

let InstallActionNotification = NSNotification.Name("InstallActionNotification")

class InstallAction: NSScriptCommand
{
    override func performDefaultImplementation() -> Any?
    {
        NotificationCenter.default.post(name: InstallActionNotification, object: nil)
        return nil
    }
}
