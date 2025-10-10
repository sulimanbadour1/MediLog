//
//  PersistenceController.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

internal import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Create the model programmatically
        let model = NSManagedObjectModel()
        
        // Create PharmacyVisit entity
        let pharmacyVisitEntity = NSEntityDescription()
        pharmacyVisitEntity.name = "PharmacyVisit"
        pharmacyVisitEntity.managedObjectClassName = "PharmacyVisit"
        
        // Add attributes to PharmacyVisit
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = true
        
        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = true
        
        let pharmacyNameAttribute = NSAttributeDescription()
        pharmacyNameAttribute.name = "pharmacyName"
        pharmacyNameAttribute.attributeType = .stringAttributeType
        pharmacyNameAttribute.isOptional = true
        
        let symptomsAttribute = NSAttributeDescription()
        symptomsAttribute.name = "symptomsText"
        symptomsAttribute.attributeType = .stringAttributeType
        symptomsAttribute.isOptional = true
        
        let tagsAttribute = NSAttributeDescription()
        tagsAttribute.name = "tags"
        tagsAttribute.attributeType = .transformableAttributeType
        tagsAttribute.isOptional = true
        tagsAttribute.valueTransformerName = "NSSecureUnarchiveFromDataTransformer"
        
        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = true
        
        pharmacyVisitEntity.properties = [idAttribute, dateAttribute, pharmacyNameAttribute, symptomsAttribute, tagsAttribute, createdAtAttribute]
        
        // Create Product entity
        let productEntity = NSEntityDescription()
        productEntity.name = "Product"
        productEntity.managedObjectClassName = "Product"
        
        let productIdAttribute = NSAttributeDescription()
        productIdAttribute.name = "id"
        productIdAttribute.attributeType = .UUIDAttributeType
        productIdAttribute.isOptional = true
        
        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = true
        
        let dosageAttribute = NSAttributeDescription()
        dosageAttribute.name = "dosage"
        dosageAttribute.attributeType = .stringAttributeType
        dosageAttribute.isOptional = true
        
        let quantityAttribute = NSAttributeDescription()
        quantityAttribute.name = "quantity"
        quantityAttribute.attributeType = .integer16AttributeType
        quantityAttribute.isOptional = true
        
        let notesAttribute = NSAttributeDescription()
        notesAttribute.name = "notes"
        notesAttribute.attributeType = .stringAttributeType
        notesAttribute.isOptional = true
        
        let expiryDateAttribute = NSAttributeDescription()
        expiryDateAttribute.name = "expiryDate"
        expiryDateAttribute.attributeType = .dateAttributeType
        expiryDateAttribute.isOptional = false  // Required field
        
        productEntity.properties = [productIdAttribute, nameAttribute, dosageAttribute, quantityAttribute, notesAttribute, expiryDateAttribute]
        
        // Create Photo entity
        let photoEntity = NSEntityDescription()
        photoEntity.name = "Photo"
        photoEntity.managedObjectClassName = "Photo"
        
        let photoIdAttribute = NSAttributeDescription()
        photoIdAttribute.name = "id"
        photoIdAttribute.attributeType = .UUIDAttributeType
        photoIdAttribute.isOptional = true
        
        let imageDataAttribute = NSAttributeDescription()
        imageDataAttribute.name = "imageData"
        imageDataAttribute.attributeType = .binaryDataAttributeType
        imageDataAttribute.isOptional = true
        
        photoEntity.properties = [photoIdAttribute, imageDataAttribute]
        
        // Create relationships
        let productsRelationship = NSRelationshipDescription()
        productsRelationship.name = "products"
        productsRelationship.destinationEntity = productEntity
        productsRelationship.maxCount = 0
        productsRelationship.deleteRule = .cascadeDeleteRule
        
        let photosRelationship = NSRelationshipDescription()
        photosRelationship.name = "photos"
        photosRelationship.destinationEntity = photoEntity
        photosRelationship.maxCount = 0
        photosRelationship.deleteRule = .cascadeDeleteRule
        
        let visitRelationship = NSRelationshipDescription()
        visitRelationship.name = "visit"
        visitRelationship.destinationEntity = pharmacyVisitEntity
        visitRelationship.maxCount = 1
        visitRelationship.deleteRule = .nullifyDeleteRule
        
        // Set inverse relationships
        productsRelationship.inverseRelationship = visitRelationship
        photosRelationship.inverseRelationship = visitRelationship
        visitRelationship.inverseRelationship = productsRelationship
        
        pharmacyVisitEntity.properties.append(contentsOf: [productsRelationship, photosRelationship])
        productEntity.properties.append(visitRelationship)
        photoEntity.properties.append(visitRelationship)
        
        // Add entities to model
        model.entities = [pharmacyVisitEntity, productEntity, photoEntity]
        
        // Create container with the programmatic model
        container = NSPersistentContainer(name: "MediLogModel", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data error: \(error)")
                fatalError("Unresolved error: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
