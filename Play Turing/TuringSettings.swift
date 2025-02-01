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

open class TuringSettings: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    open class var sharedInstance: TuringSettings {
        struct Singleton {
            static let instance = TuringSettings()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
    }
    
    open var hintsUnlocked = UserDefaults.standard.bool(forKey: HINTS_ID) {
        didSet {
            UserDefaults.standard.set(hintsUnlocked, forKey: HINTS_ID)
            UserDefaults.standard.synchronize()
        }
    }
    
    open var hintsPriceString: String?
    
    fileprivate var doneHandler: (Void)->Void = {}
    // in the done handler, check hintsPriceString
    func getHintsPriceString(_ done: @escaping (Void)->Void) -> Void {
        doneHandler = done
        PRODUCT_REQUEST.delegate = self
        PRODUCT_REQUEST.start()
    }
    // call this only after getHintsPriceString's done handler has returned, and only if the price has been updated
    // in the done handler, check hintsUnlocked
    func downloadHints(_ done: @escaping (Void)->Void) -> Void {
        if let p = product {
            doneHandler = done
            SKPaymentQueue.default().add(SKPayment(product: p))
        }
    }
    
    //
    func restoreHints(_ done: @escaping (Void)->Void) -> Void {
        doneHandler = done
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    fileprivate var product: SKProduct!
    open func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        product = response.products.last!
        let priceFormatter = NumberFormatter()
        priceFormatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
        priceFormatter.numberStyle = NumberFormatter.Style.currency
        priceFormatter.locale = product.priceLocale
        hintsPriceString = priceFormatter.string(from: product.price)
        doneHandler()
    }
    
    open func request(_ request: SKRequest, didFailWithError error: Error) {
        doneHandler()
    }
    
    open func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for t in transactions {
            let transaction = t 
            print("Transaction in state \(transaction.transactionState.rawValue)")
            switch transaction.transactionState {
            case SKPaymentTransactionState.failed:
                doneHandler()
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case SKPaymentTransactionState.restored:
                hintsUnlocked = true
                doneHandler()
                SKPaymentQueue.default().finishTransaction(transaction)
            case SKPaymentTransactionState.purchased:
                hintsUnlocked = true
                doneHandler()
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
        
    }
    
    
    var aboutText: NSAttributedString {
        let mutableText = NSMutableAttributedString()
        let fontName = "Palatino-Roman"
        let centeredParagaphStyle = NSMutableParagraphStyle()
        centeredParagaphStyle.alignment = NSTextAlignment.center
        let leftParagraphStyle = NSMutableParagraphStyle()
        leftParagraphStyle.firstLineHeadIndent = 20
        leftParagraphStyle.alignment = .left
        let headerAttributes: [String : AnyObject] = [NSFontAttributeName: UIFont(name: fontName, size: 20)!, NSParagraphStyleAttributeName: centeredParagaphStyle as AnyObject]
        let bodyAttributes: [String : AnyObject] = [NSFontAttributeName: UIFont(name: fontName, size: 15)!, NSParagraphStyleAttributeName: leftParagraphStyle]
        
        mutableText.append(NSAttributedString(string: "About Turing Machines", attributes: headerAttributes))
        mutableText.append(NSAttributedString(string: "\n\nA turing machine is the ultimate hypothetical computer, but it operates under simple principles. It has some states (q0, q1, q2, ...) and it reads from a tape with some characters (-, 0, 1, ...).\n\nAt each step, the machine follows rules. Based on the current state and the current character, the machine knows what rule to use. The rule tells it to write a new character, go to a new state, and move left or right on the tape.\n\nUsing certain rules, a turing machine could do anything a supercomputer can do, but programming that machine would be a hassle. Some of the small procedures, like adding two numbers, are simple enough to program. Play Turing presents these simple programming challenges as levels, so the player can learn how Turing Machines work and develop algorithmic thinking.", attributes: bodyAttributes))
        
        return mutableText.copy() as! NSAttributedString
    }
    
}
