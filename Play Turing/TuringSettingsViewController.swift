//
//  TuringSettingsViewController.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/13/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

class TuringSettingsViewController: UIViewController {

    @IBAction func unlockAllHints(_ sender: UIButton) {
        self.unlockHintsButton.isEnabled = false
        self.unlockHintsButton.setTitle("Buying...", for: UIControlState())
        TuringSettings.sharedInstance.downloadHints {
            if TuringSettings.sharedInstance.hintsUnlocked {
                self.unlockHintsButton.setTitle("Bought", for: UIControlState())
            } else {
                self.unlockHintsButton.setTitle("Buy Failed", for: UIControlState())
            }
        }
    }
    @IBAction func restorePurchase(_ sender: UIButton) {
        //
        //self.restorePurchaseButton?.setTitle("Restoring...", forState: .Normal)
        TuringSettings.sharedInstance.restoreHints {
            if TuringSettings.sharedInstance.hintsUnlocked {
                self.restorePurchaseButton?.isEnabled = false
                self.restorePurchaseButton?.setTitle("Restored", for: UIControlState())
                self.unlockHintsButton.isEnabled = false
                self.unlockHintsButton.setTitle("Bought", for: UIControlState())
            }
        }
    }
    @IBAction func buttonPressed(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var mybutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = VIEW_BACKGROUND_COLOR
        aboutTextView.isEditable = false
        aboutTextView.backgroundColor = VIEW_BACKGROUND_COLOR
        unlockHintsButton.setTitle("Loading Price...", for: UIControlState())
        unlockHintsButton.isEnabled = false
        if TuringSettings.sharedInstance.hintsUnlocked {
            self.unlockHintsButton.setTitle("Bought", for: UIControlState())
            self.restorePurchaseButton?.isEnabled = false
            //self.restorePurchaseButton?.setTitle("", forState: <#UIControlState#>)
        } else {
            TuringSettings.sharedInstance.getHintsPriceString {
                if let price = TuringSettings.sharedInstance.hintsPriceString {
                    self.unlockHintsButton.setTitle("Buy (\(price))", for: UIControlState())
                    self.unlockHintsButton.isEnabled = true
                } else {
                    self.unlockHintsButton.setTitle("No Connection", for: UIControlState())
                }
            }
        }
        self.aboutTextView.attributedText = TuringSettings.sharedInstance.aboutText
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var restorePurchaseButton: UIButton?
    @IBOutlet weak var unlockHintsButton: UIButton!
    override func viewWillAppear(_ animated: Bool) {
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
