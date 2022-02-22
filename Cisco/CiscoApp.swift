//
//  CiscoApp.swift
//  Cisco
//
//  Created by Юрий Дурнев on 22.01.2022.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	var statusItem: NSStatusItem?
	var popOver = NSPopover()
	
	static private(set) var instance: AppDelegate! = nil
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		AppDelegate.instance = self
		let menuView = ContentView()
		popOver.behavior = .transient
		popOver.animates = true
		
		popOver.contentViewController = NSViewController()
		popOver.contentViewController?.view = NSHostingView(rootView: menuView)
		
		popOver.contentViewController?.view.window?.becomeKey()
		
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		
		if let button = statusItem?.button {
			button.image = NSImage(systemSymbolName: menuView.hasConnect() ? "shield.fill" : "shield", accessibilityDescription: nil)?.tinting(with: .white)
			button.action = #selector(toogle)
		}
		NSApp.activate(ignoringOtherApps: true)
	}
	
	@objc func toogle(sender: AnyObject) {
		if popOver.isShown {
			popOver.performClose(sender)
		} else {
			if let button = statusItem?.button {
				popOver.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxY)
			}
		}
	}
}
