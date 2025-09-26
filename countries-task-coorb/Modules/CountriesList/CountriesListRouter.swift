//
//  CountriesListRouter.swift
//  countries-task-coorb
//
//  Created by Mohamed Bakr on 26/09/2025.
//

import Foundation
import SwiftUI

protocol CountriesListRouterProtocol: AnyObject {
    func navigateToCountryDetail(_ country: Country)
}

class CountriesListRouter: CountriesListRouterProtocol {
    weak var navigationController: UINavigationController?
    
    func navigateToCountryDetail(_ country: Country) {
        let countryDetailView = CountryDetailView(country: country)
        let hostingController = UIHostingController(rootView: countryDetailView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

class CountriesListAssembly {
    static func createModule() -> CountriesListView {
        let interactor = CountriesListInteractor()
        let presenter = CountriesListPresenter(interactor: interactor)
        let router = CountriesListRouter()
        
        presenter.router = router
        
        return CountriesListView(presenter: presenter)
    }
}
