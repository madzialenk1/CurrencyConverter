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

class NetworkService {
    func requestData(from endpoint: APIEndpoint, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> Observable<Data> {
        guard var urlComponents = URLComponents(string: Constants.baseURL + "/" + endpoint.rawValue) else {
            return Observable.error(NetworkError.invalidURL)
        }
        
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        }
        
        guard let url = urlComponents.url else {
            return Observable.error(NetworkError.invalidURL)
        }
        
        var request = URLRequest(url: url)
        
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return Observable.create { observer in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkError.requestFailed)
                    return
                }
                
                observer.onNext(data)
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
