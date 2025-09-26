//
//  CountriesListPresenter.swift
//  countries-task-coorb
//
//  Created by Mohamed Bakr on 26/09/2025.
//

import Foundation
import Combine

protocol CountriesListPresenterProtocol {
    func viewDidLoad()
    func searchTextChanged(_ text: String)
    func selectCountry(_ country: Country)
    func removeCountry(_ country: Country)
    func showCountryDetail(_ country: Country)
}

class CountriesListPresenter: CountriesListPresenterProtocol, ObservableObject {
    weak var router: CountriesListRouterProtocol?
    private let interactor: CountriesListInteractorProtocol
    
    @Published var searchText = ""
    @Published var searchResults: [Country] = []
    @Published var selectedCountries: [Country] = []
    @Published var userLocationCountry: Country?
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var showLocationDeniedMessage = false
    @Published var isSearchActive = false
    
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()
    
    init(interactor: CountriesListInteractorProtocol) {
        self.interactor = interactor
        setupSearchDebouncing()
        bindInteractor()
    }
    
    func viewDidLoad() {
        loadUserLocationCountry()
    }
    
    func searchTextChanged(_ text: String) {
        searchText = text
        searchSubject.send(text)
    }
    
    func selectCountry(_ country: Country) {
        guard selectedCountries.count < 5 else {
            errorMessage = "Maximum 5 countries allowed"
            return
        }
        
        guard !selectedCountries.contains(where: { $0.alpha2Code == country.alpha2Code }),
              userLocationCountry?.alpha2Code != country.alpha2Code else {
            errorMessage = "Country already selected"
            return
        }
        
        interactor.addCountryToSelected(country)
    }
    
    func closeSearch() {
        searchText = ""
        searchResults = []
        isSearchActive = false
    }
    
    func activateSearch() {
        isSearchActive = true
    }
    
    func removeCountry(_ country: Country) {
        guard userLocationCountry?.alpha2Code != country.alpha2Code else {
            return
        }
        interactor.removeCountryFromSelected(country)
    }
    
    func showCountryDetail(_ country: Country) {
        router?.navigateToCountryDetail(country)
    }
    
    private func setupSearchDebouncing() {
        searchSubject
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.performSearch(searchText)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ text: String) {
        guard !text.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        interactor.searchCountries(query: text)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isSearching = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] countries in
                    self?.searchResults = countries
                }
            )
            .store(in: &cancellables)
    }
    
    private func bindInteractor() {
        interactor.selectedCountriesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countries in
                self?.selectedCountries = countries
            }
            .store(in: &cancellables)
    }
    
    private func loadUserLocationCountry() {
        interactor.getCurrentUserCountry()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        DispatchQueue.main.async {
                            self?.showLocationDeniedMessage = true
                        }
                    }
                },
                receiveValue: { [weak self] country in
                    DispatchQueue.main.async {
                        if let country = country {
                            self?.userLocationCountry = country
                        } else {
                            self?.showLocationDeniedMessage = true
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
}
