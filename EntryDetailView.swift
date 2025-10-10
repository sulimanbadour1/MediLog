//
//  EntryDetailView.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI
internal import CoreData

struct EntryDetailView: View {
    let visit: NSManagedObject
    @EnvironmentObject var vm: VisitViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Error message
                if showError {
                    ErrorMessageView(
                        message: errorMessage,
                        isVisible: showError,
                        onDismiss: { 
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showError = false
                            }
                        }
                    )
                }
                
                // Header card
                HeaderCardView(visit: visit)
                
                // Symptoms card
                SymptomsCardView(visit: visit)
                
                // Tags card
                if let tags = visit.value(forKey: "tags") as? [String], !tags.isEmpty {
                    TagsCardView(tags: tags)
                }
                
                // Products card
                if let products = visit.value(forKey: "products") as? Set<NSManagedObject>, !products.isEmpty {
                    ProductsCardView(products: Array(products))
                }
                
                // Photos card
                if let photos = visit.value(forKey: "photos") as? Set<NSManagedObject>, !photos.isEmpty {
                    PhotosCardView(photos: Array(photos))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .navigationTitle("Visit Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Delete") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.red)
            }
        }
        .alert("Delete Visit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await vm.deleteVisit(visit)
                        dismiss()
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
        } message: {
            Text("Are you sure you want to delete this visit? This action cannot be undone.")
        }
    }
}

struct HeaderCardView: View {
    let visit: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cross.case")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let date = visit.value(forKey: "date") as? Date {
                        Text(date, style: .date)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(date, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            if let pharmacyName = visit.value(forKey: "pharmacyName") as? String, !pharmacyName.isEmpty {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.green)
                    Text(pharmacyName)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct SymptomsCardView: View {
    let visit: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.text.square")
                    .foregroundColor(.red)
                Text("Symptoms")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            if let symptoms = visit.value(forKey: "symptomsText") as? String, !symptoms.isEmpty {
                Text(symptoms)
                    .font(.body)
                    .lineSpacing(4)
            } else {
                Text("No symptoms recorded")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct TagsCardView: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag")
                    .foregroundColor(.orange)
                Text("Tags")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100))
            ], spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct ProductsCardView: View {
    let products: [NSManagedObject]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pills")
                    .foregroundColor(.green)
                Text("Products (\(products.count))")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 8) {
                ForEach(products, id: \.objectID) { product in
                    EnhancedProductDetailView(product: product)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct EnhancedProductDetailView: View {
    let product: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(product.value(forKey: "name") as? String ?? "Unknown Product")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if let quantity = product.value(forKey: "quantity") as? Int16 {
                    Text("Qty: \(quantity)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
            }
            
            if let dosage = product.value(forKey: "dosage") as? String, !dosage.isEmpty {
                HStack {
                    Image(systemName: "drop")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(dosage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let expiryDate = product.value(forKey: "expiryDate") as? Date {
                HStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .foregroundColor(expiryDate < Date() ? .red : (expiryDate < Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date() ? .orange : .green))
                        .font(.caption)
                    Text("Expires: \(expiryDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(expiryDate < Date() ? .red : (expiryDate < Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date() ? .orange : .secondary))
                }
            }
            
            if let notes = product.value(forKey: "notes") as? String, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct PhotosCardView: View {
    let photos: [NSManagedObject]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "photo")
                    .foregroundColor(.purple)
                Text("Photos (\(photos.count))")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(photos, id: \.objectID) { photo in
                        if let imageData = photo.value(forKey: "imageData") as? Data,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipped()
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
/Users/mpmp/Desktop/Projects/ios/MediLog/MediLog/EnhancedAddEntryView.swift:187:111 Cannot infer contextual base in reference to member 'date'
