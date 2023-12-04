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
    
    private let internetAvailabilitySubject = BehaviorSubject<Bool?>(value: nil)
    
    var isInternetAvailable: Observable<Bool?> {
        return internetAvailabilitySubject
    }
    
    private init() {
        do {
            try reachability?.startNotifier()
            setupReachabilityObservers()
        } catch {
            print("Error starting reachability notifier: \(error)")
        }
    }
    
    private func setupReachabilityObservers() {
        reachability?.whenReachable = { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.internetAvailabilitySubject.onNext(true)
            }
        }
        
        reachability?.whenUnreachable = { [weak self] _ in
            self?.internetAvailabilitySubject.onNext(false)
        }
    }
    
    func stopMonitoring() {
        reachability?.stopNotifier()
    }
    
    deinit {
        stopMonitoring()
    }
}
