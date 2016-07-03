//
//  Poll.swift
//  Pollarious
//
//  Created by Julian Dunskus on 28/06/16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation

class Poll {
	
	var question = ""
	var highestOptionID = 0
	var options: [Option] = []
	var lastVoteChange: TimeInterval = NSDate.timeIntervalSinceReferenceDate()
	var lastVoteCount: TimeInterval = 0
	var voteTotal = 0
	var voteMax = 0
	var votes: [UUID: Int] = [:] {
		didSet {
			lastVoteChange = NSDate.timeIntervalSinceReferenceDate()
		}
	}
	private var cachedVoteCount: [Int: Int] = [:]
	var voteCount: [Int: Int] {
		get {
			if lastVoteCount < lastVoteChange {
				var dict: [Int: Int] = [:]
				voteMax = 0
				voteTotal = 0
				for vote in votes {
					dict[vote.value] = (dict[vote.value] ?? 0) + 1
					voteTotal += 1
					voteMax = max(voteMax, dict[vote.value]!)
				}
				cachedVoteCount = dict
				lastVoteCount = NSDate.timeIntervalSinceReferenceDate()
			}
			return cachedVoteCount
		}
	}
	
	init() {
		print("New Poll Created!")
	}
	
	convenience init(from items: [URLQueryItem]) {
		
		self.init()
		
		for item in items {
			if item.name.hasPrefix("question") {
				question = item.value!
				continue
			}
			if addOption(from: item) { continue }
			if addVote  (from: item) { continue }
		}
		
		for option in options {
			print("Loading: Option \(option.id): \(option.name)")
		}
		for vote in votes {
			print("Loading: User \(vote.key) voted for \(vote.value)")
		}
	}
	
	func addVote(from item: URLQueryItem) -> Bool {
		if item.name.hasPrefix("vote") {
			print("string: \(item.name.components(separatedBy: "vote"))")
			if let uuid = UUID(uuidString: item.name.components(separatedBy: "vote").last!) {
				votes[uuid] = Int(item.value!)
				return true
			}
		}
		return false
	}
	
	func addOption(from item: URLQueryItem) -> Bool {
		if item.name.hasPrefix("option") {
			if let id = Int(item.name.components(separatedBy: "option").last!) {
				addOption(named: item.value!, withID: id)
				return true
			}
		}
		return false
	}
	
	func addOption(named name: String, withID possibleID: Int? = nil) {
		let id = possibleID ?? highestOptionID + 1 // too bad I can't use this as a default parameter, since it crashes the compiler
		if id > highestOptionID {
			highestOptionID = id
		}
		options.append(Option(named: name, withID: id))
	}
	
	func remove(at index: Int) {
		let option = options[index]
		options.remove(at: index)
		for vote in votes {
			if vote.value == option.id {
				votes.removeValue(forKey: vote.key) // this also removes the key ofc
			}
		}
	}
	
	func toQueryItems() -> [URLQueryItem] {
		var items: [URLQueryItem] = []
		
		items.append(URLQueryItem(name: "question", value: question))
		for option in options {
			items.append(option.toQueryItem())
		}
		for vote in votes {
			items.append(URLQueryItem(name: "vote\(vote.key)", value: "\(vote.value)"))
		}
		
		return items
	}
	
	func votes(for option: Option) -> Int {
		return votes(forID: option.id)
	}
	
	func votes(forID id: Int) -> Int {
		return voteCount[id] ?? 0
	}
	
	func votePercentage(for option: Option) -> Double {
		return votePercentage(forID: option.id)
	}
	
	func votePercentage(forID id: Int) -> Double {
		if voteTotal == 0 { // don't divide by zero
			return 0
		}
		return Double(votes(forID: id)) / Double(voteTotal)
	}
	
	func fractionOfMax(for option: Option) -> Double {
		return fractionOfMax(forID: option.id)
	}
	
	func fractionOfMax(forID id: Int) -> Double {
		if voteMax == 0 { // don't divide by zero
			return 0
		}
		return Double(votes(forID: id)) / Double(voteMax)
	}
}

extension Poll: Equatable {}

func ==(lhs: Poll, rhs: Poll) -> Bool {
	if lhs.options.count != rhs.options.count {
		return false
	}
	
	for i in 0 ..< lhs.options.count {
		if lhs.options[i].name != rhs.options[i].name {
			return false
		}
	}
	
	return true
}

class Option {
	
	var id: Int
	var name: String
	
	init(named name: String, withID id: Int) {
		self.id = id
		self.name = name
	}
	
	func toQueryItem() -> URLQueryItem {
		return URLQueryItem(name: "option\(id)", value: name)
	}
}
