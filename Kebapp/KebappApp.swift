//
//  KebappApp.swift
//  Kebapp
//
//  Created by Илья Варфоломеев on 07.06.2024.
//

import SwiftUI

@main
struct KebappApp: App {
    private let persistence = PersistenceController.shared
    @StateObject private var historyViewModel = HistoryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(historyViewModel)
                .tint(Theme.accent)
        }
    }
}
