//
//  ViewController.swift
//  SimulatorController
//
//  Created by David Lawson on 5/03/2016.
//

import Cocoa

class ViewController: NSViewController, DragDropViewDelegate
{
    var simulatorController: SimulatorController!
    
    @IBOutlet weak var bootButton: NSButton!
    @IBOutlet weak var bootInstallButton: NSButton!
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet weak var shutdownButton: NSButton!
    
    @IBOutlet weak var simulatorStackView: NSStackView!
    
    var hasApp = false
    var enabledSimulators: Set<Simulator> = []
    var toggles: [NSButton] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.simulatorController = SimulatorController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.installAction(notification:)), name: InstallActionNotification, object: nil)
        
        for simType in SimulatorController.availableSimulators
        {
            let button = NSButton()
            button.setButtonType(.switch)
            button.alignment = .left
            button.imagePosition = .imageRight
            button.title = simType.rawValue
            button.target = self
            button.action = #selector(ViewController.toggledSimulator(button:))
            self.toggles.append(button)
            self.simulatorStackView.addView(button, in: .top)
            self.simulatorStackView.addConstraint(NSLayoutConstraint(item: self.simulatorStackView, attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1, constant: 20))
        }
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: InstallActionNotification, object: nil)
    }
    
    func dragDropViewGotURL(appURL: NSURL)
    {
        let plistURL = appURL.appendingPathComponent("Info.plist")
        let plist = NSDictionary(contentsOf: plistURL!)!
        
        let bundleID = plist["CFBundleIdentifier"] as! String
        let executable = plist["CFBundleExecutable"] as! String
        
        do
        {
            try self.simulatorController.setApplication(appURL: appURL, bundleID: bundleID, executable: executable)
            self.hasApp = true
            self.updateState()
        }
        catch let error as NSError
        {
            NSAlert(error: error).runModal()
        }
    }
    
    @IBAction func pressedBoot(sender: AnyObject)
    {
        self.simulatorController.boot(simulators: self.enabledSimulators)
        
        self.toggles.forEach { toggle in toggle.isEnabled = false }
        
        self.updateState()
    }
    
    @IBAction func pressedBootAndInstall(sender: AnyObject)
    {
        self.simulatorController.boot(simulators: self.enabledSimulators)
        self.simulatorController.install()
        
        self.toggles.forEach { toggle in toggle.isEnabled = false }
        
        self.updateState()
    }
    
    @IBAction func pressedInstall(sender: AnyObject)
    {
        self.simulatorController.install()
    }
    
    @IBAction func pressedShutdown(sender: AnyObject)
    {
        self.simulatorController.shutdown()
        
        self.toggles.forEach { toggle in toggle.isEnabled = true }
        
        self.updateState()
    }
    
    func updateState()
    {
        self.bootButton.isEnabled = self.enabledSimulators.count > 0 && self.hasApp && self.simulatorController.state == .Ready
        self.bootInstallButton.isEnabled = self.enabledSimulators.count > 0 && self.hasApp && self.simulatorController.state == .Ready
        self.installButton.isEnabled = self.simulatorController.state == .Booted
        self.shutdownButton.isEnabled = self.simulatorController.state == .Booted
    }
    
    func toggledSimulator(button: NSButton)
    {
        if button.state == NSOnState
        {
            self.enabledSimulators.insert(Simulator(rawValue: button.title)!)
        }
        else
        {
            self.enabledSimulators.remove(Simulator(rawValue: button.title)!)
        }
        
        self.updateState()
    }
    
    func installAction(notification: NSNotification)
    {
        if self.simulatorController.state == .Booted
        {
            self.simulatorController.install()
        }
    }
}

