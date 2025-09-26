//
//  NetworkService.swift
//  countries-task-coorb
//
//  Created by Mohamed Bakr on 25/09/2025.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func searchCountries(query: String) -> AnyPublisher<[Country], Error>
    func getCountryByName(_ name: String) -> AnyPublisher<[Country], Error>
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://restcountries.com/v2"
    private let session = URLSession.shared
    
    func searchCountries(query: String) -> AnyPublisher<[Country], Error> {
        guard !query.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let urlString = "\(baseURL)/name/\(query)"
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Country].self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<[Country], Error> in
                if let urlError = error as? URLError, urlError.code == .cannotFindHost {
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getCountryByName(_ name: String) -> AnyPublisher<[Country], Error> {
        let urlString = "\(baseURL)/name/\(name)"
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Country].self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<[Country], Error> in
                return Just([])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        }
    }
}
