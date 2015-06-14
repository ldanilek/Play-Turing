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

class AddRuleViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, TuringTapeViewDelegate {
    
    var delegate: AddRuleDelegate!
    var possibleCharacters: [Character]!
    var maxState: Int!
    
    @IBOutlet weak var rulePreviewLabel: UILabel!
    
    func tapAtIndex(index: Int, forView view: TuringTapeView) {
        if view.id == 1 {
            if index == 0 {
                setDirection(.Left)
            } else if index == 2 {
                setDirection(.Right)
            }
        }
        if index == 1 {
            let pickerView = view.id == 0 ? self.readingCharPicker : self.writingCharPicker
            let row = (pickerView.selectedRowInComponent(0)+1)%self.pickerView(pickerView, numberOfRowsInComponent: 0)
            pickerView.selectRow(row, inComponent: 0, animated: true)
            self.pickerView(pickerView, didSelectRow: row, inComponent: 0)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.readingCharPicker.selectRow(self.possibleCharacters.count-1, inComponent: 0, animated: false)
        self.writingCharPicker.selectRow(self.possibleCharacters.count-1, inComponent: 0, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.readingCharPicker.selectRow(find(possibleCharacters, readingCharacter) ?? 0, inComponent: 0, animated: true)
        self.writingCharPicker.selectRow(find(possibleCharacters, writeCharacter) ?? 0, inComponent: 0, animated: true)
    }
    
    func characterAtIndex(index: Int, forView view: TuringTapeView) -> String {
        if view.id == 0 {
            if index == 1 {
                return String(self.readingCharacter)
            } else {
                return ""
            }
        } else {
            if index == 1 {
                return String(self.writeCharacter)
            } else if (direction == Direction.Left ? 0 : 2) == index {
                return ""
            } else {
                return "tap"
            }
        }
    }
    
    func numberOfCharacters(forView view: TuringTapeView) -> Int {
        return 3
    }

    override func viewDidLoad() {
        readingCharacter = possibleCharacters[find(possibleCharacters, readingCharacter) ?? 0]
        writeCharacter = possibleCharacters[find(possibleCharacters, writeCharacter) ?? 0]
        
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
        // Do any additional setup after loading the view.
        self.startingStateStepper.value = Double(startingState)
        self.startingStateStepper.maximumValue = Double(maxState)
        
        self.endStateStepper.value = Double(endState)
        self.endStateStepper.maximumValue = Double(maxState)
        if maxState == 0 {
            self.endStateStepper.hidden = true
            self.startingStateStepper.hidden = true
        }
        conditionTape = TuringTapeView(frame: CGRectZero, delegate: self, id: 0)
        conditionTape.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.conditionTapeSuperview.addSubview(conditionTape)
        view.addConstraint(NSLayoutConstraint(item: conditionTape, attribute: .Leading, relatedBy: .Equal, toItem: conditionTapeSuperview, attribute: .Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: conditionTape, attribute: .Trailing, relatedBy: .Equal, toItem: conditionTapeSuperview, attribute: .Trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: conditionTape, attribute: .Top, relatedBy: .Equal, toItem: conditionTapeSuperview, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: conditionTape, attribute: .Bottom, relatedBy: .Equal, toItem: conditionTapeSuperview, attribute: .Bottom, multiplier: 1, constant: 0))
        
        resultTape = TuringTapeView(frame: CGRectZero, delegate: self, id: 1)
        self.resultTapeSuperview.addSubview(resultTape)
        resultTape.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraint(NSLayoutConstraint(item: resultTape, attribute: .Leading, relatedBy: .Equal, toItem: resultTapeSuperview, attribute: .Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: resultTape, attribute: .Trailing, relatedBy: .Equal, toItem: resultTapeSuperview, attribute: .Trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: resultTape, attribute: .Top, relatedBy: .Equal, toItem: resultTapeSuperview, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: resultTape, attribute: .Bottom, relatedBy: .Equal, toItem: resultTapeSuperview, attribute: .Bottom, multiplier: 1, constant: 0))
        
        resultTapeSuperview.backgroundColor = TAPE_BG_COLOR
        conditionTapeSuperview.backgroundColor = TAPE_BG_COLOR // don't want yellow showing through on rotate
        
        conditionTapeHead = TuringHeadView(frame: CGRectZero)
        resultTapeHead = TuringHeadView(frame: CGRectZero)
        conditionTapeHead.setTranslatesAutoresizingMaskIntoConstraints(false)
        resultTapeHead.setTranslatesAutoresizingMaskIntoConstraints(false)
        conditionTapeHead.setState(startingState)
        resultTapeHead.setState(endState)
        view.addSubview(conditionTapeHead)
        view.addSubview(resultTapeHead)
        view.addConstraint(NSLayoutConstraint(item: conditionTapeSuperview, attribute: .Bottom, relatedBy: .Equal, toItem: conditionTapeHead, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: resultTapeSuperview, attribute: .Bottom, relatedBy: .Equal, toItem: resultTapeHead, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: conditionTapeSuperview, attribute: .CenterX, relatedBy: .Equal, toItem: conditionTapeHead, attribute: .CenterX, multiplier: 1, constant: 0))
        resultHeadConstraint = NSLayoutConstraint(item: resultTapeHead, attribute: .CenterX, relatedBy: .Equal, toItem: conditionTape.viewAtIndex(direction == .Left ? 0 : 2), attribute: .CenterX, multiplier: 1, constant: 0)
        view.addConstraint(resultHeadConstraint)
        
        view.addConstraint(NSLayoutConstraint(item: conditionTapeHead, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: TAPE_HEAD_WIDTH))
        view.addConstraint(NSLayoutConstraint(item: conditionTapeHead, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: TAPE_HEAD_HEIGHT))
        view.addConstraint(NSLayoutConstraint(item: resultTapeHead, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: TAPE_HEAD_WIDTH))
        view.addConstraint(NSLayoutConstraint(item: resultTapeHead, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: TAPE_HEAD_HEIGHT))
        
        self.readingCharPicker.selectRow(find(possibleCharacters, readingCharacter) ?? 0, inComponent: 0, animated: false)
        self.writingCharPicker.selectRow(find(possibleCharacters, writeCharacter) ?? 0, inComponent: 0, animated: false)
        
        self.resultTapeHead.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "swipeHead:"))
        self.resultTapeHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapResultState:"))
        self.conditionTapeHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapConditionState:"))
    }
    
