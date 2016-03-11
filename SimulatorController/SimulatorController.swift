//
//  SimulatorController.swift
//  SimulatorController
//
//  Created by David Lawson on 5/03/2016.
//

import Foundation
import FBSimulatorControl

enum Simulator: String
{
    case iPhone4s = "iPhone 4s"
    case iPhone5 = "iPhone 5"
    case iPhone5s = "iPhone 5s"
    case iPhone6 = "iPhone 6"
    case iPhone6Plus = "iPhone 6 Plus"
    case iPhone6s = "iPhone 6s"
    case iPhone6sPlus = "iPhone 6s Plus"
    case iPad2 = "iPad 2"
    case iPadAir = "iPad Air"
    case iPadAir2 = "iPad Air 2"
    case iPadPro = "iPad Pro"
    case iPadRetina = "iPad Retina"
}

extension FBSimulatorConfiguration
{
    class func iPhone6s() -> FBSimulatorConfiguration {
        return FBSimulatorConfiguration.iPhone6().updateNamedDevice(FBSimulatorConfiguration_Device_iPhone6S())
    }
    class func iPhone6sPlus() -> FBSimulatorConfiguration {
        return FBSimulatorConfiguration.iPhone6Plus().updateNamedDevice(FBSimulatorConfiguration_Device_iPhone6SPlus())
    }
    class func iPadPro() -> FBSimulatorConfiguration {
        return FBSimulatorConfiguration.iPadRetina().updateNamedDevice(FBSimulatorConfiguration_Device_iPadPro())
    }
}

enum SimulatorState
{
    case Ready
    case Booted
}

class SimulatorController
{
    static let availableSimulators: [Simulator] = [
        .iPhone4s,
        .iPhone5,
        .iPhone5s,
        .iPhone6,
        .iPhone6Plus,
        .iPhone6s,
        .iPhone6sPlus,
        .iPad2,
        .iPadAir,
        .iPadAir2,
        .iPadPro,
        .iPadRetina
    ]
    
    private static let simulatorMap: [Simulator: FBSimulatorConfiguration] = [
        .iPhone4s: FBSimulatorConfiguration.iPhone4s(),
        .iPhone5: FBSimulatorConfiguration.iPhone5(),
        .iPhone5s: FBSimulatorConfiguration.iPhone5s(),
        .iPhone6: FBSimulatorConfiguration.iPhone6(),
        .iPhone6Plus: FBSimulatorConfiguration.iPhone6Plus(),
        .iPhone6s: FBSimulatorConfiguration.iPhone6s(),
        .iPhone6sPlus: FBSimulatorConfiguration.iPhone6sPlus(),
        .iPad2: FBSimulatorConfiguration.iPad2(),
        .iPadAir: FBSimulatorConfiguration.iPadAir(),
        .iPadAir2: FBSimulatorConfiguration.iPadAir2(),
        .iPadPro: FBSimulatorConfiguration.iPadPro(),
        .iPadRetina: FBSimulatorConfiguration.iPadRetina()
    ]
    
    private let control: FBSimulatorControl
    private let allocationOptions: FBSimulatorAllocationOptions
    private let simulatorLaunchConfiguration: FBSimulatorLaunchConfiguration
    
    private var application: FBSimulatorApplication?
    private var launchConfiguration: FBApplicationLaunchConfiguration?
    
    private var simulators: [FBSimulator] = []
    
    private(set) var state: SimulatorState = .Ready
    
    init()
    {
        let managementOptions: FBSimulatorManagementOptions = [.KillAllOnFirstStart]
        let controlConfiguration = FBSimulatorControlConfiguration(deviceSetPath: nil, options: managementOptions)
        self.control = try! FBSimulatorControl.withConfiguration(controlConfiguration)
        self.allocationOptions = [.Reuse]
        self.simulatorLaunchConfiguration = FBSimulatorLaunchConfiguration.scale50Percent()
    }
    
    func setApplication(appURL: NSURL, bundleID: String, executable: String) throws
    {
        self.application = try FBSimulatorApplication(
            name: bundleID,
            path: appURL.path,
            bundleID: bundleID,
            binary: FBSimulatorBinary(path: appURL.URLByAppendingPathComponent(executable).path)
        )
        
        self.launchConfiguration = FBApplicationLaunchConfiguration(
            application: application,
            arguments: [],
            environment: [:]
        )
    }
    
    func boot(simulators: Set<Simulator>)
    {
        let simulatorConfigurations = simulators.map { simulator in SimulatorController.simulatorMap[simulator]! }
        for simulatorConfiguration in simulatorConfigurations
        {
            do
            {
                let simulator = try self.control.pool.allocateSimulatorWithConfiguration(simulatorConfiguration, options: allocationOptions)
                let interact = simulator.interact
                if simulator.state != .Booted
                {
                    interact.bootSimulator(self.simulatorLaunchConfiguration)
                    
                    do
                    {
                        try interact.perform()
                    }
                    catch let error as NSError
                    {
                        NSAlert(error: error).runModal()
                    }
                    
                    self.simulators.append(simulator)
                }
            }
            catch let error as NSError
            {
                NSAlert(error: error).runModal()
            }
        }
        
        self.state = .Booted
    }
    
    func install()
    {
        let dispatchGroup = dispatch_group_create()
        
        for simulator in self.simulators
        {
            dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
            {
                do
                {
                    try simulator.interact.installApplication(self.application).launchApplication(self.launchConfiguration).perform()
                }
                catch let error as NSError
                {
                    dispatch_async(dispatch_get_main_queue())
                    {
                        NSAlert(error: error).runModal()
                    }

                }
            }
        }
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
    }
    
    func shutdown()
    {
        let dispatchGroup = dispatch_group_create()
        
        for simulator in self.simulators
        {
            dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
            {
                do
                {
                    try simulator.interact.shutdownSimulator().perform()
                }
                catch let error as NSError
                {
                    dispatch_async(dispatch_get_main_queue())
                    {
                        NSAlert(error: error).runModal()
                    }
                    
                }
            }
        }
        
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
        
        self.simulators.removeAll()
        
        self.state = .Ready
    }
}