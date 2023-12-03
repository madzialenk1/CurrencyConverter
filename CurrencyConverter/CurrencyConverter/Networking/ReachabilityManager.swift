//
//  ReachabilityManager.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 02/12/2023.
//

import Reachability
import RxSwift

class ReachabilityManager {
    static let shared = ReachabilityManager()
    
    private let reachability = try? Reachability()
    
    var isInternetAvailable: Observable<Bool> {
        return Observable.create { observer in
            do {
                try self.reachability?.startNotifier()
                self.reachability?.whenReachable = { _ in
                    observer.onNext(true)
                }
                self.reachability?.whenUnreachable = { _ in
                    observer.onNext(false)
                }
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create {
                self.reachability?.stopNotifier()
            }
        }
        .startWith(self.reachability?.connection != .unavailable)
        .distinctUntilChanged()
    }
    
    private init() {}
}



