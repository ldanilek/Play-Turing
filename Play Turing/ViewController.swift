//
//  ViewController.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

let RULE_HEIGHT: CGFloat = 40
let RULE_SPACING: CGFloat = 5

let TAPE_HEIGHT: CGFloat = 40
let BUTTON_WIDTH: CGFloat = 60
let TAPE_LABEL_HEIGHT: CGFloat = 25
let TAPE_HEAD_SIZE: CGFloat = 30

class ViewController: UIViewController, TuringTapeViewDelegate, AddRuleDelegate, UIGestureRecognizerDelegate {
    
    var playMachine: TuringMachine!
    var challenge: TuringChallenge!
    
    var goalTapeView: TuringTapeView!
    var playTapeView: TuringTapeView!
    var tapeHeadView: TuringHeadView!
    
    var onscreen: Bool = false
    
    var playButton: UIBarButtonItem!
    var addRuleButton: UIBarButtonItem!
    var resetButton: UIBarButtonItem!
    var fastForwardButton: UIBarButtonItem!
    
    var ruleScrollView: UIScrollView!
    var rulesContainer: UIView!
    var rulesContainerHeight: NSLayoutConstraint!
    var ruleLabels: [UILabel] = []
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        //touchDown(gestureRecognizer.view!)
        return true
    }
    
    func addConstraint(v: UIView, at: NSLayoutAttribute, v2: AnyObject?, at2: NSLayoutAttribute, c: CGFloat = 0) {
        view.addConstraint(NSLayoutConstraint(item: v, attribute: at, relatedBy: .Equal, toItem: v2, attribute: at2, multiplier: 1, constant: c))
    }
    
    var headViewConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        resetButton.width = BUTTON_WIDTH
        addRuleButton.width = BUTTON_WIDTH
        //self.navigationController?.toolbarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.toolbarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = challenge.name
        playButton = UIBarButtonItem(title: "Play", style: UIBarButtonItemStyle.Plain, target: self, action: "play:")
        resetButton = UIBarButtonItem(title: "Reset", style: UIBarButtonItemStyle.Plain, target: self, action: "reset:")
        addRuleButton = UIBarButtonItem(title: "Add Rule", style: UIBarButtonItemStyle.Plain, target: self, action: "addRule:")
        self.toolbarItems = [addRuleButton, UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil), playButton, UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil), resetButton]
        
        fastForwardButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self, action: "fastForward:")
        self.navigationItem.rightBarButtonItem = fastForwardButton
        
        goalTapeView = TuringTapeView(frame: CGRectZero, delegate: self, id: 1)
        playTapeView = TuringTapeView(frame: CGRectZero, delegate: self, id: 0)
        self.view.addSubview(goalTapeView)
        self.view.addSubview(playTapeView)
        
        tapeHeadView = TuringHeadView(frame: CGRectZero)
        self.view.addSubview(tapeHeadView)
        
        ruleScrollView = UIScrollView(frame: CGRectZero)
        self.view.addSubview(ruleScrollView)
        rulesContainer = UIView(frame: CGRectZero)
        ruleScrollView.addSubview(rulesContainer)
        rulesContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        /*
        var backButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        backButton.setTitle("Give Up", forState: .Normal)
        backButton.addTarget(self, action: "giveUp", forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        */
        var goalLabel = UILabel(frame: CGRectZero)
        goalLabel.text = "Goal"
        goalLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(goalLabel)
        
        var tapeLabel = UILabel(frame: CGRectZero)
        tapeLabel.text = "Turing Machine"
        tapeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(tapeLabel)
        
        //backButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        goalTapeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        playTapeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tapeHeadView.setTranslatesAutoresizingMaskIntoConstraints(false)
        ruleScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        view.addConstraint(NSLayoutConstraint(item: goalTapeView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: goalTapeView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        addConstraint(playTapeView, at: .Leading, v2: view, at2: .Leading)
        addConstraint(playTapeView, at: .Trailing, v2: view, at2: .Trailing)
        //addConstraint(backButton, at: .Trailing, v2: view, at2: .Trailing)
        addConstraint(goalLabel, at: .Top, v2: self.topLayoutGuide, at2: .Bottom, c: 0)
        addConstraint(goalTapeView, at: .Top, v2: goalLabel, at2: .Bottom)
        addConstraint(goalTapeView, at: .Height, v2: nil, at2: .NotAnAttribute, c: TAPE_HEIGHT)
        //addConstraint(goalLabel, at: .CenterY, v2: backButton, at2: .CenterY)
        addConstraint(goalLabel, at: .Height, v2: nil, at2: .NotAnAttribute, c: TAPE_LABEL_HEIGHT)
        addConstraint(goalLabel, at: .CenterX, v2: view, at2: .CenterX)
        //addConstraint(playTapeView, at: .Top, v2: goalTapeView, at2: .Bottom)
        addConstraint(playTapeView, at: .Height, v2: goalTapeView, at2: .Height)
        addConstraint(tapeHeadView, at: .Top, v2: playTapeView, at2: .Bottom)
        addConstraint(tapeLabel, at: .Top, v2: goalTapeView, at2: .Bottom, c: 5)
        addConstraint(tapeLabel, at: .Bottom, v2: playTapeView, at2: .Top, c: 0)
        addConstraint(tapeHeadView, at: .Width, v2: nil, at2: .NotAnAttribute, c: TAPE_HEAD_SIZE)
        addConstraint(tapeHeadView, at: .Height, v2: nil, at2: .NotAnAttribute, c: TAPE_HEAD_SIZE)
        headViewConstraint = NSLayoutConstraint(item: tapeHeadView, attribute: .CenterX, relatedBy: .Equal, toItem: playTapeView, attribute: .CenterX, multiplier: 1, constant: 0)
        view.addConstraint(headViewConstraint)
        
        addConstraint(ruleScrollView, at: .Bottom, v2: self.bottomLayoutGuide, at2: .Top)
        addConstraint(tapeHeadView, at: .Bottom, v2: ruleScrollView, at2: .Top)
        addConstraint(ruleScrollView, at: .Leading, v2: view, at2: .Leading)
        addConstraint(ruleScrollView, at: .Trailing, v2: view, at2: .Trailing)
        
        addConstraint(rulesContainer, at: .Leading, v2: ruleScrollView, at2: .Leading)
        addConstraint(rulesContainer, at: .Trailing, v2: ruleScrollView, at2: .Trailing)
        addConstraint(rulesContainer, at: .Top, v2: ruleScrollView, at2: .Top)
        addConstraint(rulesContainer, at: .Bottom, v2: ruleScrollView, at2: .Bottom)
        addConstraint(rulesContainer, at: .Width, v2: ruleScrollView, at2: .Width)
        rulesContainerHeight = NSLayoutConstraint(item: rulesContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        view.addConstraint(rulesContainerHeight)
        addConstraint(tapeLabel, at: .CenterX, v2: view, at2: .CenterX)
        
        self.reset()
    }
    
    func fastForward(button: UIBarButtonItem) {
        if stepDelay > 0.05 {
            stepDelay /= 2
        } else {
            stepDelay = 0.5
        }
        if let timerRunning = timer {
            let userInfo: AnyObject? = timerRunning.userInfo
            timerRunning.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(stepDelay, target: self, selector: "nextStep:", userInfo: userInfo, repeats: true)
        }
    }
    
    func giveUp() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelNewRule() {
        self.dismissViewControllerAnimated(true, completion: nil)
        editingRule = nil
    }
    
    func addRule(sender: UIButton) {
        let ruleForCurrentState = playMachine.ruleToUse()
        if let rule = ruleForCurrentState {
            
        } else {
            editingRule = Rule(movingDirection: .Left, state: playMachine.state, read: playMachine.read())
        }
        self.performSegueWithIdentifier("addrule", sender: sender)
    }
    var editingRule: Rule?
    func editRule(rule: Rule) {
        editingRule = rule
        self.performSegueWithIdentifier("addrule", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addrule" {
            let dest = (segue.destinationViewController as! UINavigationController).viewControllers.last as! AddRuleViewController
            if let rule = editingRule {
                dest.startingState = rule.state
                dest.endState = rule.newState
                dest.direction = rule.direction
                dest.readingCharacter = rule.read
                dest.writeCharacter = rule.write
            }
            dest.delegate = self
            dest.possibleCharacters = challenge.allowedCharacters
            dest.maxState = challenge.maxState
        }
    }
    
    func newRuleLabelWithRule(rule: Rule) {
        let previousRuleLabel = ruleLabels.last
        var newRuleLabel = UILabel(frame: CGRectZero)
        newRuleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        newRuleLabel.font = UIFont.systemFontOfSize(14)
        newRuleLabel.textAlignment = .Center
        newRuleLabel.userInteractionEnabled = true
        newRuleLabel.layer.cornerRadius = 5
        newRuleLabel.layer.borderWidth = 1
        newRuleLabel.layer.borderColor = UIColor.blackColor().CGColor
        let d = rule.direction==Direction.Left ? "left" : "right"
        newRuleLabel.text = "Read \(rule.read) in q\(rule.state) → write \(rule.write), set to q\(rule.newState), and go \(d)"
        let tap = UITapGestureRecognizer(target: self, action: "ruleTapped:")
        tap.delegate = self
        newRuleLabel.addGestureRecognizer(tap)
        var swiper = UISwipeGestureRecognizer(target: self, action: "ruleSwiped:")
        swiper.direction = UISwipeGestureRecognizerDirection.Left
        newRuleLabel.addGestureRecognizer(swiper)
        //ruleScrollView.contentSize = CGSizeMake(view.frame.width, CGFloat(rules.count)*(RULE_HEIGHT+RULE_SPACING))
        rulesContainer.addSubview(newRuleLabel)
        addConstraint(rulesContainer, at: .Left, v2: newRuleLabel, at2: .Left, c: -RULE_SPACING)
        addConstraint(rulesContainer, at: .Right, v2: newRuleLabel, at2: .Right, c: RULE_SPACING)
        addConstraint(newRuleLabel, at: .Height, v2: nil, at2: .NotAnAttribute, c: RULE_HEIGHT)
        if let prev = previousRuleLabel {
            addConstraint(prev, at: .Bottom, v2: newRuleLabel, at2: .Top, c: -RULE_SPACING)
        } else {
            addConstraint(rulesContainer, at: .Top, v2: newRuleLabel, at2: .Top, c: -RULE_SPACING)
        }
        ruleLabels.append(newRuleLabel)
        self.view.layoutIfNeeded()
        rulesContainerHeight.constant = newRuleLabel.frame.origin.y + newRuleLabel.frame.height + 10
        self.view.layoutIfNeeded()
    }
    
    func newRule(rule: Rule) {
        
        if let wasRule = editingRule {
            editingRule = nil
            if wasRule != rule {
                deleteRuleAtIndex(find(playMachine.rules, wasRule)!)
            }
        }
        var indexToReplace: Int?
        for (index,ruleAlreadyExists) in enumerate(playMachine.rules) {
            if ruleAlreadyExists == rule {
                indexToReplace = index
            }
        }
        var rules = playMachine.rules
        if let toReplace = indexToReplace {
            rules[toReplace] = rule
        } else {
            rules.append(rule);
            newRuleLabelWithRule(rule)
            indexToReplace = rules.count-1
        }
        resetWithRules(rules)
        let d = rule.direction==Direction.Left ? "left" : "right"
        ruleLabels[indexToReplace!].text = "Read \(rule.read) in q\(rule.state) → write \(rule.write), set to q\(rule.newState), and go \(d)"
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func ruleTapped(tap: UITapGestureRecognizer) {
        touchUp(tap.view!)
        let index = find(self.ruleLabels, tap.view as! UILabel)!
        editRule(playMachine.rules[index])
    }
    
    func ruleSwiped(swipe: UISwipeGestureRecognizer) {
        let index = find(self.ruleLabels, swipe.view as! UILabel)!
        // delete rule at index
        deleteRuleAtIndex(index)
    }
    
    func deleteRuleAtIndex(index: Int) {
        var rules = playMachine.rules
        rules.removeAtIndex(index)
        resetWithRules(rules)
        
        var labelToRemove = self.ruleLabels[index]
        self.ruleLabels.removeAtIndex(index)
        
        var toRemove = [NSLayoutConstraint]()
        for constraint in view.constraints() {
            if let cons = constraint as? NSLayoutConstraint {
                if let labelFirst = cons.firstItem as? UILabel {
                    if labelFirst == labelToRemove {
                        toRemove.append(cons)
                        continue
                    }
                }
                if let labelSecond = cons.secondItem as? UILabel {
                    if labelSecond == labelToRemove {
                        toRemove.append(cons)
                    }
                }
            }
        }
        view.removeConstraints(toRemove)
        
        if index < self.ruleLabels.count {
            // not the last one, so have to fix constraint
            var labelToFix = self.ruleLabels[index]
            
            if index > 0 {
                let prev = self.ruleLabels[index-1]
                addConstraint(prev, at: .Bottom, v2: labelToFix, at2: .Top, c: -RULE_SPACING)
            } else {
                addConstraint(rulesContainer, at: .Top, v2: labelToFix, at2: .Top, c: -RULE_SPACING)
            }
        }
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
            labelToRemove.alpha = 0
            }) { (a) -> Void in
                labelToRemove.removeFromSuperview()
        }
    }
    
    func touchDown(view: UIView) {
        view.layer.backgroundColor = UIColor.blueColor().CGColor
    }
    func touchUp(view: UIView) {
        view.layer.backgroundColor = UIColor.whiteColor().CGColor
    }
    
    func highlightRule(rule: Rule?) {
        UIView.animateWithDuration(stepDelay, animations: { () -> Void in
            for (index,possibleRule) in enumerate(self.playMachine.rules) {
                if possibleRule == rule {
                    self.ruleLabels[index].layer.backgroundColor = UIColor.yellowColor().CGColor
                } else {
                    self.ruleLabels[index].layer.backgroundColor = UIColor.whiteColor().CGColor
                }
            }
        })
    }
    
    func reset(button: UIBarButtonItem) {
        if button.title == "Reload" {
            button.title = "Reset"
            self.reloadChallenge()
        } else {
            self.timer?.invalidate()
            self.timer = nil
            resetWithRules(playMachine.rules)
            playButton.title = "Play"
            playButton.enabled = true
        }
    }
    
    var timer: NSTimer?
    func play(button: UIBarButtonItem) {
        if button.title == "Pause" {
            self.timer?.invalidate()
            self.timer = nil
            button.title="Play"
            return
        }
        if playMachine.rules.count == 0 {
            if challenge.name=="Getting Started" {
                flashAlerts("Your Turing Machine needs rules to run", "Rule you need: read \""+String(b)+"\"→ write \"1\"")
            } else {
                flashAlert("Your Turing Machine needs rules to run")
            }
        } else {
            button.title="Pause"
            resetButton.title = "Reset"
            self.timer = NSTimer.scheduledTimerWithTimeInterval(stepDelay, target: self, selector: "nextStep:", userInfo: button, repeats: true)
            self.updateUI()
        }
    }
    
    var stepDelay = 0.5
    
    func nextStep(timer: NSTimer) {
        if let rule = self.playMachine.step() {
            highlightRule(rule)
        } else {
            if playMachine.rules.count == 1 && playMachine.rulesUsed.count == 0 {
                flashAlerts("Your rule didn't run; check its condition", "Tap to edit a rule; swipe left to delete it")
            }
            highlightRule(nil)
            let button = timer.userInfo as! UIBarButtonItem
            button.title = "Play"
            button.enabled = false
            timer.invalidate()
            self.timer = nil
        }
        self.updateUI()
    }
    
    func tapAtIndex(index: Int, forView view: TuringTapeView) {
        self.step()
    }
    
    func step() {
        self.timer?.invalidate()
        self.timer = nil
        if let rule = self.playMachine.step() {
            highlightRule(rule)
        } else if self.playMachine.rules.count > 0 {
            highlightRule(nil)
            playButton.title = "Reset"
        }
        self.updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if onscreen == false {
            onscreen = true
            if self.challenge.name == "Getting Started" {
                flashAlerts("Tap Play to get started")
            } else if self.challenge.name == "Deletion" {
                if playMachine.rules.count == 0 {
                    flashAlert("Rule: Read \"1\", write \""+String(b)+"\", and move Left")
                }
            } else if self.challenge.name == "Alternator" {
                if playMachine.rules.count == 0 {
                    flashAlerts("Now you need two rules", "Alternate between states q0 and q1", "q0 means write \"0\", q1 means write \"1\"")
                }
            }
        } else {
            if self.challenge.name == "Getting Started" {
                if playMachine.rules.count == 1 {
                    flashAlerts("Now you have a rule. Play your machine")
                }
            }
            
        }
    }
    func numberOfCharacters(forView view: TuringTapeView) -> Int {
        return challenge.startTape.count
    }
    func characterAtIndex(index: Int, forView view: TuringTapeView) -> String {
        if view.id == 0 {
            // playMachineTape
            return String((self.playMachine?.tape ?? challenge.startTape)[index])
        } else {
            return String(challenge.goalTape[index])
        }
    }
    
    func reset() {
        /*
        let rule = Rule(state: 0, read: "1", newState: 1, write: blank, direction: .Right)
        let rule2 = Rule(state: 1, read: "0", newState: 1, write: blank, direction: .Right)
        let rule3 = Rule(movingDirection: .Left, state: 1, read: "1")
        let rule4 = Rule(state: 1, read: blank, newState: 0, write: "1", direction: .Left)
*/
        if let rules = challenge?.storedRules() {
            //println("found rules")
            resetWithRules(rules)
        } else {
            //println("no rules found")
            resetWithRules([])
        }
    }
    
    func resetWithRules(rules: [Rule]) {
        challenge.storeRules(rules)
        //println("new rules")
        timer?.invalidate()
        timer = nil
        playButton.enabled = true
        playButton.title = "Play"
        resetButton.title = "Reload"
        if self.playMachine != nil {
            highlightRule(nil)
        }
        playButton.title = "Play"
        self.playMachine = TuringMachine(rules: rules, initialTape: challenge.startTape, tapeIndex: challenge.startIndex, initialState: challenge.startState)
        updateUI()
    }
    
    func flashAlerts(alerts: String...) {
        self.flashAlerts(alerts)
    }
    func flashAlert(alert: String) {
        self.flashAlerts(alert)
    }
    
    func flashAlerts(alerts: [String], offset: CGFloat = 0) {
        var alertTexts = alerts
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.text = alertTexts.removeAtIndex(0)
        label.textColor = UIColor.redColor()
        label.backgroundColor = UIColor.yellowColor()
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.textAlignment = NSTextAlignment.Center
        label.alpha = 0
        view.addSubview(label)
        addConstraint(label, at: .CenterX, v2: view, at2: .CenterX)
        addConstraint(label, at: .CenterY, v2: view, at2: .CenterY, c: offset)
        addConstraint(label, at: .Height, v2: nil, at2: .NotAnAttribute, c: 30)
        addConstraint(label, at: .Width, v2: view, at2: .Width, c: -10)
        view.layoutIfNeeded()
        UIView.animateWithDuration(1, animations: { () -> Void in
            label.alpha = 1
        }) { (c) -> Void in
            if alertTexts.count > 0 {
                self.flashAlerts(alertTexts, offset: offset+40)
            }
            UIView.animateWithDuration(1, animations: { () -> Void in
                label.transform = CGAffineTransformMakeScale(1.03, 1.03)
                }, completion: { (a) -> Void in
                    UIView.animateWithDuration(3, animations: { () -> Void in
                        label.alpha = 0
                        }, completion: { (s) -> Void in
                            label.removeFromSuperview()
                    })
            })
            
        }
    }
    
    func reloadChallenge() {
        self.challenge = TuringChallenge(index: self.challenge.index)
        self.reset()
        if self.challenge.name == "Bit flipper" {
            self.flashAlert("Try out your machine on a different tape")
        }
    }
    
    func updateUI() {
        tapeHeadView.setState(self.playMachine.state)
        playTapeView.reload()
        goalTapeView.reload()
        let indexToMoveTo = playMachine.index
        while ruleLabels.count < playMachine.rules.count {
            newRuleLabelWithRule(playMachine.rules[ruleLabels.count])
        }
        
        if playMachine.tape == challenge.goalTape {
            // win
            timer?.invalidate()
            timer = nil
            playButton.title = "Reset"
            var alert = UIAlertController(title: "You Win", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yay!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.reloadChallenge()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        if indexToMoveTo < 0 || indexToMoveTo >= playMachine.tape.count {
            if challenge.index < 5 {
                flashAlerts("Stay on your section of tape", "Try moving the other direction")
            } else {
                flashAlert("Stay on your section of tape")
            }
            reset()
        } else {
            self.view.removeConstraint(headViewConstraint)
            headViewConstraint = NSLayoutConstraint(item: tapeHeadView, attribute: .CenterX, relatedBy: .Equal, toItem: playTapeView.viewAtIndex(playMachine.index), attribute: .CenterX, multiplier: 1, constant: 0)
            view.addConstraint(headViewConstraint)
        }
        func animate() {
            self.view.layoutIfNeeded()
        }
        if onscreen {
            UIView.animateWithDuration(stepDelay, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animate, completion: nil)
        } else {
            animate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

