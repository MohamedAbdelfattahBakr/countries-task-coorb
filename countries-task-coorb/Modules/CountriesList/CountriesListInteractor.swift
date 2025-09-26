//
//  CountriesListInteractor.swift
//  countries-task-coorb
//
//  Created by Mohamed Bakr on 26/09/2025.
//

import Foundation
import Combine

protocol CountriesListInteractorProtocol {
    func searchCountries(query: String) -> AnyPublisher<[Country], Error>
    func getCurrentUserCountry() -> AnyPublisher<Country?, Error>
    func addCountryToSelected(_ country: Country)
    func removeCountryFromSelected(_ country: Country)
    var selectedCountries: [Country] { get }
    var selectedCountriesPublisher: Published<[Country]>.Publisher { get }
}

class CountriesListInteractor: CountriesListInteractorProtocol, ObservableObject {
    private let networkService: NetworkServiceProtocol
    private let locationService: LocationServiceProtocol
    
    @Published var selectedCountries: [Country] = []
    var selectedCountriesPublisher: Published<[Country]>.Publisher { $selectedCountries }
    
    private let maxSelectedCountries = 5
    
    init(networkService: NetworkServiceProtocol = NetworkService(),
         locationService: LocationServiceProtocol = LocationService()) {
        self.networkService = networkService
        self.locationService = locationService
    }
    
    func searchCountries(query: String) -> AnyPublisher<[Country], Error> {
        return networkService.searchCountries(query: query)
    }
    
    func getCurrentUserCountry() -> AnyPublisher<Country?, Error> {
        return locationService.requestLocation()
            .flatMap { [weak self] countryName -> AnyPublisher<Country?, Error> in
                guard let self = self, let countryName = countryName else {
                    return Just(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.networkService.getCountryByName(countryName)
                    .map { countries in
                        return countries.first
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func addCountryToSelected(_ country: Country) {
        guard selectedCountries.count < maxSelectedCountries else { return }
        guard !selectedCountries.contains(where: { $0.alpha2Code == country.alpha2Code }) else { return }
        
        selectedCountries.append(country)
    }
    
    func removeCountryFromSelected(_ country: Country) {
        selectedCountries.removeAll { $0.alpha2Code == country.alpha2Code }
    }
}
