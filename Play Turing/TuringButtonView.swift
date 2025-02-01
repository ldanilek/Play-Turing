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
let BUTTON_TEXT_COLOR = UIColor.white

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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if enabled {
            pressed = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if enabled {
            pressed = false
            self.action()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 8
        self.backgroundColor = BUTTON_BG_COLOR
        
        self.isUserInteractionEnabled = true
        label = UILabel(frame: CGRect.zero)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        label.font = BUTTON_FONT
        label.textColor = BUTTON_TEXT_COLOR
        addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: label, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1, constant: 0))
        
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
