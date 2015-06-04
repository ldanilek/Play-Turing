//
//  Play_TuringTests.swift
//  Play TuringTests
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit
import XCTest

class Play_TuringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testTuringMachine() {
        let rule = Rule(state: 0, read: "1", newState: 1, write: blank, direction: .Right)
        let rule2 = Rule(state: 1, read: "0", newState: 1, write: blank, direction: .Right)
        let rule3 = Rule(movingDirection: .Left, state: 1, read: "1")
        let rule4 = Rule(state: 1, read: blank, newState: 0, write: "1", direction: .Left)
        
        var machine = TuringMachine(rules: [rule, rule2, rule3, rule4], initialTape: ["1", "0", "0", "0", "0", "0", "1"])
        
        for var i = 0; i < 8; i++ {
            machine.step()
        }
        assert(machine.state == 0, "end with state 0")
        assert(machine.rulesUsed.count == 4, "used all 4 rules")
        assert(machine.charsSeen.count == 3, "saw all 3 characters")
        assert(machine.statesUsed.count == 2, "used two states")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
