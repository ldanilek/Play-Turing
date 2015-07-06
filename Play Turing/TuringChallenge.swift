//
//  TuringChallenge.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/3/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

let lotsaChars: [Character] = [b, "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "x"]


let bt: [Character] = [b]
func bs(i: Int) -> Tape {
    return Array(count: i, repeatedValue: b)
}
func bs(t: Tape) -> Tape {
    return bs(t.count)
}

let MAX_CHALLENGE_INDEX = 24


extension Array {
    var random: T {
        let i = Int(rand())%self.count
        return self[i]
    }
    init(count: Int, generator: ()->T) {
        self.init()
        for var i = 0; i < count; i++ {
            self.append(generator())
        }
    }
    init(count: Int, fromArray array: [T]) {
        self.init(count: count, generator: { () -> T in
            return array.random
        })
    }
}
func makeTape(tapes: [Tape]) -> Tape {
    var mytape: [Character] = [Character]()
    for t in tapes {
        mytape = mytape + t
    }
    return mytape
}
func makeTape(tapes: Tape...) -> Tape {
    var mytape: [Character] = [Character]()
    for t in tapes {
        mytape = mytape + t
    }
    return mytape
}
func intToBinary(var i: Int) -> Tape {
    var tape: Tape = [Character]()
    while i > 0 {
        tape = [i%2==0 ? "0" : "1"] + tape
        i/=2
    }
    return tape
}
func binaryToInt(var binary: [Character]) -> Int {
    var i = 0
    while binary.count > 0 {
        i *= 2
        i += binary.removeAtIndex(0) == "0" ? 0 : 1
    }
    return i
}

class TuringChallenge: NSObject {
    // do not edit any of these instance variables except in initializer
    
    let startTape: Tape
    let goalTape: Tape
    let startIndex: Int
    let startState: State
    
    let allowedCharacters: [Character]
    let maxState: Int
    let name: String
    
    var index: Int
    
    var hintsAreFree: Bool = false
    var hints: [String] = []
    
    var requiresEndState = false
    
    var uniqueID: String {
        //return "\(startTape) \(goalTape) \(startIndex) \(startState) \(allowedCharacters) \(maxState) \(name)"
        return name
    }
    
    func addHints(hs: String...) {
        for hint in hs {
            hints.append(hint)
        }
    }
    
    func addFreeHints(hs: String...) {
        for hint in hs {
            hints.append(hint)
        }
        hintsAreFree = true
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
        self.index = 0
    }
    
    override init() {
        goalTape = [blank, blank, blank, blank, blank, "1", "1"]
        startIndex = 0
        startState = 0
        startTape = ["1", "0", "0", "0", "0", "0", "1"]
        allowedCharacters = lotsaChars//[b, "0", "1"]
        maxState = 1
        self.name = ""
        self.index = 0
    }
    
    convenience init(index: Int) {
        
        switch index {
        case 0:
            self.init(startTape: [b], goalTape: ["1"], startIndex: 0, startState: 0, allowedCharacters: [b, "1"], maxState: 0, name: "Getting Started")
            addFreeHints("Rule you need: read \""+String(b)+"\"→ write \"1\"")
        case 1:
            self.init(startTape: [b, b], goalTape: ["1", "1"], startIndex: 0, startState: 0, allowedCharacters: [b, "1"], maxState: 0, name: "Go Right")
            addFreeHints("Rule: Read \"-\", write \"1\", move Right")
        case 2:
            self.init(startTape: ["1", "1", "1", "1"], goalTape: [b,b,b,b], startIndex: 3, startState: 0, allowedCharacters: [b, "1"], maxState: 0, name: "Deletion")
            addFreeHints("Rule: Read \"1\", write \"\(b)\", and move Left")
        case 3:
            self.init(startTape: ["0", "1", "0", "0", "1", "0", "1"], goalTape: ["1", "1", "1", "1", "1", "1", "1"], startIndex: 0, startState: 0, allowedCharacters: ["0", "1"], maxState: 0, name: "All On")
            addFreeHints("Two rules: 0→1 and 1→1")
        case 4:
            let sequence: Tape = ["0","1","0","1","0","1","0"]
            self.init(startTape: Array(count: sequence.count, repeatedValue: b), goalTape: sequence, startIndex: sequence.count-1, startState: 0, allowedCharacters: [b, "0", "1"], maxState: 1, name: "Alternator")
            addFreeHints("Now you need two states", "Alternate between states q0 and q1", "q0 means write \"0\", q1 means write \"1\"")
        case 5:
            self.init(startTape: Array(count: 9, repeatedValue: b), goalTape: ["0", b, "1", b, "0", b, "1", b, "0"], startIndex: 0, startState: 0, allowedCharacters: [b, "0", "1"], maxState: 3, name: "Sequencer")
            addFreeHints("Try writing one rule at a time", "Play the machine to see what happens", "Loop through your four states")
        case 6:
            let bits = Array<Character>(count: Int(rand()%8)+5, fromArray:["0","1"])
            let flipped = bits.map { (c)->Character in
                return c=="0" ? "1" : "0"
            }
            self.init(startTape: bits, goalTape: flipped, startIndex: 0, startState: 0, allowedCharacters: ["0","1"], maxState: 0, name: "Bit flipper")
            addHints("Ones become zeros", "Zeros become ones")
        case 7:
            self.init(startTape: [b, "1", "1", "1", "1", "1", b], goalTape: [b,"0","0","0","0","0",b], startIndex: 3, startState: 0, allowedCharacters: [b,"0","1"], maxState: 0, name: "There and back")
            addHints("You only have one state", "Ones and zeros become zeros", "Blanks remain blank", "Experiment with directions")
        case 8:
            self.init(startTape: ["1", "0", "0", "0", "0", "0", "1"], goalTape: [b,b,b,b,b,"1","1"], startIndex: 0, startState: 0, allowedCharacters: [b,"0", "1"], maxState: 1, name: "Carry the one")
            requiresEndState = true
        case 9:
            let number = (Int(rand()%60)+1)*2 - 1
            var numberBits = intToBinary(number)
            var subBits = intToBinary(number+1)
            while subBits.count < numberBits.count {
                subBits = makeTape(["0"], subBits)
            }
            while subBits.count > numberBits.count {
                numberBits = makeTape(["0"], numberBits)
            }
            self.init(startTape: makeTape(numberBits, bt), goalTape: makeTape(subBits, bt), startIndex: 0, startState: 0, allowedCharacters: [b,"0","1"], maxState: 1, name: "Binary Add 1")
            addHints("Base two subtraction", "Go to the right of the digits", "0→1, 1→0")
            requiresEndState = true
        case 10:
            self.init(startTape: [b,"1", "0", "1", "0", "0", "1", "1", b], goalTape: [b,b,b,b,"1","1","1","1", b], startIndex: 1, startState: 0, allowedCharacters: [b,"0", "1"], maxState: 3, name: "Condenser")
            addHints("Move ones over", "Replace the leftmost zeros")
            requiresEndState = true
        case 11:
            var tocondense: Tape = ["1"]
            var compressed: Tape = ["1"]
            while compressed.count == 0 || compressed.count == tocondense.count {
                tocondense = Array<Character>(count: Int(rand())%5+4, fromArray: ["1", "0"])
                compressed = tocondense.filter { (c) -> Bool in
                    return c=="1"
                }
            }
            self.init(startTape: makeTape(bt, tocondense, bt), goalTape: makeTape(bt, Array(count: tocondense.count-compressed.count, repeatedValue:b), compressed, bt), startIndex: 1, startState: 0, allowedCharacters: [b,"0", "1"], maxState: 2, name: "Concise Condenser")
            addHints("If a pair is out of order,", "Perform swaps of adjacents")
            requiresEndState = true
        case 12:
            let toDup = Array(count: Int(rand())%10 + 1, repeatedValue: Character("1"))
            let placeToPutDup = Array(count: toDup.count, repeatedValue: b)
            self.init(startTape: makeTape([toDup,bt,placeToPutDup]), goalTape: makeTape([toDup,bt,toDup]), startIndex: 0, startState: 0, allowedCharacters: [b, "1"], maxState: 4, name: "Duplicator")
            addHints("This example is on Wikipedia", "Move over one at a time", "Use blanks as placeholders")
            requiresEndState = true
        case 13:
            var toSort = Array<Character>(count: Int(rand())%10+5, fromArray: ["0","1","2"])
            while toSort.filter({ (a) -> Bool in a=="1" }).count == 0 {
                toSort = Array<Character>(count: Int(rand())%10+5, fromArray: ["0","1","2"])
            }
            let sorted = toSort.sorted(<)
            self.init(startTape: makeTape([bt,toSort, bt]), goalTape: makeTape([bt, sorted, bt]), startIndex: 1, startState: 0, allowedCharacters: [b, "0", "1", "2"], maxState: 4, name: "Sort")
            addHints("If a pair is out of order,", "Perform swaps of adjacents", "This is Insertion Sort")
            requiresEndState = true
        case 14:
            let ones = Array<Character>(count: Int(rand())%18+2, repeatedValue:"1")
            let modThree = Character("\(ones.count%3)")
            self.init(startTape: makeTape(bt, bt, ones), goalTape: makeTape([modThree], bt, bs(ones)), startIndex: ones.count+1, startState: 0, allowedCharacters: [b, "0", "1", "2"], maxState: 4, name: "Modulo 3")
            addHints("Carry each one over", "Increase left digit by one mod 3", "0→1, 1→2, 2→0")
            requiresEndState = true
        case 15:
            let ones = Array<Character>(count: Int(rand())%18+2, repeatedValue:"1")
            let countBits = intToBinary(ones.count)
            self.init(startTape: makeTape(bs(countBits), bt, ones), goalTape: makeTape(countBits, bt, ones), startIndex: ones.count+countBits.count, startState: 0, allowedCharacters: [b,"0","1"], maxState: 4, name: "Binary Counter")
            addHints("Carry ones over like in Duplicator", "Use binary to add to total count", "It's like regular numbers but 1+1=10")
            requiresEndState = true
        case 16:
            let ones = Array<Character>(count: Int(rand())%18+2, repeatedValue:"1")
            let countBits = intToBinary(ones.count)
            self.init(startTape: makeTape(bt, countBits, bt,Array<Character>(count: ones.count, repeatedValue: b)), goalTape: makeTape(bt, Array<Character>(count: countBits.count, repeatedValue: b), bt, ones), startIndex: countBits.count, startState: 0, allowedCharacters: [b,"0","1"], maxState: 4, name: "Inverse Counter")
            addHints("Subtract one using binary subtraction", "Transfer this one to the right")
            requiresEndState = true
        case 17:
            let randomBinary = Array(count: 8, generator: { () -> Character in
                return ["0","1"].random
            })
            self.init(startTape: [b, "1"]+randomBinary, goalTape: ["1"]+randomBinary+["0"], startIndex: 9, startState: 1, allowedCharacters: [b, "0", "1"], maxState: 1, name: "Multiply by two")
            
            addHints("q1 means carry 0", "q0 means carry 1")
        case 18:
            let bits = Array<Character>(count: 8, fromArray: ["0","1"])
            let integer = binaryToInt(bits)
            let bitShift = Int(rand())%4 + 1
            let bitShiftBits = intToBinary(bitShift)
            let bitShiftedBits = intToBinary(integer >> bitShift)
            let padded = Array<Character>(count: 8-bitShiftedBits.count, repeatedValue: "0") + bitShiftedBits
            let rightPadding = Array<Character>(count: 3+bitShiftBits.count, repeatedValue: b)
            let start = makeTape(bt, bits, [">", ">"], bitShiftBits, bt)
            let end = makeTape(bt, padded, rightPadding)
            self.init(startTape: start, goalTape: end, startIndex: 10+bitShiftBits.count, startState: 0, allowedCharacters: [b, "0", "1", ">"], maxState: 6, name: "Bit shifter")
            addHints("Subtract one from the right side", "Shift digits to the right")
            requiresEndState = true
        case 19:
            // for copier
            let toDuplicate: [Character] = Array<Character>(count: 6, fromArray:["0", "1"])
            let blanks: [Character] = Array(count: toDuplicate.count, repeatedValue: b)
            let firstPart: [Character] = bt + toDuplicate + bt
            let duplicateStart: [Character] = firstPart + blanks + bt
            let duplicateGoal: [Character] = firstPart + toDuplicate + bt
            self.init(startTape: duplicateStart, goalTape: duplicateGoal, startIndex: 1, startState: 0, allowedCharacters: [b, "0", "1", "x", "a", "b"], maxState: 4, name: "Copier")
            addHints("You have three spare characters", "Use x to separate original from copy", "Replace 0 with a, 1 with b")
            requiresEndState = true
        case 20:
            let len = rand()%2==0 ? 6 : 4
            let firstBits = Array<Character>(count: len, fromArray: ["0","1"])
            let nextBits = Array<Character>(count: len, fromArray: ["0","1"])
            var xored = Array<Character>()
            for var i = 0; i < len; i++ {
                xored.append(firstBits[i]==nextBits[i] ? "0" : "1")
            }
            let blanks = Array(count: len, repeatedValue: b)
            self.init(startTape: makeTape([firstBits,["^"],nextBits,["="],blanks]), goalTape: makeTape([blanks, bt, blanks, bt, xored]), startIndex: 0, startState: 0, allowedCharacters: [b, "0", "1", "^", "="], maxState: 5, name: "XOR")
            addHints("The title \"XOR\" means exclusive or", "XOR the first digits of each number", "Replace in left number with \(b)", "Replace in right number with ^")
            requiresEndState = true
        case 21:
            let oddNumber =  2*Int(rand()%4+2) + 1
            var countOnes = 0
            var bits = Array<Character>()
            while countOnes == 0 {
                bits = Array(count: oddNumber, fromArray:["0","1"])
                for bit in bits {
                    if bit == "1" {
                        countOnes++
                    }
                }
            }
            let mode: Character = (countOnes*2 > oddNumber) ? "1" : "0"
            self.init(startTape: makeTape([bt, bits, bt]), goalTape: makeTape([bt,Array(count: bits.count/2, repeatedValue: b),[mode],Array(count: bits.count/2, repeatedValue: b),bt]), startIndex: 1, startState: 0, allowedCharacters: [b,"0","1"], maxState: 6, name: "Mode")
            addHints("The title \"Mode\" is a statistics term", "You have an odd set of 0's and 1's", "Therefore, Mode = Median", "First sort, then remove extremes")
        case 22:
            let first = Int(rand())%40 + 2
            let firstBits = intToBinary(first)
            let second = Int(rand())%40 + 2
            let secondBits = intToBinary(second)
            let sumBits = intToBinary(first + second)
            let totalLength = firstBits.count + sumBits.count + 3
            let neededExtra = Array(count: totalLength-firstBits.count-secondBits.count-3, repeatedValue: b)
            let finalPad = Array(count: totalLength - sumBits.count - 1, repeatedValue: b)
            self.init(startTape: makeTape([bt, firstBits, bt, neededExtra, secondBits, bt]), goalTape: makeTape([finalPad, sumBits, bt]), startIndex: firstBits.count, startState: 0, allowedCharacters: [b,"0","1"], maxState: 6, name: "Addition")
            addHints("Subtract one from the left number", "Add that one to the right number",  "There are two methods to subtract")
            //requiresEndState = true
        case 23:
            let spacing = Int(rand())%8+2
            self.init(startTape: makeTape(["1"], bs(spacing),bt,bs(spacing), ["1"]), goalTape: makeTape(["1"], bs(spacing), ["1"], bs(spacing), ["1"]), startIndex: 0, startState: 0, allowedCharacters: [b, "0", "1"], maxState: 3, name: "Bisect")
            addHints("Fill with zeroes, then remove edges", "If you run out of states, re-use", "Try working out rules on paper")
            requiresEndState = true
        case 24:
            let spacing = Int(rand())%7+2
            let blankBits = Array(count: spacing, repeatedValue: b)
            self.init(startTape: makeTape(["1"], blankBits, bt, blankBits, bt, blankBits, ["1"]), goalTape: makeTape(["1"], blankBits, ["1"], blankBits, ["1"], blankBits, ["1"]), startIndex: 0, startState: 0, allowedCharacters: [b, "0","1"], maxState: 8, name: "Trisect")
            addHints("Find one third first:", "Remove twice as fast from one side", "Then bisect that third and the end")
            requiresEndState = true
        default:
            self.init()
        }
        self.index = index
    }
    
    class func challengeAccuracy(forIndex index: Int) -> Double {
        let dataPoints = 25
        var countSolvedTimes = 0
        for var i = 0; i < dataPoints; i++ {
            var challenge = TuringChallenge(index: index)
            var machine = TuringMachine(rules: challenge.storedRules(), initialTape: challenge.startTape, tapeIndex: challenge.startIndex, initialState: challenge.startState)
            let mustEndState: Int? = challenge.requiresEndState ? challenge.maxState+1 : nil
            let completed = machine.solve(challenge.goalTape, finalStateMustBe: mustEndState)
            if completed {
                countSolvedTimes++
            }
        }
        return Double(countSolvedTimes)/Double(dataPoints)
    }
}
