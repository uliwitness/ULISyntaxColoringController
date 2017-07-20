//
//  SyntaxColoringTextView.swift
//  ULISyntaxColoringController
//
//  Created by Uli Kusterer on 18.07.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

import Cocoa



public class SyntaxColoringTextView: NSTextView {
	class UndoInfo : NSObject {
		let text: String
		let replacementRange: NSRange
		
		init( text: String, replacementRange: NSRange ) {
			self.text = text
			self.replacementRange = replacementRange
		}
	}

	override public func insertNewline(_ sender: Any?) {
		if let delegate = delegate as? NSResponder {
			delegate.insertNewline(sender)
		}
	}
	
	
	override public func insertTab(_ sender: Any?) {
		if let delegate = delegate as? NSResponder {
			delegate.insertTab(sender)
		}
	}
	
	
	override public func insertBacktab(_ sender: Any?) {
		if let delegate = delegate as? NSResponder {
			delegate.insertBacktab(sender)
		}
	}
	
	
	public func replaceUndoableCharacters( in selectedRange: NSRange, with insertedText: String ) {
		replaceCharacters(in: selectedRange, with: insertedText)
		let undoInfo = UndoInfo(text: "", replacementRange: NSRange(location: selectedRange.location, length: (insertedText as NSString).length))
		undoManager?.registerUndo(withTarget: self, selector: #selector(undoRange), object: undoInfo)
	}
	
	
	dynamic func undoRange( _ undoInfo: UndoInfo ) {
		let tvStr = string! as NSString
		let redoInfo = UndoInfo( text: tvStr.substring(with: undoInfo.replacementRange), replacementRange: NSRange(location: undoInfo.replacementRange.location, length: (undoInfo.text as NSString).length) )
		replaceCharacters(in: undoInfo.replacementRange, with: undoInfo.text)
		undoManager?.registerUndo(withTarget: self, selector: #selector(undoRange), object: redoInfo)
	}
}
