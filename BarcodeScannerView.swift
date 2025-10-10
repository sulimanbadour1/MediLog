//
//  BarcodeScannerView.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI
import AVFoundation
import Combine

struct BarcodeScannerView: View {
    @Binding var isPresented: Bool
    @Binding var scannedCode: String
    @State private var isScanning = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
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
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
                
                if isScanning {
                    CameraPreviewView()
                        .ignoresSafeArea()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("Position the barcode within the frame")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                
                // Scanning overlay
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 250, height: 150)
                        .overlay(
                            VStack {
                                Text("Scan Barcode")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Text("Hold steady")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.caption)
                            }
                        )
                    
                    Spacer()
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            // Manual entry fallback
                            scannedCode = "MANUAL_ENTRY"
                            isPresented = false
                        }) {
                            VStack {
                                Image(systemName: "keyboard")
                                    .font(.system(size: 20))
                                Text("Manual")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                startScanning()
            }
            .onDisappear {
                stopScanning()
            }
        }
        .alert("Scan Result", isPresented: $showingAlert) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func startScanning() {
        isScanning = true
        // In a real implementation, you would start the camera session here
        // For now, we'll simulate scanning after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            simulateScan()
        }
    }
    
    private func stopScanning() {
        isScanning = false
    }
    
    private func simulateScan() {
        // Simulate a barcode scan
        let sampleCodes = ["1234567890123", "9876543210987", "5555555555555"]
        let randomCode = sampleCodes.randomElement() ?? "1234567890123"
        
        // Simulate occasional scan failures
        if Int.random(in: 1...10) <= 2 { // 20% failure rate
            errorMessage = "Failed to scan barcode. Please try again or use manual entry."
            showError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showError = false
            }
            return
        }
        
        scannedCode = randomCode
        alertMessage = "Scanned: \(scannedCode)"
        showingAlert = true
    }
}

struct CameraPreviewView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        // Add a simple animated scanning line
        let scanningLine = UIView()
        scanningLine.backgroundColor = .green
        scanningLine.frame = CGRect(x: 50, y: 100, width: 200, height: 2)
        view.addSubview(scanningLine)
        
        // Animate the scanning line
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            scanningLine.frame.origin.y = 200
        })
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update view if needed
    }
}

// Product lookup service
class ProductLookupService: ObservableObject {
    var objectWillChange: ObservableObjectPublisher
    
    @Published var productInfo: ProductInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        self.objectWillChange = ObservableObjectPublisher()
    }
    
    func lookupProduct(barcode: String) {
        isLoading = true
        errorMessage = nil
        
        // Simulate API call with potential failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Simulate 15% failure rate for product lookup
            if Int.random(in: 1...100) <= 15 {
                self.errorMessage = "Product not found in database. Please enter manually."
                self.productInfo = nil
            } else {
                self.productInfo = ProductInfo(
                    name: "Sample Medication",
                    manufacturer: "Pharma Corp",
                    dosage: "500mg",
                    description: "Prescription medication for treatment"
                )
                self.errorMessage = nil
            }
            self.isLoading = false
        }
    }
}

struct ProductInfo {
    let name: String
    let manufacturer: String
    let dosage: String
    let description: String
}