    func tapResultState(tap: UITapGestureRecognizer) {
        self.endStateStepper.value = Double((Int(self.endStateStepper.value) + 1) % (self.maxState + 1))
        self.endStateChanged(endStateStepper)
    }
    
    func tapConditionState(tap: UITapGestureRecognizer) {
        self.startingStateStepper.value = Double((Int(self.startingStateStepper.value) + 1) % (self.maxState + 1))
        self.startingStateChanged(startingStateStepper)
    }
    
    func swipeHead(pan: UIPanGestureRecognizer) {
        if direction == .Left && pan.translationInView(pan.view!).x > 10 {
            setDirection(.Right)
            pan.setTranslation(CGPointZero, inView: pan.view)
        }
        if direction == .Right && pan.translationInView(pan.view!).x < -10 {
            setDirection(.Left)
            pan.setTranslation(CGPointZero, inView: pan.view)
        }
    }
    
    func cancel() {
        delegate.cancelNewRule()
    }
    
    var resultHeadConstraint: NSLayoutConstraint!
    
    var startingState: Int = 0 {
        didSet {
            rulePreviewLabel?.text = currentRule.preview
        }
    }
    @IBOutlet weak var startingStateStepper: UIStepper!
    @IBAction func startingStateChanged(sender: UIStepper) {
        self.startingState = Int(sender.value)
        conditionTapeHead.setState(startingState)
    }
    
    var endState: Int = 0 {
        didSet {
            rulePreviewLabel?.text = currentRule.preview
        }
    }
    @IBOutlet weak var endStateStepper: UIStepper!
    @IBAction func endStateChanged(sender: UIStepper) {
        self.endState = Int(sender.value)
        resultTapeHead.setState(endState)
    }
    @IBOutlet weak var conditionTapeSuperview: UIView!
    var conditionTape: TuringTapeView!
    @IBOutlet weak var resultTapeSuperview: UIView!
    var resultTape: TuringTapeView!
    
    var conditionTapeHead: TuringHeadView!
    var resultTapeHead: TuringHeadView!
    
    var readingCharacter: Character = b {
        didSet {
            rulePreviewLabel?.text = currentRule.preview
        }
    }
    @IBOutlet weak var readingCharPicker: UIPickerView!
    
    var writeCharacter: Character = b {
        didSet {
            rulePreviewLabel?.text = currentRule.preview
        }
    }
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
            conditionTape.reload()
        } else {
            writeCharacter = possibleCharacters[row]
            resultTape.reload()
        }
    }
    
    var direction: Direction = .Left {
        didSet {
            rulePreviewLabel?.text = currentRule.preview
        }
    }
    func setDirection(d: Direction) {
        direction = d
        resultTape.reload()
        view.removeConstraint(resultHeadConstraint)
        resultHeadConstraint = NSLayoutConstraint(item: resultTapeHead, attribute: .CenterX, relatedBy: .Equal, toItem: resultTape.viewAtIndex(direction == .Left ? 0 : 2), attribute: .CenterX, multiplier: 1, constant: 0)
        view.addConstraint(resultHeadConstraint)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    
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
