//
//  TuringButtonView.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/13/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

let DARK_ORANGE_COLOR = UIColor(red: 140.0/255.0, green: 63.0/255.0, blue: 28.0/255.0, alpha: 1)
let ORANGE_COLOR = UIColor(red: 232.0/255.0, green: 117.0/255.0, blue: 0, alpha: 1)

let BUTTON_BG_COLOR = ORANGE_COLOR//UIColor.orangeColor()//UIColor(red: 0.3, green: 1, blue: 0.3, alpha: 1)
let BUTTON_TEXT_COLOR = UIColor.whiteColor()

let BUTTON_FONT_SIZE: CGFloat = 25
let BUTTON_FONT = UIFont(name: MAIN_FONT_NAME, size: BUTTON_FONT_SIZE)

class TuringButtonView: UIView {
    
    var label: UILabel!
    
    var title: String? {
        didSet {
            label.text = title
        }
    }
    
    var enabled: Bool = true {
        didSet {
            label.alpha = enabled ? 1 : 0.4
        }
    }
    
    var pressed: Bool = false {
        didSet {
            if pressed {
                label.alpha = 0.4
            } else {
                label.alpha = 1
            }
        }
    }
    
    var action: ()->Void = {}
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if enabled {
            pressed = true
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if enabled {
            pressed = false
            self.action()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 8
        self.backgroundColor = BUTTON_BG_COLOR
        
        self.userInteractionEnabled = true
        label = UILabel(frame: CGRectZero)
        addSubview(label)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = NSTextAlignment.Center
        label.font = BUTTON_FONT
        label.textColor = BUTTON_TEXT_COLOR
        addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: label, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: label, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: label, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: label, attribute: .Leading, multiplier: 1, constant: 0))
        
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
