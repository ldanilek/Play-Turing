//
//  TuringChallengeSelectorViewController.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/3/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

let CHALLENGE_BUTTON_WIDTH: CGFloat = 40
let CHALLENGE_BUTTON_HEIGHT: CGFloat = 50
let CHALLENGE_BUTTON_PADDING: CGFloat = 20

let levelsPerLine: Int = 5
let levelLines: Int = 5

func leftHalf(i: Int) -> Int {
    if i%2 == 1 {
        return i/2-1
    }
    return i/2
}

class TuringChallengeSelectorViewController: UIViewController, TuringTapeViewDelegate {
    
    //var buttons: [UIButton] = []
    var tapes: [TuringTapeView] = []
    var tapeHeads: [TuringHeadView] = []
    var headCenteringConstraints: [NSLayoutConstraint] = []
    var selectedIndices: [Int] = Array(count: levelLines) { () -> Int in
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate) &+ UInt32(rand()) // add rand because don't want to seed with the same number every time
        srand(time)
        return rand()%2==0 ? leftHalf(levelsPerLine) : levelsPerLine/2 + 1
    }
    var animating: Bool = false
    var spacerViews: [UIView] = []
    
    func makeSpacerView() -> UIView {
        var spacerView = UIView()
        spacerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(spacerView)
        spacerView.alpha = 0
        view.addConstraint(NSLayoutConstraint(item: spacerView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: spacerView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
        if let oldSpacerView = spacerViews.last {
            view.addConstraint(NSLayoutConstraint(item: oldSpacerView, attribute: .Height, relatedBy: .Equal, toItem: spacerView, attribute: .Height, multiplier: 1, constant: 0))
        }
        spacerViews.append(spacerView)
        return spacerView
    }
    
    func numberOfCharacters(#forView: TuringTapeView) -> Int {
        return levelsPerLine
    }
    func characterAtIndex(index: Int, forView view: TuringTapeView) -> String {
        let row = view.id
        return "\(row*levelsPerLine+index)"
    }
    func tapAtIndex(index: Int, forView view: TuringTapeView) {
        self.performSegueWithIdentifier("challenge", sender: NSString(string:characterAtIndex(index, forView: view)))
    }
    
    let tapeSpacing: CGFloat = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Levels", style: UIBarButtonItemStyle.Plain, target: nil, action: "")
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        for var i = 0; i < levelLines; i++ {
            var tape = TuringTapeView(frame: CGRectZero, delegate: self, id: i)
            tapes.append(tape)
            var tapeHead = TuringHeadView(frame: CGRectZero)
            tapeHeads.append(tapeHead)
            tapeHead.setTranslatesAutoresizingMaskIntoConstraints(false)
            tape.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addSubview(tape)
            self.view.addSubview(tapeHead)
            
            tapeHead.addConstraint(NSLayoutConstraint(item: tapeHead, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TAPE_HEAD_WIDTH))
            tapeHead.addConstraint(NSLayoutConstraint(item: tapeHead, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TAPE_HEAD_HEIGHT))
            tapeHead.setState(nil)
            view.addConstraint(NSLayoutConstraint(item: tapeHead, attribute: .Top, relatedBy: .Equal, toItem: tape, attribute: .Bottom, multiplier: 1, constant: 0))
            var headCenteringConstraint = NSLayoutConstraint(item: tapeHead, attribute: .CenterX, relatedBy: .Equal, toItem: tape, attribute: .CenterX, multiplier: 1, constant: 0)
            headCenteringConstraints.append(headCenteringConstraint)
            view.addConstraint(headCenteringConstraint)
            
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: tape, attribute: .Leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: tape, attribute: .Trailing, multiplier: 1, constant: 0))

            var newSpacerView = makeSpacerView()
            view.addConstraint(NSLayoutConstraint(item: tape, attribute: .Top, relatedBy: .Equal, toItem: newSpacerView, attribute: .Bottom, multiplier: 1, constant: 0))
            
            if i == 0 {
                view.addConstraint(NSLayoutConstraint(item: self.topLayoutGuide, attribute: .Bottom, relatedBy: .Equal, toItem: newSpacerView, attribute: .Top, multiplier: 1, constant: 0))
                tape.addConstraint(NSLayoutConstraint(item: tape, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TAPE_HEIGHT))
            } else {
                let prevtape = tapes[i-1]
                
                view.addConstraint(NSLayoutConstraint(item: prevtape, attribute: .Bottom, relatedBy: .Equal, toItem: newSpacerView, attribute: .Top, multiplier: 1, constant: 0))
                
                view.addConstraint(NSLayoutConstraint(item: prevtape, attribute: .Height, relatedBy: .Equal, toItem: tape, attribute: .Height, multiplier: 1, constant: 0))
                if i == levelLines-1 {
                    var bottomSpacerView = makeSpacerView()
                    view.addConstraint(NSLayoutConstraint(item: tape, attribute: .Bottom, relatedBy: .Equal, toItem: bottomSpacerView, attribute: .Top, multiplier: 1, constant: 0))
                    view.addConstraint(NSLayoutConstraint(item: self.bottomLayoutGuide, attribute: .Top, relatedBy: .Equal, toItem: bottomSpacerView, attribute: .Bottom, multiplier: 1, constant: 0))
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectChallenge(button: UIButton) {
        self.performSegueWithIdentifier("challenge", sender: button)
    }

    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        animating = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !animating {
            animating = true
            self.animate()
        }
        //timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "animate:", userInfo: nil, repeats: true)
    }
    
    func animate() {
        for var i = 0; i < levelLines; i++ {
            let tapeHead = tapeHeads[i]
            var indexToSelect = selectedIndices[i]
            let tapePartToSelect = tapes[i].viewAtIndex(indexToSelect)
            view.removeConstraint(headCenteringConstraints[i])
            headCenteringConstraints[i] = NSLayoutConstraint(item: tapeHead, attribute: .CenterX, relatedBy: .Equal, toItem: tapePartToSelect, attribute: .CenterX, multiplier: 1, constant: 0)
            view.addConstraint(headCenteringConstraints[i])
            if indexToSelect == 0 {
                indexToSelect = 1
            } else if indexToSelect == levelsPerLine-1 {
                indexToSelect = levelsPerLine-2
            } else {
                indexToSelect += (rand()%2==0) ? -1 : 1
            }
            selectedIndices[i] = indexToSelect
        }
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (c) -> Void in
                if self.animating {
                    self.animate()
                }
        })
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "challenge" {
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
            let string = String(sender as! NSString)
            let challengeIndex = NSNumberFormatter().numberFromString(string)!.integerValue
            let dest = segue.destinationViewController as! ViewController
            dest.challenge = TuringChallenge(index: challengeIndex)
        } else {
            //let dest = segue.destinationViewController as!
        }
        
    }
    

}
