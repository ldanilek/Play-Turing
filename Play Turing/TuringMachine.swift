//
//  TuringMachine.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit
let MAIN_FONT_NAME = "Menlo"//"Bangla Sangam MN"
let RULE_FONT_SIZE: CGFloat = 13

typealias State = Int
typealias Tape = [Character]
enum Direction {
    case left
    case right
    var opposite: Direction {
        return self == .left ? .right : .left
    }
}
typealias Callback = (Rule, State, Tape, Int) -> Void
func emptyCallback(_ rule: Rule, state: State, tape: Tape, index: Int) {}

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
    func stringForState(_ state: State) -> NSAttributedString {
        let s = "q\(state)"
        let string = NSAttributedString(string: s, attributes: [NSFontAttributeName: UIFont(name: MAIN_FONT_NAME, size: RULE_FONT_SIZE)!])
        return string
    }
    func stringForChar(_ char: Character) -> NSAttributedString {
        var string: NSAttributedString = NSAttributedString()
        if #available(iOS 8.2, *) {
            string = NSAttributedString(string: "\(char)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: RULE_FONT_SIZE, weight: UIFontWeightBlack)])
        } else {
            string = NSAttributedString(string: "\(char)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: RULE_FONT_SIZE)])
            // Fallback on earlier versions
        }
        return string
    }
    func stringForDirection() -> NSAttributedString {
        let d = direction==Direction.left ? "⬅︎" : "➡︎"
        let string = NSAttributedString(string: d, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: RULE_FONT_SIZE)])
        return string
    }
    var preview: NSAttributedString {
        let mainAttributes = [NSFontAttributeName: UIFont(name: MAIN_FONT_NAME, size: RULE_FONT_SIZE)!]
        let str = NSMutableAttributedString(string: "Read ", attributes: mainAttributes)
        let inStr = NSAttributedString(string: " in ", attributes: mainAttributes)
        let arrow = NSAttributedString(string: " ⇒ ", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: RULE_FONT_SIZE)])
        let move = NSAttributedString(string: "move ", attributes: mainAttributes)
        let comma = NSAttributedString(string: ", ", attributes: mainAttributes)
        let setTo = NSAttributedString(string: "set to ", attributes: mainAttributes)
        let writeStr = NSAttributedString(string: "write ", attributes: mainAttributes)
        
        str.append(stringForChar(read))
        str.append(inStr)
        str.append(stringForState(state))
        str.append(arrow)
        
        if newState == state {
            if read == write {
                str.append(move)
            } else {
                str.append(writeStr)
                str.append(stringForChar(write))
                str.append(comma)
            }
        } else {
            if read == write {
                str.append(setTo)
                str.append(stringForState(newState))
                str.append(comma)
            } else {
                str.append(writeStr)
                str.append(stringForChar(write))
                str.append(comma)
                str.append(setTo)
                str.append(stringForState(newState))
                str.append(comma)
            }
        }
        str.append(stringForDirection())
        return str.copy() as! NSAttributedString
    }
    // returns plist
    func storable() -> AnyObject {
        let dict = NSMutableDictionary()
        dict["state"] = NSNumber(value: self.state as Int)
        dict["newState"] = NSNumber(value: newState as Int)
        dict["read"] = NSString(string: String(read))
        dict["write"] = NSString(string: String(write))
        dict["direction"] = NSNumber(value: (direction == Direction.left) as Bool)
        return dict.copy() as AnyObject
    }
    init(stored: AnyObject) {
        let dict = stored as! NSDictionary
        self.state = (dict["state"] as! NSNumber).intValue
        self.newState = (dict["newState"] as! NSNumber).intValue
        self.read = Character(String(dict["read"] as! NSString))
        self.write = Character(String(dict["write"] as! NSString))
        self.direction = (dict["direction"] as! NSNumber).boolValue ? Direction.left : Direction.right
    }
}

let blank: Character = "-"
let b = blank
let endState = -1

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
            index += 1
        }
        index -= 1
    }
    
    func right() {
        if index == tape.count - 1 && !bounded {
            tape = tape + [blank]
        }
        index += 1
    }
    
    func read() -> Character {
        return tape[index]
    }
    
    func write(_ c: Character) {
        tape[index] = c
    }
    
    func runRule(_ rule: Rule) {
        self.statesUsed.insert(rule.newState)
        self.rulesUsed.insert(rule)
        self.charsSeen.insert(rule.write)
        
        self.state = rule.newState
        self.write(rule.write)
        if rule.direction==Direction.right {
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
    
    func solve(_ goalTape: Tape, finalStateMustBe: Int?) -> Bool {
        var iterations = 0
        while iterations < 1000 {
            if let finalState = finalStateMustBe {
                if tape == goalTape && state == finalState {
                    return true
                }
            } else if tape == goalTape {
                return true
            }
            if index < 0 || index >= tape.count {
                return false
            }
            let ruleUsed = step()
            if ruleUsed == nil {
                return false
            }
            iterations += 1
        }
        return false
    }
}
