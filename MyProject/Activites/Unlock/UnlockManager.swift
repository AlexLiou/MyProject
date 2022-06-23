//
//  UnlockManager.swift
//  MyProject
//
//  Created by Alex Liou on 6/22/22.
//

import Combine
import StoreKit

/*
 There are six steps you need to follow when implementing IAPs in your app:

 1. Adding products for folks to buy. This means telling Apple which products
 you want to offer for sale, and how much they cost.

 2. Monitoring the transaction queue. Purchases can happen at any point,
 so we need to make sure we’re watching for updates all the time.

 3. Requesting available products. We ask Apple to provide the list of products to show
 – this is usually the list from step 1, but some IAPs might have been disabled or rejected by Apple.

 4. Handling a transaction. This is where the user has completed a purchase
 – it might be successful, in which case we should provide the content,
 it might have failed, or something else could have happened.

 5. Handling restoring purchases. This allows users to share purchases across
 more than one device, or to get their purchase back after reinstalling the app.

 6. Creating a UI. I know this sounds like the most important thing,
 but really it’s the last step – you need to get all the foundations
 in place and working before creating your UI!

 */

/// <#Description#>
class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }

    enum RequestState {
        // "Loading" means we have started the request but don't have a response yet.
        case loading
        // "Loaded" means we have a successful request from Apple describing what products are available for purchase
        case loaded(SKProduct)
        // "Failed" means something went wrong, either with our request for products
        // or with our attempt to make a purchase
        case failed(Error?)
        // "Purcahsed" means the user has successfully purchased the IAP, or restored a previous purchase.
        case purchased
        // "Deferred" means the current user can't make the purchase themselves, and needs an external action.
        // In practice this means it's a minor asking their parent/guardian for permission.
        case deferred
    }

    @Published var requestState = RequestState.loading
    private let dataController: DataController
    private let request: SKProductsRequest
    private var loadedProducts = [SKProduct]()
    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    /// Handles the four states for RequestState regarding Payments
    /// - Parameters:
    ///   - queue: <#queue description#>
    ///   - transactions: <#transactions description#>
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            for transaction in transactions {
                switch transaction.transactionState {
                // Unlock the purchase, update the request state, and finish the transaction
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                    queue.finishTransaction(transaction)
                // Attempt to go back to the loaded state if we can, or otherwise update
                // our request state to be failed with whatever error occured.
                // Regardless, finish the transaction.
                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }

                    queue.finishTransaction(transaction)
                case .deferred:
                    self.requestState = .deferred
                default:
                    break
                }
            }
        }
    }

    /// Called when our SKProductsRequest finishes succcessfully, because we assigned ourself as its delegate.
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - response: <#response description#>
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Store the returned products for later, if we need them.
            self.loadedProducts = response.products

            // Get our code.MyProject.unlock product.
            guard let unlock = self.loadedProducts.first else {
                self.requestState = .failed(StoreError.missingProduct)
                return
            }

            if response.invalidProductIdentifiers.isEmpty == false {
                print("ALERT: Received invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }

            self.requestState = .loaded(unlock)
        }
    }

    /// Carries out buying a product by putting the SKProduct into an SKPayment and puttting
    /// that into the payment queue. iOS then takes over the work of validating the payment.
    /// - Parameter product: <#product description#>
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    /// Calls the dedicates restore completed transaction function
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    init(dataController: DataController) {
        // Store the data controller we were sent.
        self.dataController = dataController

        // Prepare to look for our unlock product.
        let productIds = Set(["code.MyProject.unlock"])
        request = SKProductsRequest(productIdentifiers: productIds)

        // This is required because we inherit from NSObject.
        super.init()

        // Start watching the payment queue.
        SKPaymentQueue.default().add(self)

        // Avoid starting the product request if the unlock has already happened.
        guard dataController.fullVersionUnlocked == false else { return }

        // Set ourselves up to be notified when the product request completes.
        request.delegate = self

        // Start the request
        request.start()
    }

    // Apple specifically states we should make sure to remove our object
    // from the payment queue observer when our application is being terminated
    // to avoid any problems where iOS thinks our app has been notified about
    // a purchase when really it wasn't.
    deinit {
        SKPaymentQueue.default().remove(self)
    }
}
