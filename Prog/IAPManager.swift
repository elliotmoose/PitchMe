//
//  IAPManager.swift
//  Prog
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 11/9/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import Foundation
import StoreKit

public class IAPManager : NSObject,SKProductsRequestDelegate,
    SKPaymentTransactionObserver
{
    public static let singleton = IAPManager()
    public static var productsLoaded = false
    public static var productIdentifiers : NSSet?
    public static var productsRequest = SKProductsRequest()
    public static var iapProducts = [SKProduct]()
    
    public static var queuedPurchases = [String]()
    override init() {
        super.init()
    }
    
    public func LoadProducts()
    {
        // Put here your IAP Products ID's
        guard let productIdentifiers = IAPManager.productIdentifiers else {NSLog("products not set");return}
        
        IAPManager.productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        IAPManager.productsRequest.delegate = self
        IAPManager.productsRequest.start()
    }
    
    
    public func BuyProductWithID(_ productID : String)
    {
        if !IAPManager.productsLoaded
        {
            IAPManager.queuedPurchases.append(productID)
            LoadProducts()
        }
        else
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
    }
    
    public func ProductIDToProduct(_ productID : String) -> SKProduct?
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
    
    //did load products
    func DidLoadProducts()
    {
        for productID in IAPManager.queuedPurchases
        {
            BuyProductWithID(productID)
        }
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        IAPManager.productsLoaded = true
        
        if (response.products.count > 0) {
            IAPManager.iapProducts = response.products
        }
        else
        {
            NSLog("no products available")
        }
        
        DidLoadProducts()
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
}

