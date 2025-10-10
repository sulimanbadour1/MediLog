//
//  AddEntryView.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI
import PhotosUI

@available(iOS 16.0, *)
struct AddEntryView: View {
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


var body: some View {
NavigationView {
Form {
Section(header: Text("When & Where")) {
DatePicker("Date", selection: $date)
TextField("Pharmacy (optional)", text: $pharmacyName)
}
Section(header: Text("Symptoms")) {
TextEditor(text: $symptoms).frame(minHeight: 80)
HStack {
TextField("Add tag", text: $tagsText)
Button("Add") {
let t = tagsText.trimmingCharacters(in: .whitespacesAndNewlines)
guard !t.isEmpty else { return }
tags.append(t); tagsText = ""
}
}
FlowTagsView(tags: $tags)
}
Section(header: Text("Products")) {
ForEach(products.indices, id: \.self) { idx in
ProductRowView(row: $products[idx])
}
Button("Add product") { products.append(ProductRow()) }
}
Section(header: Text("Photos")) {
PhotosPicker(selection: $pickerItems, maxSelectionCount: 4, matching: .images) { Label("Add photos", systemImage: "photo") }
.onChange(of: pickerItems) { newItems in
Task {
images.removeAll() // Clear existing images
for it in newItems {
if let data = try? await it.loadTransferable(type: Data.self), let ui = UIImage(data: data) {
images.append(ui)
}
}
}
}
ScrollView(.horizontal) {
HStack { ForEach(images, id: \.self) { Image(uiImage: $0).resizable().frame(width:100,height:80).clipped() } }
}
}
}
.navigationTitle("New Entry")
.toolbar {
ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
}
}
}

private func save() {
// Validate that all products have required fields
for (index, product) in products.enumerated() {
    if product.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        print("Error: Product \(index + 1) must have a name")
        return
    }
    if product.expiryDate < Date() {
        print("Error: Product \(index + 1) has an expired date")
        return
    }
}

Task {
let productDicts = products.map { p in ["name": p.name, "dosage": p.dosage, "quantity": p.quantity, "notes": p.note, "expiryDate": p.expiryDate] as [String : Any] }
do {
print("Saving visit with symptoms: \(symptoms)")
print("Products: \(productDicts)")
print("Images count: \(images.count)")
try await vm.addVisit(date: date, pharmacyName: pharmacyName.isEmpty ? nil : pharmacyName, symptoms: symptoms, tags: tags, products: productDicts, images: images)
print("Visit saved successfully")
dismiss()
} catch {
print("Save error: \(error)")
}
}
}
}


struct ProductRow { 
    var name = ""
    var dosage = ""
    var quantity = 1
    var note = ""
    var expiryDate = Date()
}


struct ProductRowView: View {
@Binding var row: ProductRow
var body: some View {
VStack(alignment: .leading, spacing: 12) {
TextField("Product name", text: $row.name)
HStack { 
    TextField("Dosage", text: $row.dosage)
    Stepper("\(row.quantity)", value: $row.quantity, in: 1...10)
}
DatePicker("Expiry Date", selection: $row.expiryDate, displayedComponents: .date)
    .datePickerStyle(CompactDatePickerStyle())
TextField("Note", text: $row.note)
}
}
}


// Minimal FlowTagsView
struct FlowTagsView: View {
@Binding var tags: [String]
var body: some View {
ScrollView(.horizontal) { HStack { ForEach(tags, id: \.self) { t in Text(t).padding(6).background(Color.gray.opacity(0.2)).cornerRadius(6) } } }
}
}
