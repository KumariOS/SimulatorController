//
//  SimulatorController.swift
//  SimulatorController
//
//  Created by David Lawson on 5/03/2016.
//

import Foundation
import FBSimulatorControl
import AppKit

enum Simulator: String
{
    case iPhone4s = "iPhone 4s"
    case iPhone5 = "iPhone 5"
    case iPhone5s = "iPhone 5s"
    case iPhone6 = "iPhone 6"
    case iPhone6Plus = "iPhone 6 Plus"
    case iPhone6s = "iPhone 6s"
    case iPhone6sPlus = "iPhone 6s Plus"
    case iPhoneSE = "iPhone SE"
    case iPhone7 = "iPhone 7"
    case iPhone7Plus = "iPhone 7 Plus"
    case iPad2 = "iPad 2"
    case iPadAir = "iPad Air"
    case iPadAir2 = "iPad Air 2"
    case iPadPro = "iPad Pro"
    case iPadRetina = "iPad Retina"
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
        .iPhoneSE,
        .iPhone7,
        .iPhone7Plus,
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
        .iPhoneSE: FBSimulatorConfiguration.iPhoneSE(),
        .iPhone7: FBSimulatorConfiguration.iPhone7(),
        .iPhone7Plus: FBSimulatorConfiguration.iPhone7Plus(),
        .iPad2: FBSimulatorConfiguration.iPad2(),
        .iPadAir: FBSimulatorConfiguration.iPadAir(),
        .iPadAir2: FBSimulatorConfiguration.iPadAir2(),
        .iPadPro: FBSimulatorConfiguration.iPadPro(),
        .iPadRetina: FBSimulatorConfiguration.iPadRetina()
    ]
    
    private let control: FBSimulatorControl
    private let allocationOptions: FBSimulatorAllocationOptions
    private let simulatorLaunchConfiguration: FBSimulatorBootConfiguration
    
    private var application: FBApplicationDescriptor?
    private var launchConfiguration: FBApplicationLaunchConfiguration?
    
    private var simulators: [FBSimulator] = []
    
    private(set) var state: SimulatorState = .Ready
    
    init()
    {
        let managementOptions: FBSimulatorManagementOptions = [.killAllOnFirstStart]
        let controlConfiguration = FBSimulatorControlConfiguration(deviceSetPath: nil, options: managementOptions)
        self.control = try! FBSimulatorControl.withConfiguration(controlConfiguration)
        self.allocationOptions = [.reuse]
        self.simulatorLaunchConfiguration = FBSimulatorBootConfiguration.scale50Percent()
    }
    
    func setApplication(appURL: NSURL, bundleID: String, executable: String) throws
    {
        self.application = try FBApplicationDescriptor(
            name: bundleID,
            path: appURL.path!,
            bundleID: bundleID,
            binary: FBBinaryDescriptor.binary(withPath: (appURL.appendingPathComponent(executable))!.path)
        )
        
        self.launchConfiguration = FBApplicationLaunchConfiguration(
            application: application!,
            arguments: [],
            environment: [:],
            options: []
        )
    }
    
    func boot(simulators: Set<Simulator>)
    {
        let simulatorConfigurations = simulators.map { simulator in SimulatorController.simulatorMap[simulator]! }
        for simulatorConfiguration in simulatorConfigurations
        {
            do
            {
                let simulator = try self.control.pool.allocateSimulator(with: simulatorConfiguration, options: allocationOptions)
                let interact = simulator.interact
                if simulator.state != .booted
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
        let dispatchGroup = DispatchGroup()
        
        for simulator in self.simulators
        {
            DispatchQueue.global().async(group: dispatchGroup, qos: .userInitiated, flags: [])
            {
                do
                {
                    try simulator.interact.installApplication(self.application!).launchApplication(self.launchConfiguration!).perform()
                }
                catch let error as NSError
                {
                    DispatchQueue.main.async
                    {
                        NSAlert(error: error).runModal()
                    }

                }
            }
        }
        
        _ = dispatchGroup.wait(timeout: DispatchTime.distantFuture)
    }
    
    func shutdown()
    {
        let dispatchGroup = DispatchGroup()
        
        for simulator in self.simulators
        {
            DispatchQueue.global().async(group: dispatchGroup, qos: .userInitiated, flags: [])
            {
                do
                {
                    try simulator.interact.shutdownSimulator().perform()
                }
                catch let error as NSError
                {
                    DispatchQueue.main.async {
                        NSAlert(error: error).runModal()
                    }
                }
            }
        }
        
        _ = dispatchGroup.wait(timeout: DispatchTime.distantFuture)
        
        self.simulators.removeAll()
        
        self.state = .Ready
    }
}
