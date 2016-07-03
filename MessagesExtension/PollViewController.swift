//
//  PollViewController.swift
//  Pollarious
//
//  Created by Julian Dunskus on 28/06/16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import UIKit

class PollViewController: UITableViewController {
	
	weak var messagesController: MessagesViewController!
	weak var questionField: UITextField!
	
	var poll: Poll!
	var userUUID: UUID!
	var chosenID = -1
	
	override func viewDidLoad() {
		super.viewDidLoad()
		chosenID = poll.votes[userUUID] ?? -1
	}
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let header = view as? UITableViewHeaderFooterView {
			header.textLabel?.textColor = UIColor(white: 0, alpha: 0.75)
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 && messagesController.presentationStyle == .expanded {
			return 140 // make some space for bar up top
		}
		return 30
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section == 2 {
			return 60
		}
		return 30
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return ["Edit poll question", "Tap to choose option", "Send message"][section]
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 1 ? poll.options.count + 1 : 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell")!
			
			questionField = cell.viewWithTag(10) as! UITextField
			questionField.text = poll.question
			
			return cell
		}
		
		if indexPath.section == 2 {
			return tableView.dequeueReusableCell(withIdentifier: "DoneCell")!
		}
		
		if indexPath.row == poll.options.count {
			return tableView.dequeueReusableCell(withIdentifier: "AddCell")!
		}
		let option = poll.options[indexPath.row]
		print("User \(userUUID) pressed on option \(option.id): \(option.name)")
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")!
		let numLabel = cell.viewWithTag(10) as? UILabel
		let lowerLabel = cell.viewWithTag(20) as? UILabel
		let upperLabel = cell.viewWithTag(21) as? UILabel
		
		numLabel?.text = "\(poll.votes(for: option))"
		lowerLabel?.text = option.name
		upperLabel?.text = option.name
		
		let filtered = cell.viewWithTag(30)?.constraints.filter({ (constraint) in
			return constraint.identifier == "barConstraint" ? true : false
		})
		if let barConstraint = filtered?.first {
			barConstraint.setMultiplier(to: CGFloat(0.001 + poll.fractionOfMax(for: option))) // setting the multiplier to 0 removes it, apparently
		}
		cell.setNeedsLayout()
		
		if option.id == (chosenID) {
			cell.viewWithTag(31)?.backgroundColor = UIColor.white()
		} else {
			cell.viewWithTag(31)?.backgroundColor = UIColor(white: 1, alpha: 0.75)
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		defer {
			tableView.deselectRow(at: indexPath, animated: true)
		}
		if indexPath.section == 0 {
			questionField.becomeFirstResponder()
			return
		}
		if indexPath.section == 2 {
			addPressed()
			return
		}
		if indexPath.row == poll.options.count {
			addPressed()
			return
		}
		let option = poll.options[indexPath.row]
		if option.id == chosenID {
			poll.votes.removeValue(forKey: userUUID)
			chosenID = -1
		} else {
			poll.votes[userUUID] = option.id
			chosenID = option.id
		}
		tableView.reloadData()
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		if indexPath.row != poll.options.count {
			return [UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
				self.poll.remove(at: indexPath.row)
				self.tableView.reloadData()
			})]
		}
		return nil
	}
	
	@IBAction func addPressed() {
		messagesController.requestPresentationStyle(.expanded)
		showTextFieldAlert(titled: "New Option", placeholder: "Option Name") { (text) in
			self.poll.addOption(named: text)
			self.tableView.reloadData()
		}
	}
	
	@IBAction func donePressed() {
		messagesController.poll(poll, didFinishEditingWithChoice: chosenID)
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func questionChanged(_ textField: UITextField) {
		poll.question = textField.text ?? ""
	}
}

extension PollViewController: UITextFieldDelegate {
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return messagesController.textFieldShouldBeginEditing(textField)
	}
}
