//
//  Country.swift
//  countries-task-coorb
//
//  Created by Mohamed Bakr on 26/09/2025.
//

import Foundation

struct Country: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let capital: String?
    let alpha2Code: String
    let alpha3Code: String
    let population: Int?
    let area: Double?
    let region: String?
    let subregion: String?
    let currencies: [Currency]?
    let languages: [Language]?
    let flags: Flag?
    let latlng: [Double]?
    
    enum CodingKeys: String, CodingKey {
        case name, capital, alpha2Code, alpha3Code
        case population, area, region, subregion
        case currencies, languages, flags, latlng
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.alpha2Code == rhs.alpha2Code
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(alpha2Code)
    }
}

struct Currency: Codable {
    let code: String?
    let name: String?
    let symbol: String?
}

struct Language: Codable {
    let name: String?
    let nativeName: String?
}

struct Flag: Codable {
    let svg: String?
    let png: String?
}

extension Country {
    var primaryCurrency: Currency? {
        return currencies?.first
    }
    
    var primaryLanguage: Language? {
        return languages?.first
    }
    
    var flagURL: String? {
        return flags?.png ?? flags?.svg
    }
    
    var capitalDisplay: String {
        return capital ?? "N/A"
    }
    
    var currencyDisplay: String {
        guard let currency = primaryCurrency else { return "N/A" }
        if let name = currency.name, let symbol = currency.symbol {
            return "\(name) (\(symbol))"
        } else if let name = currency.name {
            return name
        } else if let code = currency.code {
            return code
        }
        return "N/A"
    }
}
