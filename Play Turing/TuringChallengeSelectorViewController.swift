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

func leftHalf(_ i: Int) -> Int {
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
        //let time = UInt32(Date().timeIntervalSinceReferenceDate) &+ UInt32(arc4random()) // add rand because don't want to seed with the same number every time
        //srand(time)
        return arc4random()%2==0 ? leftHalf(levelsPerLine) : levelsPerLine/2 + 1
    }
    var animating: Bool = false
    var spacerViews: [UIView] = []
    
    func makeSpacerView() -> UIView {
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacerView)
        spacerView.alpha = 0
        view.addConstraint(NSLayoutConstraint(item: spacerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: spacerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        if let oldSpacerView = spacerViews.last {
            view.addConstraint(NSLayoutConstraint(item: oldSpacerView, attribute: .height, relatedBy: .equal, toItem: spacerView, attribute: .height, multiplier: 1, constant: 0))
        }
        spacerViews.append(spacerView)
        return spacerView
    }
    
    func numberOfCharacters(forView: TuringTapeView) -> Int {
        return levelsPerLine
    }
    func characterAtIndex(_ index: Int, forView view: TuringTapeView) -> String {
        let row = view.id
        return "\(row*levelsPerLine+index)"
    }
    func tapAtIndex(_ index: Int, forView view: TuringTapeView) {
        self.performSegue(withIdentifier: "challenge", sender: NSString(string:characterAtIndex(index, forView: view)))
    }
    
    let tapeSpacing: CGFloat = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = "Levels" // UIBarButtonItem(title: "Levels", style: UIBarButtonItemStyle.plain, target: nil, action: "")
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        
        for i in 0 ..< levelLines {
            let tape = TuringTapeView(frame: CGRect.zero, delegate: self, id: i)
            tapes.append(tape)
            let tapeHead = TuringHeadView(frame: CGRect.zero)
            tapeHeads.append(tapeHead)
            tapeHead.translatesAutoresizingMaskIntoConstraints = false
            tape.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(tape)
            self.view.addSubview(tapeHead)
            
            tapeHead.addConstraint(NSLayoutConstraint(item: tapeHead, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: TAPE_HEAD_WIDTH))
            tapeHead.addConstraint(NSLayoutConstraint(item: tapeHead, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: TAPE_HEAD_HEIGHT))
            tapeHead.setState(nil)
            view.addConstraint(NSLayoutConstraint(item: tapeHead, attribute: .top, relatedBy: .equal, toItem: tape, attribute: .bottom, multiplier: 1, constant: 0))
            let headCenteringConstraint = NSLayoutConstraint(item: tapeHead, attribute: .centerX, relatedBy: .equal, toItem: tape, attribute: .centerX, multiplier: 1, constant: 0)
            headCenteringConstraints.append(headCenteringConstraint)
            view.addConstraint(headCenteringConstraint)
            
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: tape, attribute: .leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: tape, attribute: .trailing, multiplier: 1, constant: 0))

            let newSpacerView = makeSpacerView()
            view.addConstraint(NSLayoutConstraint(item: tape, attribute: .top, relatedBy: .equal, toItem: newSpacerView, attribute: .bottom, multiplier: 1, constant: 0))
            
            if i == 0 {
                view.addConstraint(NSLayoutConstraint(item: self.topLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: newSpacerView, attribute: .top, multiplier: 1, constant: 0))
                tape.addConstraint(NSLayoutConstraint(item: tape, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: TAPE_HEIGHT))
            } else {
                let prevtape = tapes[i-1]
                
                view.addConstraint(NSLayoutConstraint(item: prevtape, attribute: .bottom, relatedBy: .equal, toItem: newSpacerView, attribute: .top, multiplier: 1, constant: 0))
                
                view.addConstraint(NSLayoutConstraint(item: prevtape, attribute: .height, relatedBy: .equal, toItem: tape, attribute: .height, multiplier: 1, constant: 0))
                if i == levelLines-1 {
                    let bottomSpacerView = makeSpacerView()
                    view.addConstraint(NSLayoutConstraint(item: tape, attribute: .bottom, relatedBy: .equal, toItem: bottomSpacerView, attribute: .top, multiplier: 1, constant: 0))
                    view.addConstraint(NSLayoutConstraint(item: self.bottomLayoutGuide, attribute: .top, relatedBy: .equal, toItem: bottomSpacerView, attribute: .bottom, multiplier: 1, constant: 0))
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectChallenge(_ button: UIButton) {
        self.performSegue(withIdentifier: "challenge", sender: button)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        animating = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !animating {
            animating = true
            self.animate()
        }
        //timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "animate:", userInfo: nil, repeats: true)
    }
    
    func animate() {
        for i in 0 ..< levelLines {
            let tapeHead = tapeHeads[i]
            var indexToSelect = selectedIndices[i]
            let tapePartToSelect = tapes[i].viewAtIndex(indexToSelect)
            view.removeConstraint(headCenteringConstraints[i])
            headCenteringConstraints[i] = NSLayoutConstraint(item: tapeHead, attribute: .centerX, relatedBy: .equal, toItem: tapePartToSelect, attribute: .centerX, multiplier: 1, constant: 0)
            view.addConstraint(headCenteringConstraints[i])
            if indexToSelect == 0 {
                indexToSelect = 1
            } else if indexToSelect == levelsPerLine-1 {
                indexToSelect = levelsPerLine-2
            } else {
                indexToSelect += (arc4random()%2==0) ? -1 : 1
            }
            selectedIndices[i] = indexToSelect
        }
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (c) -> Void in
                if self.animating {
                    self.animate()
                }
        })
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "challenge" {
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
            let string = String(sender as! NSString)
            let challengeIndex = NumberFormatter().number(from: string)!.intValue
            let dest = segue.destination as! ViewController
            dest.challenge = TuringChallenge(index: challengeIndex)
        } else {
            //let dest = segue.destinationViewController as!
        }
        
    }
    

}
