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

class TuringChallenge: NSObject {
    let startTape: Tape
    let goalTape: Tape
    let startIndex: Int
    let startState: State
    
    let allowedCharacters: [Character]
    let maxState: Int
    let name: String
    
    var index: Int
    
    var uniqueID: String {
        //return "\(startTape) \(goalTape) \(startIndex) \(startState) \(allowedCharacters) \(maxState) \(name)"
        return name
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
        
        // for counter and inverse counter
        let ones = Array<Character>(count: Int(rand())%18+2, repeatedValue:"1")
        var one = Character("\(ones.count%2)")
        var two = Character("\((ones.count/2)%2)")
        var four = Character("\((ones.count/4)%2)")
        var eight = Character("\((ones.count/8)%2)")
        var sixteen = Character("\((ones.count/16)%2)")
        if sixteen == "0" {
            sixteen = b
            if eight == "0" {
                eight = b
                if four == "0" {
                    four = b
                    if two == "0" {
                        two = b
                        if one == "0" {
                            one = b
                        }
                    }
                }
            }
        }
        
        switch index {
        case 0:
            self.init(startTape: [b], goalTape: ["1"], startIndex: 0, startState: 0, allowedCharacters: [b, "1"], maxState: 0, name: "Getting Started")
        case 1:
            self.init(startTape: ["1", "1", "1", "1"], goalTape: [b,b,b,b], startIndex: 3, startState: 0, allowedCharacters: [b, "1"], maxState: 0, name: "Deletion")
        case 2:
            self.init(startTape: ["0", "1", "0", "0", "1", "0", "1"], goalTape: ["1", "1", "1", "1", "1", "1", "1"], startIndex: 0, startState: 0, allowedCharacters: [b, "0", "1"], maxState: 0, name: "All On")
        case 3:
            let sequence: Tape = ["0","1","0","1","0","1","0"]
            self.init(startTape: Array(count: sequence.count, repeatedValue: b), goalTape: sequence, startIndex: sequence.count-1, startState: 0, allowedCharacters: [b, "0", "1"], maxState: 1, name: "Alternator")
        case 4:
            self.init(startTape: Array(count: 9, repeatedValue: b), goalTape: ["1", b, "0", b, "1", b, "0", b, "1"], startIndex: 0, startState: 0, allowedCharacters: [b, "0", "1"], maxState: 3, name: "Sequencer")
        case 5:
            let bits = Array<Character>(count: Int(rand()%8)+5, fromArray:["0","1"])
            let flipped = bits.map { (c)->Character in
                return c=="0" ? "1" : "0"
            }
            self.init(startTape: bits, goalTape: flipped, startIndex: 0, startState: 0, allowedCharacters: [b,"0","1"], maxState: 0, name: "Bit flipper")
        case 6:
            self.init(startTape: [b, "1", "1", "1", "1", "1", b], goalTape: [b,"0","0","0","0","0",b], startIndex: 3, startState: 0, allowedCharacters: [b,"0","1"], maxState: 0, name: "There and back")
        case 7:
            self.init(startTape: ["1", "0", "0", "0", "0", "0", "1"], goalTape: [b,b,b,b,b,"1","1"], startIndex: 0, startState: 0, allowedCharacters: [b,"0", "1"], maxState: 1, name: "Carry the one")
        case 8:
            let tosub: Int = [1,2].random
            self.init(startTape: ["2","0","1",Character("\(tosub)"),"0","0",b], goalTape: ["2","0","1",Character("\(tosub-1)"),"2","2",b], startIndex: 0, startState: 0, allowedCharacters: [b,"0","1","2"], maxState: 1, name: "Ternary Subtract")
        case 9:
            self.init(startTape: [b,"1", "0", "1", "0", "0", "1", "1", b], goalTape: [b,b,b,b,"1","1","1","1", b], startIndex: 1, startState: 0, allowedCharacters: [b,"0", "1"], maxState: 3, name: "Condenser")
        case 10:
            var tocondense: Tape = ["1"]
            var compressed: Tape = ["1"]
            while compressed.count == 0 || compressed.count == tocondense.count {
                tocondense = Array<Character>(count: Int(rand())%5+4, fromArray: ["1", "0"])
                compressed = tocondense.filter { (c) -> Bool in
                    return c=="1"
                }
            }
            self.init(startTape: makeTape(bt, tocondense, bt), goalTape: makeTape(bt, Array(count: tocondense.count-compressed.count, repeatedValue:b), compressed, bt), startIndex: 1, startState: 0, allowedCharacters: [b,"0", "1"], maxState: 2, name: "Concise Condenser")
        case 11:
            let toDup = Array(count: Int(rand())%10 + 1, repeatedValue: Character("1"))
            let placeToPutDup = Array(count: toDup.count, repeatedValue: b)
            self.init(startTape: makeTape([bt,toDup,bt,placeToPutDup,bt]), goalTape: makeTape([bt,toDup,bt,toDup,bt]), startIndex: 1, startState: 0, allowedCharacters: [b, "1"], maxState: 4, name: "Duplicator")
        case 12:
            let toSort = Array<Character>(count: Int(rand())%10+5, fromArray: ["0","1","2"])
            let sorted = toSort.sorted(<)
            self.init(startTape: makeTape([bt,toSort, bt]), goalTape: makeTape([bt, sorted, bt]), startIndex: 1, startState: 0, allowedCharacters: [b, "0", "1", "2"], maxState: 4, name: "Sort")
            
        case 13:
            self.init(startTape: [b,b,b,b,b,b]+ones, goalTape: [sixteen, eight, four, two, one ,b]+ones, startIndex: ones.count+5, startState: 0, allowedCharacters: [b,"0","1"], maxState: 4, name: "Binary Counter")
        case 14:
            self.init(startTape: [b,sixteen, eight, four, two, one ,b]+Array<Character>(count: ones.count, repeatedValue: b), goalTape: [b,b,b,b,b,b,b]+ones, startIndex: 5, startState: 0, allowedCharacters: [b,"0","1"], maxState: 4, name: "Inverse Counter")
        case 15:
            let randomBinary = Array(count: 8, generator: { () -> Character in
                return ["0","1"].random
            })
            self.init(startTape: [b, b, "1"]+randomBinary+[b], goalTape: [b, "1"]+randomBinary+["0", b], startIndex: 10, startState: 1, allowedCharacters: [b, "0", "1"], maxState: 1, name: "Multiply by two")
        case 16:
            // for copier
            let toDuplicate: [Character] = Array<Character>(count: 6, fromArray:["0", "1"])
            let blanks: [Character] = Array(count: toDuplicate.count, repeatedValue: b)
            let firstPart: [Character] = bt + toDuplicate + bt
            let duplicateStart: [Character] = firstPart + blanks + bt
            let duplicateGoal: [Character] = firstPart + toDuplicate + bt
            self.init(startTape: duplicateStart, goalTape: duplicateGoal, startIndex: 1, startState: 0, allowedCharacters: [b, "0", "1", "x", "a", "b"], maxState: 4, name: "Copier")
        
        case 17:
            let len = rand()%2==0 ? 6 : 4
            let firstBits = Array<Character>(count: len, fromArray: ["0","1"])
            let nextBits = Array<Character>(count: len, fromArray: ["0","1"])
            var xored = Array<Character>()
            for var i = 0; i < len; i++ {
                xored.append(firstBits[i]==nextBits[i] ? "0" : "1")
            }
            let blanks = Array(count: len, repeatedValue: b)
            self.init(startTape: makeTape([firstBits,["^"],nextBits,["="],blanks]), goalTape: makeTape([blanks, bt, blanks, bt, xored]), startIndex: 0, startState: 0, allowedCharacters: [b, "0", "1", "^", "="], maxState: 5, name: "XOR")
        
        case 18:
            let oddNumber =  2*Int(rand()%4+2) + 1
            let bits = Array<Character>(count: oddNumber, fromArray:["0","1"])
            var countOnes = 0
            for bit in bits {
                if bit == "1" {
                    countOnes++
                }
            }
            let mode: Character = (countOnes*2 > oddNumber) ? "1" : "0"
            self.init(startTape: makeTape([bt, bits, bt]), goalTape: makeTape([bt,Array(count: bits.count/2, repeatedValue: b),[mode],Array(count: bits.count/2, repeatedValue: b),bt]), startIndex: 1, startState: 0, allowedCharacters: [b,"0","1"], maxState: 7, name: "Mode")
        case 19:
            let first = Int(rand())%40 + 2
            let firstBits = intToBinary(first)
            let second = Int(rand())%40 + 2
            let secondBits = intToBinary(second)
            let sumBits = intToBinary(first + second)
            let totalLength = firstBits.count + sumBits.count + 3
            let neededExtra = Array(count: totalLength-firstBits.count-secondBits.count-3, repeatedValue: b)
            let finalPad = Array(count: totalLength - sumBits.count - 1, repeatedValue: b)
            self.init(startTape: makeTape([bt, firstBits, bt, neededExtra, secondBits, bt]), goalTape: makeTape([finalPad, sumBits, bt]), startIndex: firstBits.count, startState: 0, allowedCharacters: [b,"0","1"], maxState: 6, name: "Addition")
          
        case 20:
            let spacing = Int(rand())%7+2
            let blankBits = Array(count: spacing, repeatedValue: b)
            self.init(startTape: makeTape([b, "1"], blankBits, bt, blankBits, bt, blankBits, ["1", b]), goalTape: makeTape([b, "1"], blankBits, ["1"], blankBits, ["1"], blankBits, ["1", b]), startIndex: 1, startState: 0, allowedCharacters: [b, "0","1"], maxState: 16, name: "Trisect") // seriously? 17 states? that's the best I can do
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
            let completed = machine.solve(challenge.goalTape)
            if completed {
                countSolvedTimes++
            }
        }
        return Double(countSolvedTimes)/Double(dataPoints)
    }
}
