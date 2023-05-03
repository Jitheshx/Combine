//
//  ViewController.swift
//  CombineWithSwift
//
//  Created by Jithesh Xavier on 04/04/23.
//

import UIKit

class ViewController: UIViewController {

    var viewModel: DashboardViewModel? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = DashboardViewModel()
        viewModel?.request()
        viewModel?.requestViaCombine()
        viewModel?.requestViaCombineAndFuture()
    }
}

