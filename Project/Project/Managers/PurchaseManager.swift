import StoreKit

protocol PurchaseManagerDelegate: AnyObject {
  func purchaseManager(_ manager: PurchaseManager, didReceiveProducts products: [SKProduct])
  func purchaseManager(_ manager: PurchaseManager, didCompletePurchaseFor product: SKProduct)
  func purchaseManagerDidRestorePurchases(_ manager: PurchaseManager)
  func purchaseManager(_ manager: PurchaseManager, didFailWithError error: Error)
}

final class PurchaseManager: NSObject {
  static let shared = PurchaseManager()

  var isProVersion: Bool {
    get {
      return UserDefaults.standard.bool(forKey: "60645040-1e6a-4c74-b850-09c9b2a63a19")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "60645040-1e6a-4c74-b850-09c9b2a63a19")
      UserDefaults.standard.synchronize()
    }
  }

  private var productIdentifiers: Set<String> = []
  private var productsRequest: SKProductsRequest?
  private var products: [SKProduct] = []
  private let paymentQueue = SKPaymentQueue.default()
  weak var delegate: PurchaseManagerDelegate?
  
  private override init() {
    super.init()
    paymentQueue.add(self)
  }
  
  deinit {
    productIdentifiers = []
    productsRequest = nil
    products = []
    delegate = nil
    paymentQueue.remove(self)
  }
  
  func purchaseProduct(_ product: SKProduct) {
    let payment = SKPayment(product: product)
    paymentQueue.add(payment)
  }
  
  func startProductRequest(with identifiers: Set<String>) {
    productsRequest?.cancel()
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest?.delegate = self
    productsRequest?.start()
  }

  func purchase(_ product: SKProduct) {
    let payment = SKPayment(product: product)
    paymentQueue.add(payment)
  }
  
  func restorePurchases() {
    paymentQueue.restoreCompletedTransactions()
  }
}

extension PurchaseManager: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    products = response.products
    delegate?.purchaseManager(self, didReceiveProducts: products)
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    delegate?.purchaseManager(self, didFailWithError: error)
  }
}

extension PurchaseManager: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .purchased:
        let productIdentifier = transaction.payment.productIdentifier
        if let product = products.first(where: { $0.productIdentifier == productIdentifier }) {
          delegate?.purchaseManager(self, didCompletePurchaseFor: product)
          paymentQueue.finishTransaction(transaction)
        }
      case .restored:
        let productIdentifier = transaction.original?.payment.productIdentifier
        if let product = products.first(where: { $0.productIdentifier == productIdentifier }) {
          delegate?.purchaseManager(self, didCompletePurchaseFor: product)
          paymentQueue.finishTransaction(transaction)
        }
      case .failed:
        if let error = transaction.error as NSError?, error.code != SKError.paymentCancelled.rawValue {
          delegate?.purchaseManager(self, didFailWithError: error)
        }
        paymentQueue.finishTransaction(transaction)
      default:
        break
      }
    }
  }
  
  func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    delegate?.purchaseManagerDidRestorePurchases(self)
  }
  
  func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
    delegate?.purchaseManager(self, didFailWithError: error)
  }
}







