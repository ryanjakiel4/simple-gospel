//
//  BibleApp.swift
//  simple-gospel
//
//  Created by Ryan Jakiel on 2/9/25.
//


import SwiftUI

@main
struct BibleApp: App {
    @StateObject private var appearanceManager = AppearanceManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                BooksGridView()
            }
            .preferredColorScheme(appearanceManager.colorScheme)
            .environmentObject(appearanceManager)
        }
    }
} 
