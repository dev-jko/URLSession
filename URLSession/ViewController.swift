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

    private let service = AppService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        service.todo(id: 1) { [weak self] result in
//            guard let `self` = self else { return }
//
//            switch result {
//            case .success(let todo):
//                self.label.text = todo.title
//            case .failure(let error):
//                self.label.text = error.localizedDescription
//            }
//        }
        
        service.createTodo(todo: Todo(id: 2, title: "jkoTodo", completed: false)) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let todo):
                print(todo)
                self.label.text = todo.title
            case .failure(let error):
                print(error)
                self.label.text = error.localizedDescription
            }
        }
    }

    

}

struct Todo: Codable {
    let id: Int
    let title: String
    let completed: Bool
}

enum JustError: Error {
    case just
    case couldNotDecode
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .just:
            return "just"
        case .couldNotDecode:
            return "couldNotDecode"
        case .invalidData:
            return "invalidData"
        }
    }
}

class Network {
    private let session: URLSession = URLSession.shared
    
    func dataTask(request: URLRequest, completion: @escaping (Result<(Data?, HTTPURLResponse), Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    return completion(.failure(error))
                }
                
                guard let response = response as? HTTPURLResponse else {
                    return completion(.failure(JustError.just))
                }
                
                switch response.statusCode {
                case 200..<300:
                    completion(.success((data, response)))
                default:
                    completion(.failure(JustError.just))
                }
            }
        }.resume()
    }
}

class AppService {
    private let network: Network = Network()
    private let baseURL: String = "https://jsonplaceholder.typicode.com/"
    
    func todo(id: Int, completion: ((Result<Todo, Error>) -> Void)? = nil) {
        let urlString: String = baseURL + "todos/\(id)"
        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        network.dataTask(request: request) { result in
            let decoder = JSONDecoder()
            switch result {
            case .success(let (data, _)):
                
                guard let data = data else {
                    completion?(.failure(JustError.invalidData))
                    return
                }
                
                guard let todo: Todo = try? decoder.decode(Todo.self, from: data) else {
                    completion?(.failure(JustError.couldNotDecode))
                    return
                }
                
                completion?(.success(todo))
                
            case .failure(let err):
                completion?(.failure(err))
            }
        }
    }
    
    func createTodo(todo: Todo, completion: ((Result<Todo, Error>) -> Void)? = nil) {
        let urlString = baseURL + "todos"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(todo) else { return }
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        network.dataTask(request: request) { result in
            let decoder = JSONDecoder()
            switch result {
            case .success(let (data, _)):
                guard let data = data else {
                    completion?(.failure(JustError.invalidData))
                    return
                }
                
                guard let todo: Todo = try? decoder.decode(Todo.self, from: data) else {
                    completion?(.failure(JustError.couldNotDecode))
                    return
                }
                
                completion?(.success(todo))
                
            case .failure(let err):
                completion?(.failure(err))
            }
        }
    }
}
