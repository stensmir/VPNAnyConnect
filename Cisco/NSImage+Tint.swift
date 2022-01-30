//
//  NSImage+Tint.swift
//  Cisco
//
//  Created by Юрий Дурнев on 30.01.2022.
//

import Foundation
import Cocoa

extension NSImage {
	func tinting(with tintColor: NSColor) -> NSImage {
		guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return self }
		
		return NSImage(size: size, flipped: false) { bounds in
			guard let context = NSGraphicsContext.current?.cgContext else { return false }
			tintColor.set()
			context.clip(to: bounds, mask: cgImage)
			context.fill(bounds)
			return true
		}
	}
}