//import StoreKit
//
//protocol PurchaseManagerDelegate: AnyObject {
//  func purchaseManager(_ manager: PurchaseManager, didReceiveProducts products: [SKProduct])
//  func purchaseManager(_ manager: PurchaseManager, didCompletePurchaseFor product: SKProduct)
//  func purchaseManagerDidRestorePurchases(_ manager: PurchaseManager)
//  func purchaseManager(_ manager: PurchaseManager, didFailWithError error: Error)
//}
//
//class PurchaseManager: NSObject {
//
//  static let shared = PurchaseManager()
//
//  weak var delegate: PurchaseManagerDelegate?
//
//  var products: [SKProduct] = []
//
//  var isProVersion: Bool {
//    get {
//      return UserDefaults.standard.bool(forKey: "60645040-1e6a-4c74-b850-09c9b2a63a19")
//    }
//    set {
//      UserDefaults.standard.set(newValue, forKey: "60645040-1e6a-4c74-b850-09c9b2a63a19")
//      UserDefaults.standard.synchronize()
//    }
//  }
//
//  private var paymentQueue = SKPaymentQueue.default()
//
//  private override init() {
//    super.init()
//    paymentQueue.add(self)
//  }
//
//  deinit {
//    paymentQueue.remove(self)
//  }
//
//  func startProductRequest(with identifiers: Set<String>) {
//    let request = SKProductsRequest(productIdentifiers: identifiers)
//    request.delegate = self
//    request.start()
//  }
//
//  func purchase(_ product: SKProduct) {
//    let payment = SKPayment(product: product)
//    paymentQueue.add(payment)
//  }
//
//  func restorePurchases() {
//    paymentQueue.restoreCompletedTransactions()
//  }
//}
//
//extension PurchaseManager: SKProductsRequestDelegate {
//  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//    products = response.products
//    delegate?.purchaseManager(self, didReceiveProducts: products)
//  }
//
//  func request(_ request: SKRequest, didFailWithError error: Error) {
//    delegate?.purchaseManager(self, didFailWithError: error)
//  }
//}
//
//extension PurchaseManager: SKPaymentTransactionObserver {
//  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//    for transaction in transactions {
//      switch transaction.transactionState {
//      case .purchased:
//        let productIdentifier = transaction.payment.productIdentifier
//        if let product = products.first(where: { $0.productIdentifier == productIdentifier }) {
//          delegate?.purchaseManager(self, didCompletePurchaseFor: product)
//          paymentQueue.finishTransaction(transaction)
//        }
//      case .restored:
//        let productIdentifier = transaction.original?.payment.productIdentifier
//        if let product = products.first(where: { $0.productIdentifier == productIdentifier }) {
//          delegate?.purchaseManager(self, didCompletePurchaseFor: product)
//          paymentQueue.finishTransaction(transaction)
//        }
//      case .failed:
//        if let error = transaction.error as NSError?, error.code != SKError.paymentCancelled.rawValue {
//          delegate?.purchaseManager(self, didFailWithError: error)
//        }
//        paymentQueue.finishTransaction(transaction)
//      default:
//        break
//      }
//    }
//  }
//
//  func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//    delegate?.purchaseManagerDidRestorePurchases(self)
//  }
//
//  func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
//    delegate?.purchaseManager(self, didFailWithError: error)
//  }
//}

























/*
import StoreKit

protocol PurchaseManagerDelegate: AnyObject {
  func purchaseManager(_ purchaseManager: PurchaseManager, didReceiveProducts products: [SKProduct])
  func purchaseManager(_ purchaseManager: PurchaseManager, didCompletePurchaseFor product: SKProduct)
  func purchaseManager(_ purchaseManager: PurchaseManager, didFailWithError error: Error?)
  func purchaseManagerDidRestorePurchases(_ purchaseManager: PurchaseManager)
}

class PurchaseManager: NSObject {
  private let productIdentifiers: Set<String>
  private var productsRequest: SKProductsRequest?
  private var products: [SKProduct] = []
  private let paymentQueue = SKPaymentQueue.default()
  weak var delegate: PurchaseManagerDelegate?
  
  init(productIdentifiers: Set<String>) {
    self.productIdentifiers = productIdentifiers
    super.init()
    paymentQueue.add(self)
  }
  
  func requestProducts() {
    productsRequest?.cancel()
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest?.delegate = self
    productsRequest?.start()
  }
  
  func purchaseProduct(_ product: SKProduct) {
    let payment = SKPayment(product: product)
    paymentQueue.add(payment)
  }
  
  func restorePurchases() {
    paymentQueue.restoreCompletedTransactions()
  }
}

extension PurchaseManager: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    products = response.products
    delegate?.purchaseManager(self, didReceiveProducts: products)
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    delegate?.purchaseManager(self, didFailWithError: error)
  }
}

extension PurchaseManager: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .purchased:
        // The purchase was successful, so deliver the content to the user and update the purchase status
        let productIdentifier = transaction.payment.productIdentifier
        if let product = products.first(where: { $0.productIdentifier == productIdentifier }) {
          delegate?.purchaseManager(self, didCompletePurchaseFor: product)
          paymentQueue.finishTransaction(transaction)
        }
      case .restored:
        // The purchase was restored, so deliver the content to the user and update the purchase status
        let productIdentifier = transaction.original?.payment.productIdentifier
        if let product = products.first(where: { $0.productIdentifier == productIdentifier }) {
          delegate?.purchaseManager(self, didCompletePurchaseFor: product)
          paymentQueue.finishTransaction(transaction)
        }
      case .failed:
        // The purchase failed, so inform the user and log the error
        if let error = transaction.error as NSError?, error.code != SKError.paymentCancelled.rawValue {
          delegate?.purchaseManager(self, didFailWithError: error)
        }
        paymentQueue.finishTransaction(transaction)
      default:
        break
      }
    }
  }
  
  func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    delegate?.purchaseManagerDidRestorePurchases(self)
  }
  
  func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
    delegate?.purchaseManager(self, didFailWithError: error)
  }
}
*/
