//
//  TuringHeadView.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/2/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

class TuringHeadView: UIView {
    
    var stateView: UILabel!
    
    func setState(state: Int?) {
        if let s = state {
            self.stateView.text = "q\(s)"
        } else {
            self.stateView.text = " "
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        stateView = UILabel(frame: CGRectZero)
        stateView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(stateView)
        addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: stateView, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: stateView, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: stateView, attribute: .Trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stateView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 0.75, constant: 0))
        stateView.textAlignment = .Center
        self.backgroundColor = UIColor.whiteColor()
        
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        var path = UIBezierPath()
        path.moveToPoint(CGPointMake(frame.width/2, 2))
        path.addLineToPoint(CGPointMake(frame.width/2-10, frame.height/4))
        path.addLineToPoint(CGPointMake(frame.width/2+10, frame.height/4))
        path.addLineToPoint(CGPointMake(frame.width/2, 2))
        UIColor.blackColor().setFill()
        path.stroke()
    }
    

}
