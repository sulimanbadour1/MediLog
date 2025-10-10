//
//  VisitViewModel.swift.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import Foundation
internal import CoreData
import UIKit
import Combine


@MainActor
class VisitViewModel: ObservableObject {
@Published var visits: [NSManagedObject] = []
private var context: NSManagedObjectContext? = PersistenceController.shared.container.viewContext


func fetchVisits() {
guard let ctx = context else { 
    print("Error: No context for fetchVisits")
    return 
}
let req = NSFetchRequest<NSManagedObject>(entityName: "PharmacyVisit")
let sort = NSSortDescriptor(key: "date", ascending: false)
req.sortDescriptors = [sort]
do {
visits = try ctx.fetch(req)
print("Fetched \(visits.count) visits")
} catch {
print("fetch error:", error)
visits = []
// In a real app, you might want to show an error to the user here
}
}


func addVisit(date: Date, pharmacyName: String?, symptoms: String, tags: [String], products: [[String: Any]], images: [UIImage]) async throws {
guard let ctx = context else { 
    throw AppError.dataError("Database connection failed. Please restart the app.")
}

print("Creating new visit...")
let ent = NSEntityDescription.entity(forEntityName: "PharmacyVisit", in: ctx)!
let visit = NSManagedObject(entity: ent, insertInto: ctx)
visit.setValue(UUID(), forKey: "id")
visit.setValue(date, forKey: "date")
visit.setValue(pharmacyName, forKey: "pharmacyName")
visit.setValue(symptoms, forKey: "symptomsText")
visit.setValue(tags, forKey: "tags")
visit.setValue(Date(), forKey: "createdAt")
print("Visit basic info set")


// Products (one-to-many)
if let prodEntity = NSEntityDescription.entity(forEntityName: "Product", in: ctx) {
var prodSet = Set<NSManagedObject>()
for p in products {
let pe = NSManagedObject(entity: prodEntity, insertInto: ctx)
pe.setValue(UUID(), forKey: "id")
pe.setValue(p["name"] as? String ?? "", forKey: "name")
pe.setValue(p["dosage"] as? String ?? "", forKey: "dosage")
pe.setValue(Int16(p["quantity"] as? Int ?? 1), forKey: "quantity")
pe.setValue(p["notes"] as? String ?? "", forKey: "notes")
pe.setValue(p["expiryDate"] as? Date ?? Date(), forKey: "expiryDate")
prodSet.insert(pe)
}
visit.setValue(prodSet as NSSet, forKey: "products")
}


// Photos
if let photoEntity = NSEntityDescription.entity(forEntityName: "Photo", in: ctx) {
var photoSet = Set<NSManagedObject>()
for img in images {
if let data = img.jpegData(compressionQuality: 0.7) {
let ph = NSManagedObject(entity: photoEntity, insertInto: ctx)
ph.setValue(UUID(), forKey: "id")
ph.setValue(data, forKey: "imageData")
photoSet.insert(ph)
}
}
visit.setValue(photoSet as NSSet, forKey: "photos")
}

print("Saving to Core Data...")
do {
    try ctx.save()
    print("Successfully saved to Core Data")
    fetchVisits()
    print("Fetched visits, count: \(visits.count)")
} catch {
    print("Core Data save error: \(error)")
    throw AppError.saveError("Failed to save visit to database. Please try again.")
}
}


func deleteVisit(_ visit: NSManagedObject) async throws {
guard let ctx = context else { 
    throw AppError.dataError("Database connection failed. Please restart the app.")
}
ctx.delete(visit)
do {
    try ctx.save()
    fetchVisits()
} catch {
    throw AppError.saveError("Failed to delete visit. Please try again.")
}
}
}
