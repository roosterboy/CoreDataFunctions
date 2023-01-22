//
//  CoreDataFunctionsApp.swift
//  CoreDataFunctions
//
//  Created by Patrick Wynne on 1/21/23.
//

import SwiftUI

@main
struct CoreDataFunctionsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
