//
//  ChapterView.swift
//  simple-gospel
//
//  Created by Ryan Jakiel on 2/9/25.
//


import SwiftUI

struct ChapterView: View {
    let book: Book
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    var body: some View {
        ScrollView {
            Text("Chapter 1")
                .font(appearanceManager.font.bold())
                .padding()
            
            // Here you would load and display the actual chapter content
            Text("In the beginning God created the heaven and the earth...")
                .font(appearanceManager.font)
                .padding()
        }
        .navigationTitle(book.name)
    }
} 