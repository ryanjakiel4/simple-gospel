//
//  BooksGridView.swift
//  simple-gospel
//
//  Created by Ryan Jakiel on 2/9/25.
//


import SwiftUI

struct BooksGridView: View {
    @EnvironmentObject private var appearanceManager: AppearanceManager
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]
    
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
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    var body: some View {
        VStack {
            Text(book.name)
                .font(appearanceManager.font)
                .multilineTextAlignment(.center)
                .foregroundColor(appearanceManager.colorScheme == .dark ? .white : .black)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(appearanceManager.colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
} 