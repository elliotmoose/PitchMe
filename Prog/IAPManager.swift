//
//  IAPManager.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 11/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import Foundation
import StoreKit

public protocol IAPManagerDelegate : class {
    func DidCompleteTransaction(success : Bool,identifiers : [String],error : String)
}

public class IAPManager : NSObject,SKProductsRequestDelegate,
    SKPaymentTransactionObserver
{
    public static let singleton = IAPManager()
    public static var productsLoaded = false
    public static var productIdentifiers : NSSet?
    public static var productsRequest = SKProductsRequest()
    public static var iapProducts = [SKProduct]()
    public static var queuedPurchases = [String]()
    public weak var delegate : IAPManagerDelegate?
    
    override init() {
        super.init()
    }
    
    public func QueueProductPurchaseWithID(_ productID : String)
    {
        //step 1: add to queue
        IAPManager.queuedPurchases.append(productID)
        
        //step 2: load products
        LoadProducts()
    }
    
    public func ProductsLoadedForPurchase()
    {
        //step 3: for objects in queue -> purhcase
        for productID in IAPManager.queuedPurchases
        {
            if let product = ProductIDToProduct(productID)
            {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            }
            else
            {
                NSLog("cant find product: \(productID)")
            }
        }
        
        //step 4: reset queue
        IAPManager.queuedPurchases.removeAll()
    }
    
    public func LoadProducts()
    {
        // Put here your IAP Products ID's
        guard let productIdentifiers = IAPManager.productIdentifiers else {NSLog("products not set");return}
        
        IAPManager.productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        IAPManager.productsRequest.delegate = self
        IAPManager.productsRequest.start()
    }
    
        
    private func ProductIDToProduct(_ productID : String) -> SKProduct?
    {
        for product in IAPManager.iapProducts
        {
            if product.productIdentifier == productID
            {
                return product
            }
        }
        
        return nil
    }

    //LOADING OF PRODUCTS
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        IAPManager.productsLoaded = true
        if (response.products.count > 0) {
            IAPManager.iapProducts = response.products
            ProductsLoadedForPurchase()
        }
        else
        {
            //reset
            IAPManager.queuedPurchases.removeAll()
            NSLog("no products available")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        delegate?.DidCompleteTransaction(success: false, identifiers: [], error: error.localizedDescription)
    }
    
    //post payment
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        var identifiers = [String]()
        for transaction in queue.transactions
        {
            identifiers.append(transaction.payment.productIdentifier)
        }
        delegate?.DidCompleteTransaction(success: true,identifiers : identifiers,error: "")
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        var identifiers = [String]()
        for transaction in queue.transactions
        {
            identifiers.append(transaction.payment.productIdentifier)
        }
        
        delegate?.DidCompleteTransaction(success: false,identifiers : identifiers,error: error.localizedDescription)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
}

