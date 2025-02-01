//
//  ViewController.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

//let MAIN_FONT_NAME = "Bangla Sangam MN"

let VIEW_BACKGROUND_COLOR = UIColor.white//UIColor(red: 1, green: 0.9, blue: 1, alpha: 1)
let NAV_BUTTON_COLOR = UIColor.blue
let NAV_BAR_COLOR = UIColor.white

let RULE_HEIGHT: CGFloat = 28
let RULE_SPACING: CGFloat = 5

let TAPE_HEIGHT: CGFloat = 28//chosen because this is the height of the selection of a state. previously 40
let BUTTON_WIDTH: CGFloat = 60
let TAPE_LABEL_HEIGHT: CGFloat = 25

let TAPE_HEAD_HEIGHT: CGFloat = 30
let TAPE_HEAD_WIDTH: CGFloat = 50

let RULE_HIGHLIGHT_COLOR = OFF_WHITE_COLOR//UIColor(red: 246.0/255.0, green: 199.0/255.0, blue: 94.0/255.0, alpha: 1)
let RULE_BG_COLOR = LIGHT_BLUE_COLOR//UIColor(red: 1, green: 1, blue: 0.8, alpha: 1)
let RULE_BORDER_COLOR = UIColor.black

let TEXT_COLOR = UIColor(white: 0.2, alpha: 1)
let ALERT_TEXT_COLOR = UIColor.red
let ALERT_BG_COLOR = UIColor.yellow
let ALERT_BORDER_COLOR = UIColor.black

class ViewController: UIViewController, TuringTapeViewDelegate, AddRuleDelegate, UIGestureRecognizerDelegate {
    
    var playMachine: TuringMachine!
    var challenge: TuringChallenge!
    
    var goalTapeView: TuringTapeView!
    var playTapeView: TuringTapeView!
    var tapeHeadView: TuringHeadView!
    
    var onscreen: Bool = false
    
    var playButton: TuringButtonView!
    var hintButton: UIBarButtonItem!
    var addRuleButton: UIBarButtonItem!
    var resetButton: UIBarButtonItem!
    var fastForwardButton: UIBarButtonItem!
    
