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

class TuringChallengeSelectorViewController: UIViewController, TuringTapeViewDelegate {
    
    //var buttons: [UIButton] = []
    var tapes: [TuringTapeView] = []
    
    func numberOfCharacters(#forView: TuringTapeView) -> Int {
        return 4
    }
    func characterAtIndex(index: Int, forView view: TuringTapeView) -> String {
        let row = view.id
        return "\(row*4+index)"
    }
    func tapAtIndex(index: Int, forView view: TuringTapeView) {
        self.performSegueWithIdentifier("challenge", sender: NSString(string:characterAtIndex(index, forView: view)))
    }
    
    let tapeSpacing: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Levels", style: UIBarButtonItemStyle.Plain, target: nil, action: "")
        
        for var i = 0; i < 4; i++ {
            var tape = TuringTapeView(frame: CGRectZero, delegate: self, id: i)
            tapes.append(tape)
            self.view.addSubview(tape)
            
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: tape, attribute: .Leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: tape, attribute: .Trailing, multiplier: 1, constant: 0))

            if i == 0 {
                view.addConstraint(NSLayoutConstraint(item: self.topLayoutGuide, attribute: .Bottom, relatedBy: .Equal, toItem: tape, attribute: .Top, multiplier: 1, constant: -tapeSpacing))
            } else {
                let prevtape = tapes[i-1]
                view.addConstraint(NSLayoutConstraint(item: prevtape, attribute: .Bottom, relatedBy: .Equal, toItem: tape, attribute: .Top, multiplier: 1, constant: -tapeSpacing))
                view.addConstraint(NSLayoutConstraint(item: prevtape, attribute: .Height, relatedBy: .Equal, toItem: tape, attribute: .Height, multiplier: 1, constant: 0))
                if i == 3 {
                    view.addConstraint(NSLayoutConstraint(item: self.bottomLayoutGuide, attribute: .Top, relatedBy: .Equal, toItem: tape, attribute: .Bottom, multiplier: 1, constant: tapeSpacing))
                }
            }
        }
        
        /*
        // padding*2 + spacing*3 + button*4 = width and hight
        let verticalSpacing = (view.frame.height - CHALLENGE_BUTTON_HEIGHT*4 - CHALLENGE_BUTTON_PADDING*2)/3.0
        let horizontalSpacing = (view.frame.width - CHALLENGE_BUTTON_WIDTH*4 - CHALLENGE_BUTTON_PADDING*2)/3.0
        
        for var i = 0; i < 16; i++ {
            let row = i/4
            let col = i%4
            var button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            self.view.addSubview(button)
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            if row==0 {
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: CHALLENGE_BUTTON_PADDING))
            } else {
                let buttonAbove = buttons[(row-1)*4 + col]
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: buttonAbove, attribute: .Bottom, multiplier: 1, constant: CHALLENGE_BUTTON_PADDING))
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: buttonAbove, attribute: .Height, multiplier: 1, constant: 0))
                if row==3 {
                    view.addConstraint(NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: -CHALLENGE_BUTTON_PADDING))
                }
            }
            if col==0 {
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: CHALLENGE_BUTTON_PADDING))
            } else {
                let buttonAbove = buttons[row*4 + col - 1]
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: buttonAbove, attribute: .Right, multiplier: 1, constant: CHALLENGE_BUTTON_PADDING))
                view.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: buttonAbove, attribute: .Width, multiplier: 1, constant: 0))
                if col==3 {
                    view.addConstraint(NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -CHALLENGE_BUTTON_PADDING))
                }
            }
            button.setTitle("\(i)", forState: .Normal)
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 2
            button.addTarget(self, action: "selectChallenge:", forControlEvents: .TouchUpInside)
            buttons.append(button)
        }
*/
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let string = String(sender as! NSString)
        let challengeIndex = NSNumberFormatter().numberFromString(string)!.integerValue
        let dest = segue.destinationViewController as! ViewController
        dest.challenge = TuringChallenge(index: challengeIndex)
    }
    

}
