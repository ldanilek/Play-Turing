//
//  TuringTapeView.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

protocol TuringTapeViewDelegate {
    func numberOfCharacters(#forView: TuringTapeView) -> Int // should never change
    func characterAtIndex(index: Int, forView: TuringTapeView) -> String // will usually be a character
    func tapAtIndex(index: Int, forView view: TuringTapeView)
}

let LABELSEPARATION: CGFloat = 5

let TAPE_BG_COLOR = UIColor(red: 0.7, green: 0.7, blue: 1, alpha: 1)
let TAPE_SELECTED_COLOR = UIColor.greenColor()

class TuringTapeView: UIView {
    let delegate: TuringTapeViewDelegate
    let id: Int
    
    var charViews: [UILabel] = []
    
    var labelWidth: CGFloat!
    
    func addCharView() {
        var newLabel = UILabel(frame: CGRectZero)
        newLabel.textAlignment = NSTextAlignment.Center
        newLabel.layer.backgroundColor = TAPE_BG_COLOR.CGColor
        newLabel.layer.borderColor = UIColor.blueColor().CGColor
        newLabel.layer.borderWidth = 2
        newLabel.layer.masksToBounds = true
        newLabel.userInteractionEnabled = true
        newLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tap:"))
        //newLabel.layer.cornerRadius = 5
        newLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(newLabel)
        self.charViews.append(newLabel)
    }
    
    // animatable
    func viewColorChange(index: Int, newColor: UIColor) {
        var label = self.charViews[index]
        label.layer.backgroundColor = newColor.CGColor
        //label.backgroundColor = newColor
        /*var newCharView = UILabel()
        var oldView = self.viewAtIndex(index) as! UILabel
        newCharView.text = oldView.text
        self.addSubview(newCharView)
        newCharView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: newCharView, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: newCharView, attribute: .Bottom, multiplier: 1, constant: 0))
        if index == self.charViews.count - 1 {
            addConstraint(NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: newCharView, attribute: .Trailing, multiplier: 1, constant: 0))
        } else {
            var nextLabel = self.charViews[index+1]
            addConstraint(NSLayoutConstraint(item: newCharView, attribute: .Width, relatedBy: .Equal, toItem: nextLabel, attribute: .Width, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: newCharView, attribute: .Right, relatedBy: .Equal, toItem: nextLabel, attribute: .Left, multiplier: 1, constant: 0))
        }
        if index == 0 {
            addConstraint(NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: newCharView, attribute: .Leading, multiplier: 1, constant: 0))
        } else {
            let prevLabel = self.charViews[index-1]
            addConstraint(NSLayoutConstraint(item: newCharView, attribute: .Left, relatedBy: .Equal, toItem: prevLabel, attribute: .Right, multiplier: 1, constant: -2))
            addConstraint(NSLayoutConstraint(item: newCharView, attribute: .Width, relatedBy: .Equal, toItem: prevLabel, attribute: .Width, multiplier: 1, constant: 0))
        }
        
        newCharView.alpha = 0
        self.charViews[index] = newCharView
        UIView.animateWithDuration(duration, animations: { () -> Void in
            newCharView.alpha = 1
        }) { (a) -> Void in
            oldView.removeFromSuperview()
        }*/
    }
    
    func removeCharView() {
        self.charViews.removeLast().removeFromSuperview()
    }
    
    func resetAllConstraints() {
        self.removeConstraints(self.constraints())
        for var i = 0; i < self.charViews.count; i++ {
            let label = self.charViews[i]
            addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: label, attribute: .Top, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: label, attribute: .Bottom, multiplier: 1, constant: 0))
            if i == self.charViews.count-1 {
                addConstraint(NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: label, attribute: .Trailing, multiplier: 1, constant: 0))
            }
            if i == 0 {
                addConstraint(NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: label, attribute: .Leading, multiplier: 1, constant: 0))
            } else {
                let prevLabel = self.charViews[i-1]
                addConstraint(NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: prevLabel, attribute: .Right, multiplier: 1, constant: -2))
                addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: prevLabel, attribute: .Width, multiplier: 1, constant: 0))
            }
        }
    }
    
    init(frame: CGRect, delegate: TuringTapeViewDelegate, id: Int) {
        self.delegate = delegate
        self.id = id
        super.init(frame: frame)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        let n = delegate.numberOfCharacters(forView: self)
        let labelHeight = self.bounds.height
        let totalWidth = self.bounds.width
        // n*LABELWIDTH + (n-1)*LABELSEPARATION = TOTALWIDTH
        labelWidth = (totalWidth-CGFloat(n-1)*LABELSEPARATION)/CGFloat(n)
        while n > self.charViews.count {
            self.addCharView()
        }
        self.resetAllConstraints()
        //self.backgroundColor = TAPE_BG_COLOR
        
        self.reload()
    }
    
    func tap(tap: UITapGestureRecognizer) {
        delegate.tapAtIndex(find(charViews, tap.view as! UILabel)!, forView: self)
    }
    
    func reload() {
        let n = delegate.numberOfCharacters(forView: self)
        if n != self.charViews.count {
            self.removeConstraints(self.constraints())
            while self.charViews.count < n {
                addCharView()
            }
            while self.charViews.count > n {
                removeCharView()
            }
            resetAllConstraints()
            self.layoutIfNeeded()
        }
        for var i = 0; i < n; i++ {
            charViews[i].text = String(delegate.characterAtIndex(i, forView: self))
        }
    }
    
    func viewAtIndex(index: Int) -> UIView {
        return self.charViews[index]
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        // Drawing code
    }
    
*/
}
