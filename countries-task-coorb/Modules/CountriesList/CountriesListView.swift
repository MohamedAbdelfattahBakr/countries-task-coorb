//
//  CountriesListView.swift
//  countries-task-coorb
//
//  Created by Mohamed Bakr on 26/09/2025.
//

import SwiftUI
import Combine

struct CountriesListView: View {
    @ObservedObject private var presenter: CountriesListPresenter
    
    init(presenter: CountriesListPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainContent
                
                if presenter.isSearchActive {
                    searchOverlay
                }
            }
            .navigationTitle("Countries")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Country.self) { country in
                CountryDetailView(country: country)
            }
            .onAppear {
                presenter.viewDidLoad()
            }
            .alert("Error", isPresented: .constant(presenter.errorMessage != nil)) {
                Button("OK") {
                    presenter.errorMessage = nil
                }
            } message: {
                Text(presenter.errorMessage ?? "")
            }
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                searchBarSection
                
                if presenter.userLocationCountry != nil {
                    currentLocationSection
                }
                
                if !presenter.selectedCountries.isEmpty {
                    selectedCountriesSection
                }
                
                if presenter.userLocationCountry == nil && presenter.selectedCountries.isEmpty {
                    if presenter.showLocationDeniedMessage {
                        locationDeniedView
                    } else {
                        emptyStateView
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                Text("Search countries...")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .onTapGesture {
                presenter.activateSearch()
            }
        }
    }
    
    private var currentLocationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                
                Text("Your Location")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if let country = presenter.userLocationCountry {
                LocationCountryCardView(country: country)
            }
        }
    }
    
    private var selectedCountriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Selected Countries")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("(\(presenter.selectedCountries.count)/5)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            LazyVStack(spacing: 8) {
                ForEach(presenter.selectedCountries) { country in
                    SelectedCountryCardView(
                        country: country,
                        onRemove: {
                            presenter.removeCountry(country)
                        }
                    )
                }
            }
        }
    }
    
    private var searchOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    presenter.closeSearch()
                }
            
            VStack(spacing: 0) {
                searchHeader
                searchContent
            }
            .background(Color(.systemBackground))
            .cornerRadius(16, corners: [.topLeft, .topRight])
            .ignoresSafeArea(.container, edges: .bottom)
            .transition(.asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            ))
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: presenter.isSearchActive)
    }
    
    private var searchHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Search Countries")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Done") {
                    presenter.closeSearch()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Type country name...", text: $presenter.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: presenter.searchText) { newValue in
                        presenter.searchTextChanged(newValue)
                    }
                
                if !presenter.searchText.isEmpty {
                    Button(action: {
                        presenter.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            Divider()
        }
    }
    
    private var searchContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if presenter.isSearching {
                    HStack {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.blue)
                        Text("Searching...")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.vertical, 50)
                    .transition(.scale.combined(with: .opacity))
                } else if presenter.searchResults.isEmpty && !presenter.searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No countries found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try searching with a different term")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 50)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    ForEach(Array(presenter.searchResults.enumerated()), id: \.element.id) { index, country in
                        SearchResultRowView(
                            country: country,
                            isSelected: presenter.selectedCountries.contains(where: { $0.alpha2Code == country.alpha2Code }) || presenter.userLocationCountry?.alpha2Code == country.alpha2Code,
                            onSelect: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    presenter.selectCountry(country)
                                }
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        
                        if index < presenter.searchResults.count - 1 {
                            Divider()
                                .padding(.leading, 70)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .animation(.easeInOut(duration: 0.3), value: presenter.searchResults)
            .animation(.easeInOut(duration: 0.3), value: presenter.isSearching)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Welcome to Countries")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Getting your location to show your current country...")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            ProgressView()
                .scaleEffect(0.8)
        }
        .padding(.vertical, 60)
    }
    
    private var locationDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Location Access Needed")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("We need access to your location to show your current country. Please enable location access in Settings.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 60)
    }
}

struct LocationCountryCardView: View {
    let country: Country
    
    var body: some View {
        NavigationLink(value: country) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: country.flagURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "flag")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        )
                }
                .frame(width: 50, height: 35)
                .cornerRadius(6)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("Capital: \(country.capitalDisplay)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SelectedCountryCardView: View {
    let country: Country
    let onRemove: () -> Void
    
    var body: some View {
        NavigationLink(value: country) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: country.flagURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "flag")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        )
                }
                .frame(width: 50, height: 35)
                .cornerRadius(6)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("Capital: \(country.capitalDisplay)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernCountryCardView: View {
    let country: Country
    let canRemove: Bool
    let onRemove: () -> Void
    
    var body: some View {
        NavigationLink(value: country) {
            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: country.flagURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "flag")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                            )
                    }
                    .frame(height: 60)
                    .clipped()
                    .cornerRadius(8)
                    
                    if canRemove {
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                                .font(.system(size: 20))
                        }
                        .offset(x: 8, y: -8)
                    }
                }
                
                VStack(spacing: 4) {
                    Text(country.name)
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .frame(height: 34)
                    
                    Text(country.capitalDisplay)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchResultRowView: View {
    let country: Country
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: country.flagURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "flag")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 50, height: 35)
            .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(country.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Capital: \(country.capitalDisplay)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Text("Currency: \(country.currencyDisplay)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onSelect) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
                    .foregroundColor(isSelected ? .green : .blue)
                    .font(.system(size: 24))
            }
            .disabled(isSelected)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
