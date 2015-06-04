//
//  TuringChallenge.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/3/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

let lotsaChars: [Character] = [b, "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "x"]

// for copier
let toDuplicate: [Character] = ["0", "1", "1", "0", "0", "1"]
let blanks: [Character] = Array(count: toDuplicate.count, repeatedValue: b)
let bt: [Character] = [b]
let firstPart: [Character] = bt + toDuplicate + bt
let duplicateStart: [Character] = firstPart + blanks + bt
let duplicateGoal: [Character] = firstPart + toDuplicate + bt

class TuringChallenge: NSObject {
    let startTape: Tape
    let goalTape: Tape
    let startIndex: Int
    let startState: State
    
    let allowedCharacters: [Character]
    let maxState: Int
    let name: String
    
    var uniqueID: String {
        return "\(startTape) \(goalTape) \(startIndex) \(startState) \(allowedCharacters) \(maxState) \(name)"
    }
    
    func storeRules(rules: [Rule]) {
        let r = NSArray(array: rules.map { (rule)->AnyObject in
            return rule.storable()
            })
        NSUserDefaults.standardUserDefaults().setObject(r, forKey: uniqueID)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func storedRules() -> [Rule] {
        let r = NSUserDefaults.standardUserDefaults().objectForKey(uniqueID) as? [AnyObject]
        return (r?.map { (obj)->Rule in
            return Rule(stored: obj)
        }) ?? []
    }
    
    init(startTape: Tape, goalTape: Tape, startIndex: Int, startState: State, allowedCharacters: [Character] = lotsaChars, maxState: Int = 10, name: String = "") {
        self.startTape = startTape
        self.goalTape = goalTape
        assert(startTape.count == goalTape.count, "Tapes must be the same length")
        self.startIndex = startIndex
        self.startState = startState
        self.allowedCharacters = allowedCharacters
        self.maxState = maxState
        self.name = name
    }
    
    override init() {
        goalTape = [blank, blank, blank, blank, blank, "1", "1"]
        startIndex = 0
        startState = 0
        startTape = ["1", "0", "0", "0", "0", "0", "1"]
        allowedCharacters = lotsaChars//[b, "0", "1"]
        maxState = 1
        self.name = ""
    }
    
    convenience init(index: Int) {
        switch index {
        case 0:
            self.init(startTape: ["1", "1", "1", "1"], goalTape: [b,b,b,b], startIndex: 3, startState: 0, allowedCharacters: [b, "1"], maxState: 0, name: "Deletion")
        case 1:
            self.init(startTape: [b, "1", "1", "1", "1", "1", b], goalTape: [b,"0","0","0","0","0",b], startIndex: 3, startState: 0, allowedCharacters: [b,"0","1"], maxState: 0, name: "There and back")
        case 3:
            self.init(startTape: ["1", "0", "0", "0", "0", "0", "1"], goalTape: [b,b,b,b,b,"1","1"], startIndex: 0, startState: 0, allowedCharacters: [b,"0", "1"], maxState: 1, name: "Carry the one")
        case 4:
            self.init(startTape: ["2","0","1","2","0","0",b], goalTape: ["2","0","1","1","2","2",b], startIndex: 0, startState: 0, allowedCharacters: [b,"0","1","2"], maxState: 1, name: "Subtract")
        case 2:
            self.init(startTape: ["1","0","1","1","0","0","1"], goalTape: ["0","1","0","0","1","1","0"], startIndex: 0, startState: 0, allowedCharacters: [b,"0","1"], maxState: 0, name: "Bit flipper")
        case 8:
            self.init(startTape: [b, "1", "1", "1", "1", "1", b, b, b, b, b,b, b], goalTape: [b, "1", "1", "1", "1", "1", b, "1", "1", "1", "1","1", b], startIndex: 1, startState: 0, allowedCharacters: [b, "1"], maxState: 4, name: "Duplicator")
        case 10:
            self.init(startTape: duplicateStart, goalTape: duplicateGoal, startIndex: 1, startState: 0, allowedCharacters: [b, "0", "1", "x", "a", "b"], maxState: 4, name: "Copier")
        case 5:
            self.init(startTape: [b,"1", "0", "1", "0", "0", "1", "1", b], goalTape: [b,b,b,b,"1","1","1","1", b], startIndex: 1, startState: 0, allowedCharacters: [b,"0", "1"], maxState: 3, name: "Condenser")
        case 6:
            self.init(startTape: [b,"1", "0", "1", "1", "0", "1", "0", "0", "1", "0", b], goalTape: [b,b,b,b,b,b,"1","1","1","1","1", b], startIndex: 1, startState: 0, allowedCharacters: [b,"0", "1"], maxState: 2, name: "Concise Condenser")
        case 7:
            self.init(startTape: [b, "2", "1", "0", "1", "1", "2", "0", "1", "2", "0", "2", b], goalTape: [b, "0", "0", "0", "1", "1", "1", "1", "2", "2", "2", "2", b], startIndex: 1, startState: 0, allowedCharacters: [b, "0", "1", "2"], maxState: 4, name: "Sort")
        default:
            self.init()
        }
    }
}
