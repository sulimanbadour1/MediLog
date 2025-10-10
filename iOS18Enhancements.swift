//
//  iOS18Enhancements.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI
internal import CoreData

// MARK: - iOS 18 Enhanced Components

/// Enhanced header with iOS 18 animations and effects
struct iOS18HeaderView: View {
    let visitCount: Int
    @State private var isAnimating = false
    
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
                    .contentTransition(.numericText())
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
                    .contentTransition(.numericText())
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
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

/// Enhanced search bar with iOS 18 features
struct iOS18SearchBar: View {
    @Binding var searchText: String
    @Binding var selectedFilter: FilterOption
    @Binding var showingFilters: Bool
    @FocusState private var isSearchFocused: Bool
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                    .symbolEffect(.bounce, value: isSearchFocused)
                
                TextField("Search visits...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.body)
                    .focused($isSearchFocused)
                    .onSubmit {
                        // Handle search submission
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSearchFocused ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSearchFocused)
            
            Button(action: { showingFilters.toggle() }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 20))
                    .foregroundColor(selectedFilter == .all ? .secondary : .blue)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedFilter == .all ? Color(.systemGray6) : Color.blue.opacity(0.1))
                    )
                    .symbolEffect(.bounce, value: showingFilters)
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingFilters) {
            iOS18FilterView(selectedFilter: $selectedFilter)
        }
    }
}

/// Enhanced filter view with iOS 18 animations
struct iOS18FilterView: View {
    @Binding var selectedFilter: iOS18SearchBar.FilterOption
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(iOS18SearchBar.FilterOption.allCases, id: \.self) { filter in
                    HStack {
                        Text(filter.rawValue)
                            .font(.body)
                        
                        Spacer()
                        
                        if selectedFilter == filter {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .symbolEffect(.bounce, value: selectedFilter == filter)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedFilter = filter
                        }
                        dismiss()
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedFilter == filter ? Color.blue.opacity(0.1) : Color.clear)
                    )
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Filter Visits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

/// Enhanced visit row with iOS 18 features
struct iOS18VisitRowView: View {
    let visit: NSManagedObject
    @State private var isPressed = false
    
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
            
            // Enhanced tags with iOS 18 animations
            if let tags = visit.value(forKey: "tags") as? [String], !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(tags.prefix(3).enumerated()), id: \.offset) { index, tag in
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
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1), value: tags)
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
            
            // Products count with enhanced styling
            if let products = visit.value(forKey: "products") as? Set<NSManagedObject>, !products.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "pills")
                        .foregroundColor(.green)
                        .font(.caption)
                        .symbolEffect(.bounce, value: products.count)
                    
                    Text("\(products.count) product\(products.count == 1 ? "" : "s")")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText())
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isPressed = false
                }
            }
        }
    }
}

/// Enhanced empty state with iOS 18 animations
struct iOS18EmptyStateView: View {
    let searchText: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "cross.case" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .symbolEffect(.bounce, value: isAnimating)
            
            Text(searchText.isEmpty ? "No visits yet" : "No results found")
                .font(.title2)
                .fontWeight(.medium)
                .contentTransition(.opacity)
            
            Text(searchText.isEmpty ? "Tap + to add your first visit" : "Try adjusting your search")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

/// Enhanced app header with iOS 18 effects
struct iOS18AppHeaderView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Enhanced logo with iOS 18 animations
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
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.spring(response: 1.0, dampingFraction: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .symbolEffect(.bounce, value: isAnimating)
            }
            
            // App name and subtitle with enhanced typography
            VStack(alignment: .leading, spacing: 2) {
                Text("MediLog")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .contentTransition(.opacity)
                
                Text("Health Companion")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .contentTransition(.opacity)
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
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                isAnimating = true
            }
        }
    }
}
