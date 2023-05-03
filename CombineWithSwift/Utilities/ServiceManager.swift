//
//  ServiceManager.swift
//  CombineWithSwift
//
//  Created by Jithesh Xavier on 04/04/23.
//

import UIKit
import Combine

struct RandomFact: Codable {
    var _id: String?
    var user: String?
    var text: String?
}

enum APIError: Error {
    case internalError
    case serverError
    case parseError
}

protocol ServiceManagerProtocol {
    func makeRequest<T: Codable>(responseType: T.Type, completion: @escaping ((Result<T, APIError>) -> Void))
    
    //MARK: - COMBINE
    func makeRequestViaCombine() -> AnyPublisher<Welcome, APIError>
    
    //MARK: - COMBINE WITH FUTURE
    func makeRequestWithFuture() -> Future<Welcome, APIError>
}

class ServiceManager: ServiceManagerProtocol {
        
    var publishers = [AnyCancellable]()

    private let baseURL = "https://cat-fact.herokuapp.com"
    
    private enum Endpoint: String {
        case random = "/facts/random"
    }
    
    private enum Method: String {
        case GET
    }
    
    //MARK: - MAKE REQUEST
    
    private func request(for endPoint: Endpoint, method: Method) -> URLRequest {
        
        var path = "\(baseURL)\(endPoint.rawValue)"
        path = "https://reqres.in/api/unknown"
        guard let url = URL(string: path) else {
            preconditionFailure("BAD URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "\(method)"
        request.allHTTPHeaderFields = ["Content-Type" : "application/json"]
        return request
    }

    //MARK: - WITH COMPLETION
    
    func makeRequest<T: Codable>(responseType: T.Type, completion: @escaping ((Result<T, APIError>) -> Void)) {
        request(endPoint: .random, method: .GET, responseType: T.self, completion: completion)
    }
    
    private func request<T: Codable>(endPoint: Endpoint, method: Method, responseType: T.Type, completion: @escaping ((Result<T, APIError>) -> Void)) {
                
        let urlRequest = request(for: endPoint, method: method)
        call(with: urlRequest, responseType: T.self, completion: completion)
    }
    
    private func call<T: Codable>(with request: URLRequest, responseType: T.Type, completion: @escaping ((Result<T, APIError>) -> Void)) {
       
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                completion(.failure(.serverError))
                return
            }
            
            do {
                guard let data = data else {
                    completion(.failure(.serverError))
                    return
                }
                
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(Result.success(object))
            } catch {
                completion(.failure(.parseError))
            }
        }
        dataTask.resume()
    }
    
    //MARK: - WITH COMBINE
    
    func makeRequestViaCombine() -> AnyPublisher<Welcome, APIError> {
        return callViaCombine(.random, responseType: Welcome.self, method: .GET)
    }

    private func callViaCombine<T: Codable>(_ endPoint: Endpoint, responseType: T.Type, method: Method) -> AnyPublisher<T, APIError> {
        
        let urlRequest = request(for: endPoint, method: method)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError{ _ in APIError.serverError }
            .map{ $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError {_ in APIError.parseError }
            .eraseToAnyPublisher()
    }

    //MARK: - WITH COMBINE AND FUTURE
    
    func makeRequestWithFuture() -> Future<Welcome, APIError> {
        return callWithFuture(.random, responseType: Welcome.self, method: .GET)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure(let error):
//                    print(error)
//                case .finished:
//                    print("Finished")
//                }
//            }, receiveValue: { responseData in
//                print("Response Data:\(responseData)")
//            })
//            .store(in: &self.publishers)
    }
    
    private func callWithFuture<T: Codable>(_ endPoint: Endpoint, responseType: T.Type, method: Method) -> Future<T, APIError> {
        
        return Future<T, APIError> { [weak self] promise in
            guard let self = self else {
                return promise(.failure(.serverError))
            }
            
            let urlRequest = self.request(for: endPoint, method: method)
            
            URLSession.shared.dataTaskPublisher(for: urlRequest)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode else {
                        throw APIError.serverError
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    if case .failure(_) = completion {
                        promise(.failure(.internalError))
                    }
                }, receiveValue: { promise(.success($0)) })
                .store(in: &self.publishers)
        }
    }
}

