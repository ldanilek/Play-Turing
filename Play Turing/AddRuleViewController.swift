//
//  AddRuleViewController.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

protocol AddRuleDelegate {
    func newRule(rule: Rule)
    func cancelNewRule()
}

class AddRuleViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var delegate: AddRuleDelegate!
    var possibleCharacters: [Character]!
    var maxState: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
        // Do any additional setup after loading the view.
        self.startingStateStepper.value = Double(startingState)
        self.startingStateStepper.maximumValue = Double(maxState)
        self.startingStateLabel.text = "q\(startingState)"
        
        self.endStateStepper.value = Double(endState)
        self.endStateStepper.maximumValue = Double(maxState)
        self.endStateLabel.text = "q\(endState)"
        
        self.readingCharPicker.selectRow(find(possibleCharacters, readingCharacter)!, inComponent: 0, animated: false)
        self.writingCharPicker.selectRow(find(possibleCharacters, writeCharacter)!, inComponent: 0, animated: false)
        
        self.directionControl.selectedSegmentIndex = direction == .Left ? 0 : 1
    }
    
    func cancel() {
        delegate.cancelNewRule()
    }
    
    var startingState: Int = 0
    @IBOutlet weak var startingStateStepper: UIStepper!
    @IBOutlet weak var startingStateLabel: UILabel!
    @IBAction func startingStateChanged(sender: UIStepper) {
        self.startingState = Int(sender.value)
        self.startingStateLabel.text = "q\(startingState)"
    }
    
    var endState: Int = 0
    @IBOutlet weak var endStateStepper: UIStepper!
    @IBOutlet weak var endStateLabel: UILabel!
    @IBAction func endStateChanged(sender: UIStepper) {
        self.endState = Int(sender.value)
        self.endStateLabel.text = "q\(endState)"
    }
    
    var readingCharacter: Character = b
    @IBOutlet weak var readingCharPicker: UIPickerView!
    
    var writeCharacter: Character = b
    @IBOutlet weak var writingCharPicker: UIPickerView!
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return possibleCharacters.count
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return String(possibleCharacters[row])
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == readingCharPicker {
            readingCharacter = possibleCharacters[row]
        } else {
            writeCharacter = possibleCharacters[row]
        }
    }
    
    var direction: Direction = .Left
    @IBAction func directionChanged(sender: UISegmentedControl) {
        direction = sender.selectedSegmentIndex==0 ? .Left : .Right
    }
    @IBOutlet weak var directionControl: UISegmentedControl!
    
    
    var currentRule: Rule {
        return Rule(state: startingState, read: readingCharacter, newState: endState, write: writeCharacter, direction: direction)
    }
    
    func save() {
        self.delegate.newRule(currentRule)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
