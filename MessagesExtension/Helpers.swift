//
//  Helpers.swift
//  Pollarious
//
//  Created by Julian Dunskus on 28/06/16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import UIKit

extension Array {
	
	mutating func filterArray(_ includeElement: @noescape (Element) throws -> Bool) rethrows {
		for i in 0 ..< count {
			var offset = 0
			if try !includeElement(self[i - offset]) {
				remove(at: i - offset)
				offset += 1
			}
		}
	}
	
	func withoutFirst() -> [Element] {
		var new: [Element] = []
		for i in 1 ..< count {
			new.append(self[i])
		}
		return new
	}
}

extension UIViewController {
	
	func showDeletionAlert(titled title: String?,
	                       message: String?,
	                       handler: (() -> Void)) {
		showAlert(titled: title, message: message, canCancel: true, okMessage: "Delete", okStyle: .destructive, okHandler: handler)
	}
	
	func showAlert(titled title: String?,
	               message: String?,
	               canCancel: Bool = false,
	               okMessage: String = "Okay",
	               okStyle: UIAlertActionStyle = .default,
	               okHandler: (() -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		if canCancel {
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		}
		alert.addAction(UIAlertAction(title: okMessage, style: okStyle, handler: { (action) in
			okHandler?()
		}))
		present(alert, animated: true)
	}
	
	func showTextFieldAlert(titled title: String, placeholder: String? = nil, previousText: String? = nil, handler: ((String) -> Void)) {
		
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		var textField: UITextField!
		alert.addTextField { (field) in
			textField = field
			if let text = placeholder {
				field.placeholder = text
			}
			field.text = previousText
		}
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
			if let text = textField.text {
				if !text.isEmpty {
					handler(text)
				}
			}
		}))
		present(alert, animated: true)
	}
	
	func editActions(editHandler: ((IndexPath) -> ()), deleteHandler: ((IndexPath) -> ())) -> [UITableViewRowAction] {
		var actions: [UITableViewRowAction] = []
		
		actions.append(UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
			deleteHandler(indexPath)
		}))
		actions.append(UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, indexPath) in
			editHandler(indexPath)
		}))
		
		return actions
	}
}

extension NSLayoutConstraint {
	
	func setMultiplier(to newMult: CGFloat) {
		let copy = NSLayoutConstraint(item: firstItem, attribute: firstAttribute, relatedBy: relation,
		                              toItem: secondItem, attribute: secondAttribute, multiplier: newMult, constant: constant)
		copy.identifier = identifier
		copy.priority = priority
		
		isActive = false
		copy.isActive = true
	}
}

extension Poll {
	
	func pieChart(sized size: CGSize) -> UIImage {
		let fractions = options.map { (option) in
			CGFloat(votePercentage(for: option))
		}
		
		return ChartHelper.drawCircleSegments(ofSizes: fractions, inImageOf: size)
	}
}
