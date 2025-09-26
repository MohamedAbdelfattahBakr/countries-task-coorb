//
//  CountryDetailView.swift
//  countries-task-coorb
//
//  Created by Mohamed Bakr on 26/09/2025.
//

import SwiftUI

struct CountryDetailView: View {
    let country: Country
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                countryHeaderSection
                
                generalInfoSection
                
                geographySection
                
                economicSection
                
                if let languages = country.languages, !languages.isEmpty {
                    languagesSection
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var countryHeaderSection: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: country.flagURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "flag")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 120)
            .cornerRadius(8)
            
            Text(country.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            if let region = country.region, let subregion = country.subregion {
                Text("\(subregion), \(region)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var generalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("General Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            InfoRowView(title: "Capital", value: country.capitalDisplay)
            InfoRowView(title: "Currency", value: country.currencyDisplay)
            InfoRowView(title: "Alpha-2 Code", value: country.alpha2Code)
            InfoRowView(title: "Alpha-3 Code", value: country.alpha3Code)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var geographySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Geography")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let population = country.population {
                InfoRowView(title: "Population", value: NumberFormatter.localizedString(from: NSNumber(value: population), number: .decimal))
            }
            
            if let area = country.area {
                InfoRowView(title: "Area", value: "\(NumberFormatter.localizedString(from: NSNumber(value: area), number: .decimal)) km²")
            }
            
            if let latlng = country.latlng, latlng.count >= 2 {
                InfoRowView(title: "Coordinates", value: "\(latlng[0])°, \(latlng[1])°")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var economicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Economic Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let currencies = country.currencies {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Currencies:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(currencies, id: \.code) { currency in
                        HStack {
                            Text("•")
                            VStack(alignment: .leading) {
                                if let name = currency.name {
                                    Text(name)
                                        .font(.body)
                                }
                                HStack {
                                    if let code = currency.code {
                                        Text("Code: \(code)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    if let symbol = currency.symbol {
                                        Text("Symbol: \(symbol)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var languagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Languages")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let languages = country.languages {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(languages, id: \.name) { language in
                        HStack {
                            Text("•")
                            VStack(alignment: .leading) {
                                if let name = language.name {
                                    Text(name)
                                        .font(.body)
                                }
                                if let nativeName = language.nativeName, nativeName != language.name {
                                    Text("Native: \(nativeName)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InfoRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationView {
        CountryDetailView(
            country: Country(
                name: "Egypt",
                capital: "Cairo",
                alpha2Code: "EG",
                alpha3Code: "EGY",
                population: 102334403,
                area: 1002450.0,
                region: "Africa",
                subregion: "Northern Africa",
                currencies: [
                    Currency(code: "EGP", name: "Egyptian pound", symbol: "£")
                ],
                languages: [
                    Language(name: "Arabic", nativeName: "العربية")
                ],
                flags: Flag(svg: "https://flagcdn.com/eg.svg", png: "https://flagcdn.com/w320/eg.png"),
                latlng: [27.0, 30.0]
            )
        )
    }
}
