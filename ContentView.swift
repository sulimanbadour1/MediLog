//
//  ContentView.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI
internal import CoreData

struct ContentView: View {
    @EnvironmentObject var vm: VisitViewModel
    @State private var showAdd = false
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var showingFilters = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var successMessage = ""
    @State private var showSuccess = false
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }
    
    var filteredVisits: [NSManagedObject] {
        let visits = vm.visits
        
        // Apply search filter
        let searchFiltered = searchText.isEmpty ? visits : visits.filter { visit in
            let symptoms = (visit.value(forKey: "symptomsText") as? String) ?? ""
            let pharmacy = (visit.value(forKey: "pharmacyName") as? String) ?? ""
            return symptoms.localizedCaseInsensitiveContains(searchText) ||
                   pharmacy.localizedCaseInsensitiveContains(searchText)
        }
        
        // Apply date filter
        switch selectedFilter {
        case .all:
            return searchFiltered
        case .today:
            return searchFiltered.filter { visit in
                guard let date = visit.value(forKey: "date") as? Date else { return false }
                return Calendar.current.isDateInToday(date)
            }
        case .thisWeek:
            return searchFiltered.filter { visit in
                guard let date = visit.value(forKey: "date") as? Date else { return false }
                return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
            }
        case .thisMonth:
            return searchFiltered.filter { visit in
                guard let date = visit.value(forKey: "date") as? Date else { return false }
                return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom header with logo
                AppHeaderView()
                    .padding(.bottom, 8)
                // Error messages
                VStack(spacing: 8) {
                    ErrorMessageView(
                        message: errorMessage,
                        isVisible: showError,
                        onDismiss: { 
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showError = false
                            }
                        }
                    )
                    
                    SuccessMessageView(
                        message: successMessage,
                        isVisible: showSuccess,
                        onDismiss: { 
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSuccess = false
                            }
                        }
                    )
                }
                .animation(.easeInOut(duration: 0.3), value: showError)
                .animation(.easeInOut(duration: 0.3), value: showSuccess)
                
                // Header with stats
                HeaderStatsView(visitCount: vm.visits.count)
                    .padding(.bottom, 8)
                
                // Search and filter bar
                SearchAndFilterView(
                    searchText: $searchText,
                    selectedFilter: $selectedFilter,
                    showingFilters: $showingFilters
                )
                .padding(.bottom, 16)
                
                // Visits list
                if filteredVisits.isEmpty {
                    EmptyStateView(searchText: searchText)
                } else {
                    List {
                        ForEach(filteredVisits, id: \.objectID) { visit in
                            NavigationLink(destination: EntryDetailView(visit: visit)) {
                                ModernVisitRowView(visit: visit)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: deleteVisits)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                EnhancedAddEntryView()
            }
            .onAppear { 
                vm.fetchVisits() 
            }
        }
    }
    
    private func deleteVisits(offsets: IndexSet) {
        Task {
            do {
                for index in offsets {
                    let visit = filteredVisits[index]
                    try await vm.deleteVisit(visit)
                }
                await MainActor.run {
                    successMessage = "Visit deleted successfully"
                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showSuccess = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete visit: \(error.localizedDescription)"
                    showError = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        showError = false
                    }
                }
            }
        }
    }
}

struct HeaderStatsView: View {
    let visitCount: Int
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Total Visits")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text("\(visitCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text("This Month")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text("\(visitCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 16)
    }
}

struct SearchAndFilterView: View {
    @Binding var searchText: String
    @Binding var selectedFilter: ContentView.FilterOption
    @Binding var showingFilters: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search visits...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.body)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            Button(action: { showingFilters.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 20))
                    .foregroundColor(selectedFilter == .all ? .secondary : .blue)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedFilter == .all ? Color(.systemGray6) : Color.blue.opacity(0.1))
                    )
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingFilters) {
            FilterView(selectedFilter: $selectedFilter)
        }
    }
}

struct FilterView: View {
    @Binding var selectedFilter: ContentView.FilterOption
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ContentView.FilterOption.allCases, id: \.self) { filter in
                    HStack {
                        Text(filter.rawValue)
                        Spacer()
                        if selectedFilter == filter {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedFilter = filter
                        dismiss()
                    }
                }
            }
            .navigationTitle("Filter Visits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ModernVisitRowView: View {
    let visit: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text((visit.value(forKey: "symptomsText") as? String) ?? "No symptoms")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    if let pharmacyName = visit.value(forKey: "pharmacyName") as? String, !pharmacyName.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "building.2")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text(pharmacyName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let date = visit.value(forKey: "date") as? Date {
                        Text(date, style: .date)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(date, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Tags
            if let tags = visit.value(forKey: "tags") as? [String], !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                        
                        if tags.count > 3 {
                            Text("+\(tags.count - 3)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                )
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            
            // Products count
            if let products = visit.value(forKey: "products") as? Set<NSManagedObject>, !products.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "pills")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("\(products.count) product\(products.count == 1 ? "" : "s")")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct EmptyStateView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "cross.case" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(searchText.isEmpty ? "No visits yet" : "No results found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(searchText.isEmpty ? "Tap + to add your first visit" : "Try adjusting your search")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AppHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            // Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            
            // App name and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text("MediLog")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Health Companion")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 16)
    }
}
