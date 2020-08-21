//
//  ViewController.swift
//  URLSession
//
//  Created by Jaedoo Ko on 2020/08/06.
//  Copyright © 2020 jko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    
    private let network = Network()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url: String = "https://jsonplaceholder.typicode.com/todos/1"
        
        network.network(url: url) { [weak self] data, response, error in
            guard let `self` = self else { return }
            
            if let error = error {
                self.label.text = error.localizedDescription
                return
            }
            
            guard let data = data else { return }
            let string = String(data: data, encoding: .utf8)
            self.label.text = string
        }
    }

    

}

class Network {
    
    func network(url: String, completion: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                completion?(data, response, error)
            }
        }.resume()
    }
}
