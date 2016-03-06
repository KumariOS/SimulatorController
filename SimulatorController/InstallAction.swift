//
//  InstallAction.swift
//  SimulatorController
//
//  Created by David Lawson on 6/03/2016.
//

import Cocoa

let InstallActionNotification = "InstallActionNotification"

class InstallAction: NSScriptCommand
{
    override func performDefaultImplementation() -> AnyObject?
    {
        NSNotificationCenter.defaultCenter().postNotificationName(InstallActionNotification, object: nil)
        return nil
    }
}
