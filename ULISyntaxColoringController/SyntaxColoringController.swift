//
//  SyntaxColoringController.swift
//  ULISyntaxColoringController
//
//  Created by Uli Kusterer on 14.07.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

import Cocoa


@objc(ULISyntaxColoringController) class SyntaxColoringController: NSResponder, NSTextViewDelegate, NSTextStorageDelegate {
	@IBOutlet var textView: NSTextView!
	var lastEditedRange = NSRange(location: NSNotFound, length: 0)
	var lastChangeInLength = 0
	
	static let tabSizePoints = CGFloat(24.0)
	static let maxTextViewWidth = CGFloat(1.0e7)
	
	override func awakeFromNib() {
		textView.textStorage?.delegate = self
		textView.delegate = self
		
		turnOffWrapping()
	}
	
	func findLineRange(for editedRange: NSRange, in textStorage: NSAttributedString) -> NSRange {
		var lineRange = NSRange(location:0, length: 0)
		let lineStartSearchRange = NSRange(location: 0,length: editedRange.location + editedRange.length)
		let lineEndSearchRange = NSRange(location: editedRange.location, length: textStorage.length - editedRange.location)
		let textStorageString = textStorage.string as NSString
		let textStorageStringLength = textStorageString.length
		let lineStartRange = textStorageString.rangeOfCharacter(from: NSCharacterSet.newlines, options: [.backwards], range: lineStartSearchRange)
		if lineStartRange.location != NSNotFound {
			lineRange.location = lineStartRange.location + lineStartRange.length
		} else {
			lineRange.location = 0
		}
		let lineEndRange = textStorageString.rangeOfCharacter(from: NSCharacterSet.newlines, options: [], range: lineEndSearchRange)
		if lineEndRange.location != NSNotFound {
			lineRange.length = lineEndRange.location + lineEndRange.length - lineRange.location
		} else {
			lineRange.length = textStorageStringLength - lineRange.location
		}
		return lineRange
	}
	
	func textStorage(_ textStorage: NSTextStorage, willProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
		
		if editedMask.contains(.editedCharacters) {
			lastEditedRange = editedRange
			lastChangeInLength = delta
		}
	}
	
	
	func textDidChange(_ notification: Notification) {
		if lastEditedRange.location != NSNotFound, let textStorage = textView.textStorage {
			let theAttributedStr = textStorage as NSMutableAttributedString
			let lineRange = findLineRange(for: lastEditedRange, in: textStorage)
			let entireRange = NSRange(location: 0, length: theAttributedStr.length)
			if entireRange.length > 0 {
				theAttributedStr.removeAttribute(NSBackgroundColorAttributeName, range: entireRange)
			}
			if lineRange.length > 0 {
				theAttributedStr.addAttributes([NSBackgroundColorAttributeName : NSColor.yellow], range: lineRange)
			}
			lastEditedRange = NSRange(location: NSNotFound, length: 0)
		}
	}
	
	
	override func insertNewline(_ sender: Any?) {
		if let textStorage = textView.textStorage {
			let selectedRange = textView.selectedRange()
			let lineRange = findLineRange(for: selectedRange, in: textView.textStorage!)
			let scanner = Scanner(string: textView.string!)
			scanner.charactersToBeSkipped = nil
			scanner.scanLocation = lineRange.location
			var foundText: NSString?
			scanner.scanUpToCharacters(from: CharacterSet.whitespaces.inverted, into: &foundText)
			if let foundText = foundText {
				textView.replaceCharacters(in: selectedRange, with: "\n\(foundText)")
			} else {
				textView.replaceCharacters(in: selectedRange, with: "\n")
			}
			textStorage.endEditing()
		}
	}
	
	
	override func insertTab(_ sender: Any?) {
		if let textStorage = textView.textStorage {
			textStorage.beginEditing()
			let selectedRange = textView.selectedRange()
			textStorage.mutableString.deleteCharacters(in: selectedRange)
			textStorage.mutableString.insert("\t", at: selectedRange.location)
			textStorage.endEditing()
		}
	}
	
	
	override func insertBacktab(_ sender: Any?) {
		print("backtab")
	}

	
	func turnOffWrapping() {
		let textContainer = textView.textContainer!
		var frame = NSRect.zero
		let scrollView = textView.enclosingScrollView!
		let maxSize = NSSize(width: SyntaxColoringController.maxTextViewWidth, height: SyntaxColoringController.maxTextViewWidth)
		
		// Make sure we can see right edge of line:
		scrollView.hasHorizontalScroller = true
		
		// Make text container so wide it won't wrap:
		textContainer.containerSize = maxSize
		textContainer.widthTracksTextView = false
		textContainer.heightTracksTextView = false
		
		// Make sure text view is wide enough:
		frame.origin = .zero
		frame.size = scrollView.contentSize
		
		textView.maxSize = maxSize
		textView.isHorizontallyResizable = true
		textView.isVerticallyResizable = true
		textView.autoresizingMask = .viewNotSizable
	}
}
