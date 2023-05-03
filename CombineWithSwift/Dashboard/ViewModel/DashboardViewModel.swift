//
//  DashboardViewModel.swift
//  CombineWithSwift
//
//  Created by Jithesh Xavier on 04/04/23.
//

import UIKit
import Combine

class DashboardViewModel {
    
    let serviceManger: ServiceManagerProtocol! = ServiceManager()
    var publishers = [AnyCancellable]()
    
    func request() {
        serviceManger.makeRequest(responseType: RandomFact.self) {
            switch $0 {
            case .failure(let error) :
                print("Error:\(error.localizedDescription)")
            case .success(let result):
                print("Result:\(result)")
            }
        }
    }
    
    func requestViaCombine() {
        serviceManger.makeRequestViaCombine().sink { _ in
            print("finished")
        } receiveValue: { value in
            print("Value:\(value)")
        }.store(in: &publishers)
    }
    
    func requestViaCombineAndFuture() {
        serviceManger.makeRequestWithFuture().sink { completion in
            switch completion {
            case .failure(let error):
                print(error)
            case .finished:
                print("Finished")
            }
        } receiveValue: { responseData in
            print("Response Data:\(responseData)")
        }.store(in: &publishers)
    }
}
