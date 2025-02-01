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
    
    func setState(_ state: Int?) {
        if let s = state {
            self.stateView.text = "q\(s)"
        } else {
            self.stateView.text = " "
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        stateView = UILabel(frame: CGRect.zero)
        stateView.font = UIFont(name: MAIN_FONT_NAME, size: 20)
        stateView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stateView)
        addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: stateView, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: stateView, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: stateView, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stateView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.75, constant: 0))
        stateView.textAlignment = .center
        self.backgroundColor = VIEW_BACKGROUND_COLOR
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let headWidth: CGFloat = 20
    let headHeight: CGFloat = 5.5
    let yOffset: CGFloat = 2 // offset from top
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width/2, y: yOffset))
        path.addLine(to: CGPoint(x: frame.width/2-headWidth/2, y: yOffset+headHeight))
        path.addLine(to: CGPoint(x: frame.width/2+headWidth/2, y: yOffset+headHeight))
        path.addLine(to: CGPoint(x: frame.width/2, y: yOffset))
        TEXT_COLOR.setFill()
        path.stroke()
    }
    

}
