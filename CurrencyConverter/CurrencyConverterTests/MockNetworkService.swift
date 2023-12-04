//
//  MockNetworkService.swift
//  CurrencyConverterTests
//
//  Created by Magda Pękacka on 03/12/2023.
//

import Foundation
import RxSwift
import XCTest
import RxTest

@testable import CurrencyConverter

class MockNetworkService: NetworkServiceProtocol {
    private let disposeBag = DisposeBag()
    
    func addParameters(to urlComponents: inout URLComponents, parameters: [String : Any]?) {
    }
    
    func addHeaders(to request: inout URLRequest, headers: [String : String]?) {
    }
    
    
    func requestData(from endpoint: APIEndpoint, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> Single<Data> {
        return Single.create { single in
            let mockData: Data? = self.mockData(for: endpoint)
            
            if let data = mockData {
                single(.success(data))
            } else {
                single(.failure(NetworkError.invalidURL))
            }
            
            return Disposables.create()
        }
    }
    
    private func mockData(for endpoint: APIEndpoint) -> Data? {
        switch endpoint {
        case .rates:
            let ratesJSON = """
                    {   "from": "PLN",
                        "to": "UAH",
                        "rate": 1.2345,
                        "fromAmount": 100.0,
                        "toAmount": 123.45
                    }
                    """.data(using: .utf8)
            return ratesJSON
            
        default:
            return nil
        }
    }
    
    func requestObject<T: Decodable>(from endpoint: APIEndpoint, parameters: [String: Any]? = nil, responseType: T.Type) -> Single<T> {
        return Single.create {[weak self] single in
            self?.requestData(from: endpoint, parameters: parameters)
                .subscribe(onSuccess: { data in
                    do {
                        let decoder = JSONDecoder()
                        let responseObject = try decoder.decode(T.self, from: data)
                        single(.success(responseObject))
                    } catch {
                        single(.failure(error))
                    }
                }, onFailure: { error in
                    single(.failure(error))
                })
                .disposed(by: self?.disposeBag ?? DisposeBag())
            
            return Disposables.create()
        }
    }
}
