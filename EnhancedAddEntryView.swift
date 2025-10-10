//
//  EnhancedAddEntryView.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI
import PhotosUI
internal import CoreData

struct EnhancedAddEntryView: View {
    @EnvironmentObject var vm: VisitViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var pharmacyName = ""
    @State private var symptoms = ""
    @State private var tagsText = ""
    @State private var tags: [String] = []
    @State private var products: [ProductRow] = [ProductRow()]
    @State private var images: [UIImage] = []
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var showingBarcodeScanner = false
    @State private var scannedBarcode = ""
    @State private var showingProductLookup = false
    @State private var productLookupService = ProductLookupService()
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var successMessage = ""
    @State private var showSuccess = false
    @State private var warningMessage = ""
    @State private var showWarning = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
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
                        
                        WarningMessageView(
                            message: warningMessage,
                            isVisible: showWarning,
                            onDismiss: { 
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showWarning = false
                                }
                            }
                        )
                    }
                    .animation(.easeInOut(duration: 0.3), value: showError)
                    .animation(.easeInOut(duration: 0.3), value: showSuccess)
                    .animation(.easeInOut(duration: 0.3), value: showWarning)
                    
                    // Header with date picker
                    HeaderSectionView(date: $date)
                    
                    // Pharmacy section
                    PharmacySectionView(pharmacyName: $pharmacyName)
                    
                    // Symptoms section
                    SymptomsSectionView(symptoms: $symptoms, tagsText: $tagsText, tags: $tags)
                    
                    // Products section with barcode scanning
                    ProductsSectionView(
                        products: $products,
                        showingBarcodeScanner: $showingBarcodeScanner,
                        scannedBarcode: $scannedBarcode,
                        showingProductLookup: $showingProductLookup,
                        productLookupService: productLookupService
                    )
                    
                    // Photos section
                    PhotosSectionView(
                        pickerItems: $pickerItems,
                        images: $images
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("New Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView(
                    isPresented: $showingBarcodeScanner,
                    scannedCode: $scannedBarcode
                )
            }
            .sheet(isPresented: $showingProductLookup) {
                ProductLookupView(
                    barcode: scannedBarcode,
                    productInfo: productLookupService.productInfo,
                    isLoading: productLookupService.isLoading,
                    errorMessage: productLookupService.errorMessage,
                    onAddProduct: { productInfo in
                        addScannedProduct(productInfo)
                    }
                )
            }
            .onChange(of: scannedBarcode) { newBarcode in
                if !newBarcode.isEmpty && newBarcode != "MANUAL_ENTRY" {
                    productLookupService.lookupProduct(barcode: newBarcode)
                    showingProductLookup = true
                }
            }
        }
    }
    
    private func addScannedProduct(_ productInfo: ProductInfo) {
        let newProduct = ProductRow(
            name: productInfo.name,
            dosage: productInfo.dosage,
            quantity: 1,
            note: productInfo.description,
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date() // Default to 1 year from now
        )
        products.append(newProduct)
        scannedBarcode = ""
    }
    
    private func save() {
        // Validate symptoms
        if symptoms.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please describe your symptoms before saving"
            showError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                showError = false
            }
            return
        }
        
        // Validate that all products have required fields
        for (index, product) in products.enumerated() {
            if product.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorMessage = "Product \(index + 1) must have a name"
                showError = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    showError = false
                }
                return
            }
            if product.expiryDate < Date() {
                errorMessage = "Product \(index + 1) has an expired date. Please update the expiry date"
                showError = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    showError = false
                }
                return
            }
        }
        
        // Check for products expiring soon (within 3 months)
        let threeMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        for (index, product) in products.enumerated() {
            if product.expiryDate < threeMonthsFromNow && product.expiryDate > Date() {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let dateString = formatter.string(from: product.expiryDate)
                warningMessage = "Product \(index + 1) expires within 3 months (\(dateString))"
                showWarning = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showWarning = false
                }
            }
        }
        
        Task {
            let productDicts = products.map { p in 
                ["name": p.name, "dosage": p.dosage, "quantity": p.quantity, "notes": p.note, "expiryDate": p.expiryDate] as [String : Any] 
            }
            do {
                try await vm.addVisit(
                    date: date,
                    pharmacyName: pharmacyName.isEmpty ? nil : pharmacyName,
                    symptoms: symptoms,
                    tags: tags,
                    products: productDicts,
                    images: images
                )
                
                await MainActor.run {
                    successMessage = "Visit saved successfully!"
                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save visit: \(error.localizedDescription)"
                    showError = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        showError = false
                    }
                }
            }
        }
    }
}

