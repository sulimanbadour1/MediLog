//
//  EditEntryView.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI
import PhotosUI
internal import CoreData

struct EditEntryView: View {
    let visit: NSManagedObject
    @EnvironmentObject var vm: VisitViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var date: Date
    @State private var pharmacyName: String
    @State private var symptoms: String
    @State private var tagsText = ""
    @State private var tags: [String]
    @State private var products: [ProductRow]
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
    
    init(visit: NSManagedObject) {
        self.visit = visit
        
        // Initialize state from existing visit data
        self._date = State(initialValue: (visit.value(forKey: "date") as? Date) ?? Date())
        self._pharmacyName = State(initialValue: (visit.value(forKey: "pharmacyName") as? String) ?? "")
        self._symptoms = State(initialValue: (visit.value(forKey: "symptomsText") as? String) ?? "")
        self._tags = State(initialValue: (visit.value(forKey: "tags") as? [String]) ?? [])
        
        // Initialize products from existing data
        var initialProducts: [ProductRow] = []
        if let products = visit.value(forKey: "products") as? Set<NSManagedObject> {
            for product in products {
                let productRow = ProductRow(
                    name: product.value(forKey: "name") as? String ?? "",
                    dosage: product.value(forKey: "dosage") as? String ?? "",
                    quantity: product.value(forKey: "quantity") as? Int ?? 1,
                    note: product.value(forKey: "notes") as? String ?? "",
                    expiryDate: product.value(forKey: "expiryDate") as? Date ?? Date()
                )
                initialProducts.append(productRow)
            }
        }
        if initialProducts.isEmpty {
            initialProducts = [ProductRow()]
        }
        self._products = State(initialValue: initialProducts)
        
        // Initialize images from existing data
        var initialImages: [UIImage] = []
        if let photos = visit.value(forKey: "photos") as? Set<NSManagedObject> {
            for photo in photos {
                if let imageData = photo.value(forKey: "imageData") as? Data,
                   let uiImage = UIImage(data: imageData) {
                    initialImages.append(uiImage)
                }
            }
        }
        self._images = State(initialValue: initialImages)
    }
    
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
            .navigationTitle("Edit Visit")
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
            expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
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
                try await vm.updateVisit(
                    visit: visit,
                    date: date,
                    pharmacyName: pharmacyName.isEmpty ? nil : pharmacyName,
                    symptoms: symptoms,
                    tags: tags,
                    products: productDicts,
                    images: images
                )
                
                await MainActor.run {
                    successMessage = "Visit updated successfully!"
                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to update visit: \(error.localizedDescription)"
                    showError = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        showError = false
                    }
                }
            }
        }
    }
}
