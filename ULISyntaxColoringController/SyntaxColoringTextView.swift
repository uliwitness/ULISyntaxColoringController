//
//  SyntaxColoringTextView.swift
//  ULISyntaxColoringController
//
//  Created by Uli Kusterer on 18.07.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

import Cocoa


class SyntaxColoringTextView: NSTextView {
	override func insertNewline(_ sender: Any?) {
		if let delegate = delegate as? NSResponder {
			delegate.insertNewline(sender)
		}
	}
	
	
	override func insertTab(_ sender: Any?) {
		if let delegate = delegate as? NSResponder {
			delegate.insertTab(sender)
		}
	}
	
	
	override func insertBacktab(_ sender: Any?) {
		if let delegate = delegate as? NSResponder {
			delegate.insertBacktab(sender)
		}
	}
	
}
