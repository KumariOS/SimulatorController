//
//  DragDropView.swift
//  SimulatorController
//
//  Created by David Lawson on 5/03/2016.
//

import Cocoa

@objc protocol DragDropViewDelegate: class
{
    func dragDropViewGotURL(appURL: NSURL)
}

class DragDropView: NSView
{
    @IBOutlet weak var nameView: NSTextField!
    @IBOutlet weak var delegate: DragDropViewDelegate!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.registerForDraggedTypes([
            NSURLPboardType
        ])
        
        let layer = CALayer()
        layer.backgroundColor = NSColor(white: 0.9, alpha: 1).CGColor
        self.wantsLayer = true
        self.layer = layer
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation
    {
        let pboard = sender.draggingPasteboard()
        
        if pboard.types!.contains(NSURLPboardType)
        {
            let plist = pboard.propertyListForType(NSURLPboardType) as! [String]
            let file = plist[0]
            return file.hasSuffix(".app") ? .Link : .None
        }
        
        return .None
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool
    {
        let pboard = sender.draggingPasteboard()
        let plist = pboard.propertyListForType(NSURLPboardType) as! [NSString]
        let file = plist[0]
        self.nameView.stringValue = file.lastPathComponent
        
        self.delegate.dragDropViewGotURL(NSURL(string: file as String)!)
        
        return true
    }
}
