//
//  PetCareApp.swift
//  PetCare
//
//  Created by Christian on 19/11/26.
//

import SwiftUI
import CoreData

@main
struct PetCareApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
