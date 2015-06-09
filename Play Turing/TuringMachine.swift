//
//  TuringMachine.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

typealias State = Int
typealias Tape = [Character]
enum Direction {
    case Left
    case Right
}
typealias Callback = (Rule, State, Tape, Int) -> Void
func emptyCallback(rule: Rule, state: State, tape: Tape, index: Int) {}

// a rule can be uniquely identified by its condition. make sure never to have two rules with the same condition
func == (r1: Rule, r2: Rule) -> Bool {
    return r1.state == r2.state && r1.read == r2.read
}

struct Rule: Hashable {
    let state: State
    let read: Character
    let newState: State
    let write: Character
    let direction: Direction
    init(state: State, read: Character, newState: State, write: Character, direction: Direction) {
        self.state = state
        self.read = read
        self.newState = newState
        self.write = write
        self.direction = direction
    }
    init(movingDirection: Direction, state: State, read: Character) {
        self.init(state: state, read: read, newState: state, write: read, direction: movingDirection)
    }
    var hashValue: Int {
        return 31 &* state.hashValue &+ read.hashValue
    }
    // returns plist
    func storable() -> AnyObject {
        var dict = NSMutableDictionary()
        dict["state"] = NSNumber(integer: self.state)
        dict["newState"] = NSNumber(integer: newState)
        dict["read"] = NSString(string: String(read))
        dict["write"] = NSString(string: String(write))
        dict["direction"] = NSNumber(bool: direction == Direction.Left)
        return dict.copy()
    }
    init(stored: AnyObject) {
        let dict = stored as! NSDictionary
        self.state = (dict["state"] as! NSNumber).integerValue
        self.newState = (dict["newState"] as! NSNumber).integerValue
        self.read = Character(String(dict["read"] as! NSString))
        self.write = Character(String(dict["write"] as! NSString))
        self.direction = (dict["direction"] as! NSNumber).boolValue ? Direction.Left : Direction.Right
    }
}

let blank: Character = "-"
let b = blank

class TuringMachine: NSObject {
    let bounded: Bool
    var tape: Tape
    var index: Int
    var state: State
    let rules: [Rule]
    
    var statesUsed = Set<Int>()
    var rulesUsed = Set<Rule>()
    var charsSeen = Set<Character>()
    
    init(rules: [Rule], initialTape: Tape = [blank], tapeIndex: Int = 0, initialState: State = 0, bounded: Bool = true) {
        self.rules = rules
        self.state = initialState
        self.tape = initialTape
        self.index = tapeIndex
        self.bounded = bounded
    }
    
    func left() {
        if index == 0 && !bounded {
            tape = [blank] + tape
            index++
        }
        index--
    }
    
    func right() {
        if index == tape.count - 1 && !bounded {
            tape = tape + [blank]
        }
        index++
    }
    
    func read() -> Character {
        return tape[index]
    }
    
    func write(c: Character) {
        tape[index] = c
    }
    
    func runRule(rule: Rule) {
        self.statesUsed.insert(rule.newState)
        self.rulesUsed.insert(rule)
        self.charsSeen.insert(rule.write)
        
        self.state = rule.newState
        self.write(rule.write)
        if rule.direction==Direction.Right {
            self.right()
        } else {
            self.left()
        }
    }
    
    func ruleToUse() -> Rule? {
        let read = self.read()
        
        self.statesUsed.insert(self.state)
        self.charsSeen.insert(read)
        
        for rule in self.rules {
            if rule.read == read && rule.state == self.state {
                return rule
            }
        }
        return nil
    }
    
    func step() -> Rule? {
        if index<0 || index>=tape.count {
            return nil
        }
        if let rule = self.ruleToUse() {
            self.runRule(rule)
            return rule
        } else {
            return nil
        }
    }
    
    func solve(goalTape: Tape) -> Bool {
        var iterations = 0
        while iterations < 1000 {
            if tape == goalTape {
                return true
            }
            let ruleUsed = step()
            if let rule = ruleUsed {
                
            } else {
                return false
            }
            if index < 0 || index >= tape.count {
                return false
            }
            iterations++
        }
        return false
    }
}
