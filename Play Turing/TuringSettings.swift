//
//  TuringSettings.swift
//  Play Turing
//
//  Created by Lee Danilek on 6/13/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit
import StoreKit

let HINTS_ID = "playturinghints"
let PRODUCT_IDS = Set<String>(arrayLiteral: HINTS_ID)
let PRODUCT_REQUEST = SKProductsRequest(productIdentifiers: PRODUCT_IDS)

public class TuringSettings: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    public class var sharedInstance: TuringSettings {
        struct Singleton {
            static let instance = TuringSettings()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self as SKPaymentTransactionObserver)
    }
    
    public var hintsUnlocked = NSUserDefaults.standardUserDefaults().boolForKey(HINTS_ID) {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(hintsUnlocked, forKey: HINTS_ID)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    public var hintsPriceString: String?
    
    private var doneHandler: Void->Void = {}
    // in the done handler, check hintsPriceString
    func getHintsPriceString(done: Void->Void) -> Void {
        doneHandler = done
        PRODUCT_REQUEST.delegate = self
        PRODUCT_REQUEST.start()
    }
    // call this only after getHintsPriceString's done handler has returned, and only if the price has been updated
    // in the done handler, check hintsUnlocked
    func downloadHints(done: Void->Void) -> Void {
        if let p = product {
            doneHandler = done
            SKPaymentQueue.defaultQueue().addPayment(SKPayment(product: p))
        }
    }
    
    //
    func restoreHints(done: Void->Void) -> Void {
        doneHandler = done
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    private var product: SKProduct!
    public func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        product = response.products.last as! SKProduct
        var priceFormatter = NSNumberFormatter()
        priceFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
        priceFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        priceFormatter.locale = product.priceLocale
        hintsPriceString = priceFormatter.stringFromNumber(product.price)
        doneHandler()
    }
    
    public func request(request: SKRequest!, didFailWithError error: NSError!) {
        doneHandler()
    }
    
    public func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for t in transactions {
            let transaction = t as! SKPaymentTransaction
            println("Transaction in state \(transaction.transactionState.rawValue)")
            switch transaction.transactionState {
            case SKPaymentTransactionState.Failed:
                doneHandler()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break
            case SKPaymentTransactionState.Restored:
                hintsUnlocked = true
                doneHandler()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case SKPaymentTransactionState.Purchased:
                hintsUnlocked = true
                doneHandler()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
        
    }
    
    
    var aboutText: NSAttributedString {
        var mutableText = NSMutableAttributedString()
        let fontName = "Palatino-Roman"
        var centeredParagaphStyle = NSMutableParagraphStyle()
        centeredParagaphStyle.alignment = NSTextAlignment.Center
        var leftParagraphStyle = NSMutableParagraphStyle()
        leftParagraphStyle.firstLineHeadIndent = 20
        leftParagraphStyle.alignment = .Left
        let headerAttributes: [NSObject : AnyObject] = [NSFontAttributeName as String: UIFont(name: fontName, size: 20) as! AnyObject, NSParagraphStyleAttributeName as String: centeredParagaphStyle as AnyObject]
        let bodyAttributes: [NSObject : AnyObject] = [NSFontAttributeName: UIFont(name: fontName, size: 15)!, NSParagraphStyleAttributeName: leftParagraphStyle]
        
        mutableText.appendAttributedString(NSAttributedString(string: "About Turing Machines", attributes: headerAttributes))
        mutableText.appendAttributedString(NSAttributedString(string: "\n\nA turing machine is the ultimate hypothetical computer, but it operates under simple principles. It has some states (q0, q1, q2, ...) and it reads from a tape with some characters (-, 0, 1, ...).\n\nAt each step, the machine follows rules. Based on the current state and the current character, the machine knows what rule to use. The rule tells it to write a new character, go to a new state, and move left or right on the tape.\n\nUsing certain rules, a turing machine could do anything a supercomputer can do, but programming that machine would be a hassle. Some of the small procedures, like adding two numbers, are simple enough to program. Play Turing presents these simple programming challenges as levels, so the player can learn how Turing Machines work and develop algorithmic thinking.", attributes: bodyAttributes))
        
        return mutableText.copy() as! NSAttributedString
    }
    
}
