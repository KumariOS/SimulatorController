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
        
        for simType in SimulatorController.availableSimulators
        {
            let button = NSButton()
            button.setButtonType(.SwitchButton)
            button.alignment = .Left
            button.imagePosition = .ImageRight
            button.title = simType.rawValue
            button.target = self
            button.action = #selector(toggledSimulator)
            self.toggles.append(button)
            self.simulatorStackView.addView(button, inGravity: .Top)
            self.simulatorStackView.addConstraint(NSLayoutConstraint(item: self.simulatorStackView, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1, constant: 20))
        }
    }

    override var representedObject: AnyObject?
    {
        didSet
        {
            // Update the view, if already loaded.
        }
    }
    
    func dragDropViewGotURL(appURL: NSURL)
    {
        let plistURL = appURL.URLByAppendingPathComponent("Info.plist")
        let plist = NSDictionary(contentsOfURL: plistURL)!
        
        let bundleID = plist["CFBundleIdentifier"] as! String
        let executable = plist["CFBundleExecutable"] as! String
        
        self.simulatorController.setApplication(appURL, bundleID: bundleID, executable: executable)
        
        self.hasApp = true
        self.updateState()
    }
    
    @IBAction func pressedBoot(sender: AnyObject)
    {
        self.simulatorController.boot(self.enabledSimulators)
        
        self.toggles.forEach { toggle in toggle.enabled = false }
        
        self.updateState()
    }
    
    @IBAction func pressedBootAndInstall(sender: AnyObject)
    {
        self.simulatorController.boot(self.enabledSimulators)
        self.simulatorController.install()
        
        self.toggles.forEach { toggle in toggle.enabled = false }
        
        self.updateState()
    }
    
    @IBAction func pressedInstall(sender: AnyObject)
    {
        self.simulatorController.install()
    }
    
    @IBAction func pressedShutdown(sender: AnyObject)
    {
        self.simulatorController.shutdown()
        
        self.toggles.forEach { toggle in toggle.enabled = true }
        
        self.updateState()
    }
    
    func updateState()
    {
        self.bootButton.enabled = self.enabledSimulators.count > 0 && self.hasApp && self.simulatorController.state == .Ready
        self.bootInstallButton.enabled = self.enabledSimulators.count > 0 && self.hasApp && self.simulatorController.state == .Ready
        self.installButton.enabled = self.simulatorController.state == .Booted
        self.shutdownButton.enabled = self.simulatorController.state == .Booted
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
}

