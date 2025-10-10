//
//  MediLogApp.swift
//  MediLog
//
//  Created by Sul on 05.10.2025.
//

import SwiftUI
internal import CoreData


@main
struct MediLogApp: App {
let persistenceController = PersistenceController.shared
@StateObject var visitVM = VisitViewModel()


var body: some Scene {
WindowGroup {
SplashScreenView()
.environment(\.managedObjectContext, persistenceController.container.viewContext)
.environmentObject(visitVM)
}
}
}
