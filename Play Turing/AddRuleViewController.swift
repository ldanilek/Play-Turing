//
//  AddRuleViewController.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

protocol AddRuleDelegate {
    func newRule(_ rule: Rule)
    func cancelNewRule()
}

class AddRuleViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, TuringTapeViewDelegate {
    
    var delegate: AddRuleDelegate!
    var possibleCharacters: [Character]!
    var maxState: Int!
    var hasFinalState: Bool = false
    var tapeLength = 0
    
    @IBOutlet weak var rulePreviewLabel: UILabel!
    
    func viewIndexForDirection(_ d: Direction? = nil) -> Int {
        let dir = d ?? direction
        if tapeLength > 1 {
            return dir == .left ? 0 : 2;
        }
        return 0
    }
    var centerIndex: Int {
        return tapeLength > 1 ? 1 : 0
    }
    
    func tapAtIndex(_ index: Int, forView view: TuringTapeView) {
        if tapeLength > 1 {
            if view.id == 1 {
                // goal tape tapped to change direction
                if index == 0 {
                    setDirection(.left)
                } else if index == 2 {
                    setDirection(.right)
                }
            }
        }
        if (index == 1 && tapeLength > 1) || tapeLength == 1 {
            let pickerView = view.id == 0 ? self.readingCharPicker : self.writingCharPicker
            let row = ((pickerView?.selectedRow(inComponent: 0))!+1)%self.pickerView(pickerView!, numberOfRowsInComponent: 0)
            pickerView?.selectRow(row, inComponent: 0, animated: true)
            self.pickerView(pickerView!, didSelectRow: row, inComponent: 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        super.viewWillAppear(animated)
        self.readingCharPicker.selectRow(self.possibleCharacters.count-1, inComponent: 0, animated: false)
        self.writingCharPicker.selectRow(self.possibleCharacters.count-1, inComponent: 0, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.readingCharPicker.selectRow(possibleCharacters.index(of: readingCharacter) ?? 0, inComponent: 0, animated: true)
        self.writingCharPicker.selectRow(possibleCharacters.index(of: writeCharacter) ?? 0, inComponent: 0, animated: true)
    }
    
    func characterAtIndex(_ index: Int, forView view: TuringTapeView) -> String {
        if view.id == 0 {
            if index == 1 || tapeLength == 1 {
                return String(self.readingCharacter)
            } else {
                return ""
            }
        } else {
            if index == 1 || tapeLength == 1 {
                return String(self.writeCharacter)
            } else if viewIndexForDirection() == index {
                return ""
            } else {
                return "tap"
            }
        }
    }
    
    func numberOfCharacters(forView view: TuringTapeView) -> Int {
        return tapeLength > 1 ? 3 : 1
    }

    override func viewDidLoad() {
        readingCharacter = possibleCharacters[possibleCharacters.index(of: readingCharacter) ?? 0]
        writeCharacter = possibleCharacters[possibleCharacters.index(of: writeCharacter) ?? 0]
        
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddRuleViewController.cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(AddRuleViewController.save))
        // Do any additional setup after loading the view.
        self.startingStateStepper.value = Double(startingState)
        self.startingStateStepper.maximumValue = Double(maxState)
        
        if hasFinalState {
            self.endStateStepper.maximumValue = Double(maxState+1)
        } else {
            self.endStateStepper.maximumValue = Double(maxState)
        }
        self.endStateStepper.value = Double(endState)
        
        if maxState == 0 {
            self.endStateStepper.isHidden = true
            self.startingStateStepper.isHidden = true
        }
        conditionTape = TuringTapeView(frame: CGRect.zero, delegate: self, id: 0)
        conditionTape.translatesAutoresizingMaskIntoConstraints = false
        self.conditionTapeSuperview.addSubview(conditionTape)
        view.addConstraint(NSLayoutConstraint(item: conditionTape, attribute: .leading, relatedBy: .equal, toItem: conditionTapeSuperview, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: conditionTape, attribute: .trailing, relatedBy: .equal, toItem: conditionTapeSuperview, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: conditionTape, attribute: .top, relatedBy: .equal, toItem: conditionTapeSuperview, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: conditionTape, attribute: .bottom, relatedBy: .equal, toItem: conditionTapeSuperview, attribute: .bottom, multiplier: 1, constant: 0))
        
        resultTape = TuringTapeView(frame: CGRect.zero, delegate: self, id: 1)
        self.resultTapeSuperview.addSubview(resultTape)
        resultTape.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: resultTape, attribute: .leading, relatedBy: .equal, toItem: resultTapeSuperview, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: resultTape, attribute: .trailing, relatedBy: .equal, toItem: resultTapeSuperview, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: resultTape, attribute: .top, relatedBy: .equal, toItem: resultTapeSuperview, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: resultTape, attribute: .bottom, relatedBy: .equal, toItem: resultTapeSuperview, attribute: .bottom, multiplier: 1, constant: 0))
        
        resultTapeSuperview.backgroundColor = TAPE_BG_COLOR
        conditionTapeSuperview.backgroundColor = TAPE_BG_COLOR // don't want yellow showing through on rotate
        
        conditionTapeHead = TuringHeadView(frame: CGRect.zero)
        resultTapeHead = TuringHeadView(frame: CGRect.zero)
        conditionTapeHead.translatesAutoresizingMaskIntoConstraints = false
        resultTapeHead.translatesAutoresizingMaskIntoConstraints = false
        conditionTapeHead.setState(startingState)
        resultTapeHead.setState(endState)
        view.addSubview(conditionTapeHead)
        view.addSubview(resultTapeHead)
        view.addConstraint(NSLayoutConstraint(item: conditionTapeSuperview, attribute: .bottom, relatedBy: .equal, toItem: conditionTapeHead, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: resultTapeSuperview, attribute: .bottom, relatedBy: .equal, toItem: resultTapeHead, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: conditionTapeSuperview, attribute: .centerX, relatedBy: .equal, toItem: conditionTapeHead, attribute: .centerX, multiplier: 1, constant: 0))
        resultHeadConstraint = NSLayoutConstraint(item: resultTapeHead, attribute: .centerX, relatedBy: .equal, toItem: conditionTape.viewAtIndex(viewIndexForDirection()), attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(resultHeadConstraint)
        
        view.addConstraint(NSLayoutConstraint(item: conditionTapeHead, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: TAPE_HEAD_WIDTH))
        view.addConstraint(NSLayoutConstraint(item: conditionTapeHead, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: TAPE_HEAD_HEIGHT))
        view.addConstraint(NSLayoutConstraint(item: resultTapeHead, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: TAPE_HEAD_WIDTH))
        view.addConstraint(NSLayoutConstraint(item: resultTapeHead, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: TAPE_HEAD_HEIGHT))
        
        self.readingCharPicker.selectRow(possibleCharacters.index(of: readingCharacter) ?? 0, inComponent: 0, animated: false)
        self.writingCharPicker.selectRow(possibleCharacters.index(of: writeCharacter) ?? 0, inComponent: 0, animated: false)
        
        self.resultTapeHead.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(AddRuleViewController.swipeHead(_:))))
        self.resultTapeHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddRuleViewController.tapResultState(_:))))
        self.conditionTapeHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddRuleViewController.tapConditionState(_:))))
        
        conditionTape.viewColorChange(centerIndex, newColor: TAPE_SELECTED_COLOR)
        resultTape?.viewColorChange(viewIndexForDirection(), newColor: TAPE_SELECTED_COLOR)
    }
    
    func tapResultState(_ tap: UITapGestureRecognizer) {
        self.endStateStepper.value = Double((Int(self.endStateStepper.value) + 1) % (self.maxState + 1))
        self.endStateChanged(endStateStepper)
    }
    
    func tapConditionState(_ tap: UITapGestureRecognizer) {
        self.startingStateStepper.value = Double((Int(self.startingStateStepper.value) + 1) % (self.maxState + 1))
        self.startingStateChanged(startingStateStepper)
    }
    
    func swipeHead(_ pan: UIPanGestureRecognizer) {
        if tapeLength == 1 {
            return
        }
        if direction == .left && pan.translation(in: pan.view!).x > 10 {
            setDirection(.right)
            pan.setTranslation(CGPoint.zero, in: pan.view)
        }
        if direction == .right && pan.translation(in: pan.view!).x < -10 {
            setDirection(.left)
            pan.setTranslation(CGPoint.zero, in: pan.view)
        }
    }
    
    func cancel() {
        delegate.cancelNewRule()
    }
    
    var resultHeadConstraint: NSLayoutConstraint!
    
    var startingState: Int = 0 {
        didSet {
            rulePreviewLabel?.attributedText = currentRule.preview
        }
    }
    @IBOutlet weak var startingStateStepper: UIStepper!
    @IBAction func startingStateChanged(_ sender: UIStepper) {
        self.startingState = Int(sender.value)
        conditionTapeHead.setState(startingState)
    }
    
    var endState: Int = 0 {
        didSet {
            rulePreviewLabel?.attributedText = currentRule.preview
        }
    }
    @IBOutlet weak var endStateStepper: UIStepper!
    @IBAction func endStateChanged(_ sender: UIStepper) {
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
            rulePreviewLabel?.attributedText = currentRule.preview
        }
    }
    @IBOutlet weak var readingCharPicker: UIPickerView!
    
    var writeCharacter: Character = b {
        didSet {
            rulePreviewLabel?.attributedText = currentRule.preview
        }
    }
    @IBOutlet weak var writingCharPicker: UIPickerView!
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return possibleCharacters.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(possibleCharacters[row])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == readingCharPicker {
            readingCharacter = possibleCharacters[row]
            conditionTape.reload()
        } else {
            writeCharacter = possibleCharacters[row]
            resultTape.reload()
        }
    }
    
    var direction: Direction = .left {
        didSet {
            rulePreviewLabel?.attributedText = currentRule.preview
        }
    }
    func setDirection(_ d: Direction) {
        direction = d
        resultTape.reload()
        resultTape?.viewColorChange(viewIndexForDirection(d), newColor: TAPE_SELECTED_COLOR)
        resultTape?.viewColorChange(viewIndexForDirection(d.opposite), newColor: TAPE_BG_COLOR)
        view.removeConstraint(resultHeadConstraint)
        resultHeadConstraint = NSLayoutConstraint(item: resultTapeHead, attribute: .centerX, relatedBy: .equal, toItem: resultTape.viewAtIndex(viewIndexForDirection()), attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(resultHeadConstraint)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
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