struct HeaderSectionView: View {
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Visit Details")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .font(.title3)
                DatePicker("Date & Time", selection: $date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .font(.body)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

struct PharmacySectionView: View {
    @Binding var pharmacyName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "building.2")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Pharmacy")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "building.2")
                    .foregroundColor(.blue)
                    .font(.title3)
                TextField("Pharmacy name (optional)", text: $pharmacyName)
                    .font(.body)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

struct SymptomsSectionView: View {
    @Binding var symptoms: String
    @Binding var tagsText: String
    @Binding var tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.text.square")
                    .foregroundColor(.red)
                    .font(.title2)
                Text("Symptoms & Tags")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Describe your symptoms")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $symptoms)
                        .frame(minHeight: 120)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            Group {
                                if symptoms.isEmpty {
                                    VStack {
                                        HStack {
                                            Text("Describe your symptoms...")
                                                .foregroundColor(.secondary)
                                                .font(.body)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding(20)
                                }
                            }
                        )
                }
                
                // Tags input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add tags")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "tag")
                            .foregroundColor(.blue)
                            .font(.title3)
                        TextField("Add tag", text: $tagsText)
                            .font(.body)
                            .onSubmit {
                                addTag()
                            }
                        
                        Button("Add") {
                            addTag()
                        }
                        .disabled(tagsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .font(.body)
                        .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                }
                
                // Tags display
                if !tags.isEmpty {
                    FlowTagsView(tags: $tags)
                }
            }
        }
    }
    
    private func addTag() {
        let tag = tagsText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        tags.append(tag)
        tagsText = ""
    }
}

struct ProductsSectionView: View {
    @Binding var products: [ProductRow]
    @Binding var showingBarcodeScanner: Bool
    @Binding var scannedBarcode: String
    @Binding var showingProductLookup: Bool
    let productLookupService: ProductLookupService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack {
                    Image(systemName: "pills")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Products")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button(action: { showingBarcodeScanner = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "barcode.viewfinder")
                        Text("Scan")
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                    .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 16) {
                ForEach(products.indices, id: \.self) { index in
                    EnhancedProductRowView(row: $products[index])
                }
                
                Button(action: { products.append(ProductRow()) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                        Text("Add Product")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
            }
        }
    }
}

struct EnhancedProductRowView: View {
    @Binding var row: ProductRow
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "pills")
                    .foregroundColor(.green)
                    .font(.title3)
                Text("Product")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Product Name")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    TextField("Enter product name", text: $row.name)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                }
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Dosage")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        TextField("Dosage", text: $row.dosage)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Quantity")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Stepper("\(row.quantity)", value: $row.quantity, in: 1...10)
                            .labelsHidden()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Expiry Date")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    DatePicker("Expiry Date", selection: $row.expiryDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    TextField("Additional notes", text: $row.note)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

struct PhotosSectionView: View {
    @Binding var pickerItems: [PhotosPickerItem]
    @Binding var images: [UIImage]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "photo")
                    .foregroundColor(.purple)
                    .font(.title2)
                Text("Photos")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 16) {
                PhotosPicker(
                    selection: $pickerItems,
                    maxSelectionCount: 4,
                    matching: .images
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.title3)
                        Text("Add Photos")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .onChange(of: pickerItems) { newItems in
                    Task {
                        images.removeAll()
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                images.append(uiImage)
                            }
                        }
                    }
                }
                
                if !images.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Photos (\(images.count)/4)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(images, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                        .cornerRadius(16)
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
            }
        }
    }
}

struct ProductLookupView: View {
    let barcode: String
    let productInfo: ProductInfo?
    let isLoading: Bool
    let errorMessage: String?
    let onAddProduct: (ProductInfo) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Looking up product...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Lookup Failed")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Enter Manually") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                } else if let productInfo = productInfo {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Product Found")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(productInfo.name)
                                .font(.headline)
                            
                            Text(productInfo.manufacturer)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(productInfo.dosage)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            
                            Text(productInfo.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        Button("Add to Visit") {
                            onAddProduct(productInfo)
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Product Not Found")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("No product information found for barcode: \(barcode)")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Product Lookup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
