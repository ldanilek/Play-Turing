//
//  TuringTapeView.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

protocol TuringTapeViewDelegate {
    func numberOfCharacters(forView: TuringTapeView) -> Int // should never change
    func characterAtIndex(_ index: Int, forView: TuringTapeView) -> String // will usually be a character
    func tapAtIndex(_ index: Int, forView view: TuringTapeView)
}

let LABELSEPARATION: CGFloat = 5

let TEAL_COLOR = UIColor(red: 35.0/255.0, green: 92.0/255.0, blue: 155.0/255.0, alpha: 1)
let LIGHT_BLUE_COLOR = UIColor(red: 102.0/255.0, green: 180.0/255.0, blue: 214.0/255.0, alpha: 1)
let NAVY_BLUE_COLOR = UIColor(red: 16.0/255.0, green: 27.0/255.0, blue: 78.0/255.0, alpha: 1)
let OFF_WHITE_COLOR = UIColor(red: 196.0/255.0, green: 204.0/255.0, blue: 219.0/255.0, alpha: 1)

let TAPE_BORDER_COLOR = LIGHT_BLUE_COLOR//UIColor(red: 49.0/255.0, green: 120.0/255.0, blue: 142.0/255.0, alpha: 1)//UIColor(red: 77.0/255.0, green: 188.0/255.0, blue: 202.0/255.0, alpha: 1)
let TAPE_SELECTED_COLOR = NAVY_BLUE_COLOR//UIColor(white: 34.0/255.0, alpha: 1)//UIColor(red: 144.0/255.0, green: 230.0/255.0, blue: 255.0/255.0, alpha: 1)//UIColor.greenColor()
let TAPE_BG_COLOR = TEAL_COLOR
let TAPE_CHAR_COLOR = UIColor.white


class TuringTapeView: UIView {
    let delegate: TuringTapeViewDelegate
    let id: Int
    
    var charViews: [UILabel] = []
    
    var labelWidth: CGFloat!
    
    func addCharView() {
        let newLabel = UILabel(frame: CGRect.zero)
        newLabel.textAlignment = NSTextAlignment.center
        newLabel.layer.backgroundColor = TAPE_BG_COLOR.cgColor
        newLabel.layer.borderColor = TAPE_BORDER_COLOR.cgColor
        newLabel.layer.borderWidth = 2
        newLabel.layer.masksToBounds = true
        newLabel.textColor = TAPE_CHAR_COLOR
        if #available(iOS 8.2, *) {
            newLabel.font = UIFont.systemFont(ofSize: newLabel.font.pointSize, weight: UIFontWeightBlack)
        } else {
            // Fallback on earlier versions
            newLabel.font = UIFont.systemFont(ofSize: newLabel.font.pointSize)
        } // want weight
        newLabel.isUserInteractionEnabled = true
        newLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TuringTapeView.tap(_:))))
        //newLabel.layer.cornerRadius = 5
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(newLabel)
        self.charViews.append(newLabel)
    }
    
    // animatable
    func viewColorChange(_ index: Int, newColor: UIColor) {
        let label = self.charViews[index]
        label.layer.backgroundColor = newColor.cgColor
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
        self.removeConstraints(self.constraints)
        for i in 0 ..< self.charViews.count {
            let label = self.charViews[i]
            addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 0))
            if i == self.charViews.count-1 {
                addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: label, attribute: .trailing, multiplier: 1, constant: 0))
            }
            if i == 0 {
                addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1, constant: 0))
            } else {
                let prevLabel = self.charViews[i-1]
                addConstraint(NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: prevLabel, attribute: .right, multiplier: 1, constant: -2))
                addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: prevLabel, attribute: .width, multiplier: 1, constant: 0))
            }
        }
    }
    
    init(frame: CGRect, delegate: TuringTapeViewDelegate, id: Int) {
        self.delegate = delegate
        self.id = id
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        let n = delegate.numberOfCharacters(forView: self)
        // let labelHeight = self.bounds.height
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
    
    func tap(_ tap: UITapGestureRecognizer) {
        delegate.tapAtIndex(charViews.index(of: tap.view as! UILabel)!, forView: self)
    }
    
    func reload() {
        let n = delegate.numberOfCharacters(forView: self)
        if n != self.charViews.count {
            self.removeConstraints(self.constraints)
            while self.charViews.count < n {
                addCharView()
            }
            while self.charViews.count > n {
                removeCharView()
            }
            resetAllConstraints()
            self.layoutIfNeeded()
        }
        for i in 0 ..< n {
            charViews[i].text = String(delegate.characterAtIndex(i, forView: self))
        }
    }
    
    func viewAtIndex(_ index: Int) -> UIView {
        return self.charViews[index]
    }

    required init?(coder aDecoder: NSCoder) {
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
