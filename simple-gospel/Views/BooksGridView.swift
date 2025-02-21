//
//  BooksGridView.swift
//  simple-gospel
//
//  Created by Ryan Jakiel on 2/9/25.
//


import SwiftUI

struct BooksGridView: View {
    @EnvironmentObject private var settings: SettingsManager
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: settings.columnsCount)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Book.allBooks) { book in
                    NavigationLink(destination: ChapterView(book: book)) {
                        BookCell(book: book)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Bible")
    }
}

struct BookCell: View {
    let book: Book
    
    var body: some View {
        VStack {
            Text(book.name)
                .font(.headline)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))  // Uses system background color that adapts to dark mode
        .cornerRadius(10)
    }
} 
