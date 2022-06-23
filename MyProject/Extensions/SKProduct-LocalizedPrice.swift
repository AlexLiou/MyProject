//
//  SKProduct-LocalizedPrice.swift
//  MyProject
//
//  Created by Alex Liou on 6/23/22.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
