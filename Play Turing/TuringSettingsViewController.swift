//
//  TuringSettingsViewController.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/13/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

class TuringSettingsViewController: UIViewController {

    @IBAction func unlockAllHints(sender: UIButton) {
        self.unlockHintsButton.enabled = false
        self.unlockHintsButton.setTitle("Buying...", forState: .Normal)
        TuringSettings.sharedInstance.downloadHints {
            if TuringSettings.sharedInstance.hintsUnlocked {
                self.unlockHintsButton.setTitle("Bought", forState: .Normal)
            } else {
                self.unlockHintsButton.setTitle("Buy Failed", forState: .Normal)
            }
        }
    }
    @IBAction func restorePurchase(sender: UIButton) {
        //
        //self.restorePurchaseButton?.setTitle("Restoring...", forState: .Normal)
        TuringSettings.sharedInstance.restoreHints {
            if TuringSettings.sharedInstance.hintsUnlocked {
                self.restorePurchaseButton?.enabled = false
                self.restorePurchaseButton?.setTitle("Restored", forState: .Normal)
                self.unlockHintsButton.enabled = false
                self.unlockHintsButton.setTitle("Bought", forState: .Normal)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutTextView.editable = false
        unlockHintsButton.setTitle("Loading Price...", forState: .Normal)
        unlockHintsButton.enabled = false
        if TuringSettings.sharedInstance.hintsUnlocked {
            self.unlockHintsButton.setTitle("Bought", forState: .Normal)
            self.restorePurchaseButton?.enabled = false
            //self.restorePurchaseButton?.setTitle("", forState: <#UIControlState#>)
        } else {
            TuringSettings.sharedInstance.getHintsPriceString {
                if let price = TuringSettings.sharedInstance.hintsPriceString {
                    self.unlockHintsButton.setTitle("Buy (\(price))", forState: .Normal)
                    self.unlockHintsButton.enabled = true
                } else {
                    self.unlockHintsButton.setTitle("No Connection", forState: .Normal)
                }
            }
        }
        self.aboutTextView.attributedText = TuringSettings.sharedInstance.aboutText
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var restorePurchaseButton: UIButton?
    @IBOutlet weak var unlockHintsButton: UIButton!
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var aboutTextView: UITextView!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