    var ruleScrollView: UIScrollView!
    var rulesContainer: UIView!
    var rulesContainerHeight: NSLayoutConstraint!
    var ruleLabels: [UILabel] = []
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //touchDown(gestureRecognizer.view!)
        return true
    }
    
    func addConstraint(_ v: UIView, at: NSLayoutAttribute, v2: AnyObject?, at2: NSLayoutAttribute, c: CGFloat = 0) {
        view.addConstraint(NSLayoutConstraint(item: v, attribute: at, relatedBy: .equal, toItem: v2, attribute: at2, multiplier: 1, constant: c))
    }
    
    var headViewConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetButton.width = BUTTON_WIDTH
        addRuleButton.width = BUTTON_WIDTH
        
        //self.navigationController?.toolbarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.toolbarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // required because I had to disable "extends under top bars", because
        // the topLayoutGuide is set to the status bar during the transition otherwise
        //self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        // Do any additional setup after loading the view, typically from a nib.
        hintButton = UIBarButtonItem(title: "Hint", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.hint(_:)))
        resetButton = UIBarButtonItem(title: "Reset", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.reset(_:)))
        addRuleButton = UIBarButtonItem(title: "Add Rule", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.addRule(_:)))
        self.toolbarItems = [addRuleButton, UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil), hintButton, UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil), resetButton]
        
        playButton = TuringButtonView(frame: CGRect.zero)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)
        let playButtonPadding: CGFloat = 5
        let playButtonHeight: CGFloat = 40
        addConstraint(playButton, at: .leading, v2: view, at2: .leading, c: playButtonPadding)
        addConstraint(playButton, at: .trailing, v2: view, at2: .trailing, c: -playButtonPadding)
        addConstraint(playButton, at: .height, v2: nil, at2: .notAnAttribute, c:playButtonHeight)
        addConstraint(playButton, at: .bottom, v2: self.bottomLayoutGuide, at2: .top, c: -playButtonPadding)
        playButton.action = { ()->Void in
            self.play(self.playButton)
        }
        
        fastForwardButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(ViewController.fastForward(_:)))
        self.navigationItem.rightBarButtonItem = fastForwardButton
        
        goalTapeView = TuringTapeView(frame: CGRect.zero, delegate: self, id: 1)
        playTapeView = TuringTapeView(frame: CGRect.zero, delegate: self, id: 0)
        self.view.addSubview(goalTapeView)
        self.view.addSubview(playTapeView)
        
        tapeHeadView = TuringHeadView(frame: CGRect.zero)
        self.view.addSubview(tapeHeadView)
        
        ruleScrollView = UIScrollView(frame: CGRect.zero)
        self.view.addSubview(ruleScrollView)
        rulesContainer = UIView(frame: CGRect.zero)
        ruleScrollView.addSubview(rulesContainer)
        rulesContainer.translatesAutoresizingMaskIntoConstraints = false
        /*
        var backButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        backButton.setTitle("Give Up", forState: .Normal)
        backButton.addTarget(self, action: "giveUp", forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        */
        let goalLabel = UILabel(frame: CGRect.zero)
        goalLabel.text = "Goal"
        goalLabel.textColor = TEXT_COLOR
        goalLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(goalLabel)
        
        let tapeLabel = UILabel(frame: CGRect.zero)
        tapeLabel.text = "Your Turing Machine"
        tapeLabel.textColor = TEXT_COLOR
        tapeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tapeLabel)
        
        //backButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        goalTapeView.translatesAutoresizingMaskIntoConstraints = false
        playTapeView.translatesAutoresizingMaskIntoConstraints = false
        tapeHeadView.translatesAutoresizingMaskIntoConstraints = false
        ruleScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: goalTapeView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: goalTapeView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
        
        addConstraint(playTapeView, at: .leading, v2: view, at2: .leading)
        addConstraint(playTapeView, at: .trailing, v2: view, at2: .trailing)
        //addConstraint(backButton, at: .Trailing, v2: view, at2: .Trailing)
        //let topGuide = self.topLayoutGuide as AnyObject?
        
        addConstraint(tapeLabel, at: .top, v2: self.topLayoutGuide, at2: .bottom, c: 5) // some buffer to top
        addConstraint(goalTapeView, at: .top, v2: goalLabel, at2: .bottom)
        addConstraint(goalTapeView, at: .height, v2: nil, at2: .notAnAttribute, c: TAPE_HEIGHT)
        //addConstraint(goalLabel, at: .CenterY, v2: backButton, at2: .CenterY)
        addConstraint(goalLabel, at: .height, v2: nil, at2: .notAnAttribute, c: TAPE_LABEL_HEIGHT)
        addConstraint(goalLabel, at: .centerX, v2: view, at2: .centerX)
        //addConstraint(playTapeView, at: .Top, v2: goalTapeView, at2: .Bottom)
        addConstraint(playTapeView, at: .height, v2: goalTapeView, at2: .height)
        addConstraint(tapeHeadView, at: .top, v2: playTapeView, at2: .bottom)
        addConstraint(goalLabel, at: .top, v2: tapeHeadView, at2: .bottom, c: 5)
        addConstraint(tapeLabel, at: .bottom, v2: playTapeView, at2: .top, c: 0)
        addConstraint(tapeHeadView, at: .width, v2: nil, at2: .notAnAttribute, c: TAPE_HEAD_WIDTH)
        addConstraint(tapeHeadView, at: .height, v2: nil, at2: .notAnAttribute, c: TAPE_HEAD_HEIGHT)
        headViewConstraint = NSLayoutConstraint(item: tapeHeadView, attribute: .centerX, relatedBy: .equal, toItem: playTapeView, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(headViewConstraint)
        
        addConstraint(ruleScrollView, at: .bottom, v2: playButton, at2: .top, c: -playButtonPadding)
        addConstraint(goalTapeView, at: .bottom, v2: ruleScrollView, at2: .top)
        addConstraint(ruleScrollView, at: .leading, v2: view, at2: .leading)
        addConstraint(ruleScrollView, at: .trailing, v2: view, at2: .trailing)
        
        addConstraint(rulesContainer, at: .leading, v2: ruleScrollView, at2: .leading)
        addConstraint(rulesContainer, at: .trailing, v2: ruleScrollView, at2: .trailing)
        addConstraint(rulesContainer, at: .top, v2: ruleScrollView, at2: .top)
        addConstraint(rulesContainer, at: .bottom, v2: ruleScrollView, at2: .bottom)
        addConstraint(rulesContainer, at: .width, v2: ruleScrollView, at2: .width)
        rulesContainerHeight = NSLayoutConstraint(item: rulesContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        view.addConstraint(rulesContainerHeight)
        addConstraint(tapeLabel, at: .centerX, v2: view, at2: .centerX)
 
        self.reset()
        print("View did load finished")
    }
    
    func boughtHints() -> Bool {
        return TuringSettings.sharedInstance.hintsUnlocked
    }
    
    func hint(_ button: UIBarButtonItem) {
        if challenge.hints.count == 0 {
            flashAlert("You're on your own for this level")
        } else if challenge.hintsAreFree || boughtHints() {
            flashAlerts(challenge.hints)
        } else {
            flashAlerts("Buy access to all hints in Settings")
        }
    }
    
    var speedTimes: Int = 1
    
    func fastForward(_ button: UIBarButtonItem) {
        if stepDelay > 0.05 {
            stepDelay /= 2
            speedTimes *= 2
        } else {
            stepDelay = 0.5
            speedTimes = 1
        }
        if speedTimes > 1 {
            flashAlert("Fast forward: \(speedTimes)x speed")
        } else {
            flashAlert("Normal speed")
        }
        if let timerRunning = timer {
            let userInfo: AnyObject? = timerRunning.userInfo as AnyObject?
            timerRunning.invalidate()
            timer = Timer.scheduledTimer(timeInterval: stepDelay, target: self, selector: #selector(ViewController.nextStep(_:)), userInfo: userInfo, repeats: true)
        }
    }
    
    func giveUp() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func cancelNewRule() {
        self.dismiss(animated: true, completion: nil)
        editingRule = nil
    }
    
    func addRule(_ sender: UIButton) {
        let ruleForCurrentState = playMachine.ruleToUse()
        if ruleForCurrentState != nil {
            
        } else if playMachine.state <= challenge.maxState {
            editingRule = Rule(movingDirection: .left, state: playMachine.state, read: playMachine.read())
        }
        self.performSegue(withIdentifier: "addrule", sender: sender)
    }
    var editingRule: Rule?
    func editRule(_ rule: Rule) {
        editingRule = rule
        self.performSegue(withIdentifier: "addrule", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addrule" {
            let dest = (segue.destination as! UINavigationController).viewControllers.last as! AddRuleViewController
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
            dest.hasFinalState = challenge.requiresEndState
            dest.tapeLength = challenge.goalTape.count
        }
    }
    
    func newRuleLabelWithRule(_ rule: Rule) {
        let previousRuleLabel = ruleLabels.last
        let newRuleLabel = UILabel(frame: CGRect.zero)
        newRuleLabel.textColor = TEXT_COLOR
        newRuleLabel.translatesAutoresizingMaskIntoConstraints = false
        newRuleLabel.textAlignment = .center
        newRuleLabel.isUserInteractionEnabled = true
        newRuleLabel.layer.cornerRadius = 5
        newRuleLabel.layer.borderWidth = 1
        newRuleLabel.layer.backgroundColor = RULE_BG_COLOR.cgColor
        newRuleLabel.layer.borderColor = RULE_BORDER_COLOR.cgColor
        newRuleLabel.attributedText = rule.preview
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.ruleTapped(_:)))
        tap.delegate = self
        newRuleLabel.addGestureRecognizer(tap)
        let swiper = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.ruleSwiped(_:)))
        swiper.direction = UISwipeGestureRecognizerDirection.left
        newRuleLabel.addGestureRecognizer(swiper)
        //ruleScrollView.contentSize = CGSizeMake(view.frame.width, CGFloat(rules.count)*(RULE_HEIGHT+RULE_SPACING))
        rulesContainer.addSubview(newRuleLabel)
        addConstraint(rulesContainer, at: .left, v2: newRuleLabel, at2: .left, c: -RULE_SPACING)
        addConstraint(rulesContainer, at: .right, v2: newRuleLabel, at2: .right, c: RULE_SPACING)
        addConstraint(newRuleLabel, at: .height, v2: nil, at2: .notAnAttribute, c: RULE_HEIGHT)
        if let prev = previousRuleLabel {
            addConstraint(prev, at: .bottom, v2: newRuleLabel, at2: .top, c: -RULE_SPACING)
        } else {
            addConstraint(rulesContainer, at: .top, v2: newRuleLabel, at2: .top, c: -RULE_SPACING)
        }
        ruleLabels.append(newRuleLabel)
        self.view.layoutIfNeeded()
        rulesContainerHeight.constant = newRuleLabel.frame.origin.y + newRuleLabel.frame.height + 10
        self.view.layoutIfNeeded()
    }
    
    func newRule(_ rule: Rule) {
        
        if let wasRule = editingRule {
            editingRule = nil
            if wasRule != rule {
                if let i = playMachine.rules.index(of: wasRule) {
                    deleteRuleAtIndex(i)
                }
            }
        }
        var indexToReplace: Int?
        for (index,ruleAlreadyExists) in playMachine.rules.enumerated() {
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
        
        ruleLabels[indexToReplace!].attributedText = rule.preview
        self.dismiss(animated: true, completion: nil)
    }
  
    func ruleTapped(_ tap: UITapGestureRecognizer) {
        //touchUp(tap.view!)
        let index = self.ruleLabels.index(of: tap.view as! UILabel)!
        editRule(playMachine.rules[index])
    }
  
    func ruleSwiped(_ swipe: UISwipeGestureRecognizer) {
        let index = self.ruleLabels.index(of: swipe.view as! UILabel)!
        // delete rule at index
        deleteRuleAtIndex(index)
    }
    
    func deleteRuleAtIndex(_ index: Int) {
        var rules = playMachine.rules
        rules.remove(at: index)
        resetWithRules(rules)
        
        let labelToRemove = self.ruleLabels[index]
        self.ruleLabels.remove(at: index)
        
        var toRemove = [NSLayoutConstraint]()
        for constraint in view.constraints {
            if let labelFirst = constraint.firstItem as? UILabel {
                if labelFirst == labelToRemove {
                    toRemove.append(constraint)
                    continue
                }
            }
            if let labelSecond = constraint.secondItem as? UILabel {
                if labelSecond == labelToRemove {
                    toRemove.append(constraint)
                }
            }
        }
        view.removeConstraints(toRemove)
    
        if index < self.ruleLabels.count {
            // not the last one, so have to fix constraint
            let labelToFix = self.ruleLabels[index]
            
            if index > 0 {
                let prev = self.ruleLabels[index-1]
                addConstraint(prev, at: .bottom, v2: labelToFix, at2: .top, c: -RULE_SPACING)
            } else {
                addConstraint(rulesContainer, at: .top, v2: labelToFix, at2: .top, c: -RULE_SPACING)
            }
        }
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
            labelToRemove.alpha = 0
            }, completion: { (a) -> Void in
                labelToRemove.removeFromSuperview()
        }) 
    }
    /*
    func touchDown(view: UIView) {
        view.layer.backgroundColor = UIColor.blueColor().CGColor
    }
    func touchUp(view: UIView) {
        view.layer.backgroundColor = UIColor.whiteColor().CGColor
    }
    */
    func highlightRule(_ rule: Rule?) {
        UIView.animate(withDuration: stepDelay, animations: { () -> Void in
            for (index,possibleRule) in self.playMachine.rules.enumerated() {
                if possibleRule == rule {
                    self.ruleLabels[index].layer.backgroundColor = RULE_HIGHLIGHT_COLOR.cgColor
                } else {
                    self.ruleLabels[index].layer.backgroundColor = RULE_BG_COLOR.cgColor
                }
            }
        })
    }
    
    func reset(_ button: UIBarButtonItem) {
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
    
    var timer: Timer?
    func play(_ button: TuringButtonView) {
        if button.title == "Pause" {
            self.timer?.invalidate()
            self.timer = nil
            button.title="Play"
            return
        }
        if playMachine.rules.count == 0 {
            flashAlerts("Your Turing Machine needs rules to run", "Tap Hint if you're stuck")
        } else {
            button.title="Pause"
            resetButton.title = "Reset"
            self.timer = Timer.scheduledTimer(timeInterval: stepDelay, target: self, selector: #selector(ViewController.nextStep(_:)), userInfo: button, repeats: true)
            self.updateUI()
        }
    }
    
    var stepDelay = 0.5
    
    func nextStep(_ timer: Timer) {
        if let rule = self.playMachine.step() {
            highlightRule(rule)
        } else {
            if playMachine.rules.count == 1 && playMachine.rulesUsed.count == 0 {
                flashAlerts("Your rule didn't run; check its condition", "Tap to edit a rule; swipe left to delete it")
            }
            if playMachine.tape == challenge.goalTape && challenge.requiresEndState {
                flashAlerts("This challenge requires an end-state", "You must finish in q\(challenge.maxState+1)")
            }
            highlightRule(nil)
            let button = timer.userInfo as! TuringButtonView
            button.title = "Play"
            button.enabled = false
            timer.invalidate()
            self.timer = nil
        }
        self.updateUI()
    }
    
    func tapAtIndex(_ index: Int, forView view: TuringTapeView) {
        self.step()
    }
    
    func step() {
        self.timer?.invalidate()
        self.timer = nil
        if let rule = self.playMachine.step() {
            highlightRule(rule)
        } else if self.playMachine.rules.count > 0 {
            highlightRule(nil)
        }
        self.updateUI()
    }
    
    func playStartingAlerts() {
        if playMachine.rules.count == 0 {
            if self.challenge.name == "Getting Started" {
                flashAlerts("Your Turing Machine needs rules to run", "Tap Add Rule to get started")
            } else if self.challenge.name == "Binary Counter" {
                self.flashAlerts("Reload a few times to see the pattern", "You should get comfortable with binary")
            /*} else if self.challenge.name == "Concise Condenser" {
                self.flashAlerts("Same as before, but with only 3 states")*/
            } else if self.challenge.name == "" {
                self.flashAlerts("This is a dummy level", "Please report as a bug")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if onscreen == false {
            onscreen = true
            playStartingAlerts()
        } else {
            if self.challenge.name == "Getting Started" {
                if playMachine.rules.count == 1 {
                    flashAlerts("Now you have a rule. Play your machine")
                }
            }
            
        }
        self.ruleScrollView.flashScrollIndicators()
    }
    func numberOfCharacters(forView view: TuringTapeView) -> Int {
        return challenge.startTape.count
    }
    func characterAtIndex(_ index: Int, forView view: TuringTapeView) -> String {
        if view.id == 0 {
            // playMachineTape
            return String((self.playMachine?.tape ?? challenge.startTape)[index])
        } else {
            return String(challenge.goalTape[index])
        }
    }
    
    func reset() {
        resetWithRules(challenge?.storedRules() ?? [])
    }
    
    func resetWithRules(_ rules: [Rule]) {
        self.title = challenge.name
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
    
    func flashAlerts(_ alerts: String...) {
        self.flashAlerts(alerts)
    }
    func flashAlert(_ alert: String) {
        self.flashAlerts(alert)
    }
    
    func flashAlerts(_ alerts: [String], offset: CGFloat = 0) {
        var alertTexts = alerts
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = alertTexts.remove(at: 0)
        label.textColor = ALERT_TEXT_COLOR
        label.backgroundColor = ALERT_BG_COLOR
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.layer.borderColor = ALERT_BORDER_COLOR.cgColor
        label.layer.borderWidth = 2
        label.textAlignment = NSTextAlignment.center
        label.alpha = 0
        view.addSubview(label)
        addConstraint(label, at: .centerX, v2: view, at2: .centerX)
        addConstraint(label, at: .centerY, v2: view, at2: .centerY, c: offset)
        addConstraint(label, at: .height, v2: nil, at2: .notAnAttribute, c: 30)
        addConstraint(label, at: .width, v2: view, at2: .width, c: -10)
        view.layoutIfNeeded()
        UIView.animate(withDuration: 1, animations: { () -> Void in
            label.alpha = 1
        }, completion: { (c) -> Void in
            if alertTexts.count > 0 {
                self.flashAlerts(alertTexts, offset: offset+40)
            }
            UIView.animate(withDuration: 4, animations: { () -> Void in
                label.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
                }, completion: { (a) -> Void in
                    UIView.animate(withDuration: 3, animations: { () -> Void in
                        label.alpha = 0
                        }, completion: { (s) -> Void in
                            label.removeFromSuperview()
                    })
            })
        })
    }
    
    func loadNextChallenge() {
        let rulesBefore = playMachine.rules
        while ruleLabels.count > 0 {
            deleteRuleAtIndex(0)
        }
        self.challenge.storeRules(rulesBefore)
        reloadChallenge(self.challenge.index+1)
        if playMachine.rules.count == 0 {
            playStartingAlerts()
        }
    }
    
    func reloadChallenge(_ index: Int! = nil) {
        var index = index
        if index == nil {
            index = self.challenge.index
            if self.challenge.name == "Bit flipper" {
                self.flashAlert("Try out your machine on a different tape")
            }
        }
        self.challenge = TuringChallenge(index: index!)
        self.reset()
        self.ruleScrollView.flashScrollIndicators()
    }
    
    func calculateAccuracy(andThen callback: @escaping (Double)->Void) {
        OperationQueue().addOperation { () -> Void in
            let accuracy = TuringChallenge.challengeAccuracy(forIndex: self.challenge.index)
            OperationQueue.main.addOperation { () -> Void in
                callback(accuracy)
            }
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
        
        if playMachine.tape == challenge.goalTape && (!challenge.requiresEndState || playMachine.state > challenge.maxState) {
            // win
            timer?.invalidate()
            timer = nil
            playButton.title = "Play"
            flashAlert("Testing on 100 random tapes...")
            self.calculateAccuracy(andThen: { (accuracy) -> Void in
                let percentage =  Int(round(accuracy*100))
                var alert = UIAlertController(title: "Challenge completed with accuracy \(percentage)%", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Play Again", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.reloadChallenge()
                }))
                alert.addAction(UIAlertAction(title: "Select Level", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    _ = self.navigationController?.popViewController(animated: true)
                }))
                if self.challenge.index < MAX_CHALLENGE_INDEX {
                    alert.addAction(UIAlertAction(title: "Next Level", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.loadNextChallenge()
                    }))
                }
                self.present(alert, animated: true, completion: nil)
            })
            return
        }
        if indexToMoveTo < 0 || indexToMoveTo >= playMachine.tape.count {
            if challenge.goalTape == playMachine.tape && challenge.requiresEndState {
                flashAlerts("This challenge requires an end-state", "You must finish in q\(challenge.maxState+1)")
            } else if challenge.index < 5 {
                flashAlerts("Stay on your section of tape", "Try moving the other direction")
            } else if challenge.requiresEndState {
                flashAlerts("Stay on your section of tape", "This challenge requires an end-state", "You must finish in q\(challenge.maxState+1)")
            } else {
                flashAlert("Stay on your section of tape")
            }
            reset()
        } else {
            self.view.removeConstraint(headViewConstraint)
            headViewConstraint = NSLayoutConstraint(item: tapeHeadView, attribute: .centerX, relatedBy: .equal, toItem: playTapeView.viewAtIndex(playMachine.index), attribute: .centerX, multiplier: 1, constant: 0)
            view.addConstraint(headViewConstraint)
        }
        func colorChange() {
            for i in 0 ..< challenge.startTape.count {
                playTapeView.viewColorChange(i, newColor: i==playMachine.index ? TAPE_SELECTED_COLOR : TAPE_BG_COLOR)
            }
        }
        func layoutAndColorChange() {
            self.view.layoutIfNeeded()
            colorChange()
        }
        if onscreen {
            UIView.animate(withDuration: stepDelay, delay: 0, options: UIViewAnimationOptions(), animations: layoutAndColorChange, completion: nil)
        } else {
            colorChange()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

