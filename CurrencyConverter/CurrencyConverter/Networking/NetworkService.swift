//
//  NetworkService.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 28/11/2023.
//

import Foundation
import RxSwift

enum APIEndpoint: String {
    case rates = "fx-rates"
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed
}

protocol NetworkServiceProtocol {
    func requestData(from endpoint: APIEndpoint, parameters: [String: Any]?, headers: [String: String]?) -> Single<Data>
    func addParameters(to urlComponents: inout URLComponents, parameters: [String: Any]?)
    func addHeaders(to request: inout URLRequest, headers: [String: String]?)
    func requestObject<T: Decodable>(from endpoint: APIEndpoint, parameters: [String: Any]?, responseType: T.Type) -> Single<T>
}

class NetworkService: NetworkServiceProtocol {
    let disposeBag = DisposeBag()
    
    func requestData(from endpoint: APIEndpoint, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> Single<Data> {
        guard var urlComponents = URLComponents(string: Constants.baseURL + "/" + endpoint.rawValue) else {
            return Single.error(NetworkError.invalidURL)
        }
        
        addParameters(to: &urlComponents, parameters: parameters)
        
        guard let url = urlComponents.url else {
            return Single.error(NetworkError.invalidURL)
        }
        
        var request = URLRequest(url: url)
        addHeaders(to: &request, headers: headers)
        
        return URLSession.shared.rx.data(request: request).asSingle()
    }
    
    internal func addParameters(to urlComponents: inout URLComponents, parameters: [String: Any]?) {
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        }
    }
    
    internal func addHeaders(to request: inout URLRequest, headers: [String: String]?) {
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
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
