//
//  ChapterView.swift
//  simple-gospel
//
//  Created by Ryan Jakiel on 2/9/25.
//


import SwiftUI

struct ChapterView: View {
    let book: Book
    @State private var selectedChapter = 1
    @State private var bibleText: BibleText?
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Chapter picker at top
                    Picker("Chapter", selection: $selectedChapter) {
                        ForEach(1...book.chapters, id: \.self) { chapter in
                            Text("\(chapter)").tag(chapter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    #if compiler(>=5.9)
                    .onChange(of: selectedChapter) { oldValue, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .top)
                        }
                    }
                    #else
                    .onChange(of: selectedChapter) { _ in
                        withAnimation {
                            proxy.scrollTo(selectedChapter, anchor: .top)
                        }
                    }
                    #endif
                    
                    if let bibleText = bibleText {
                        // Display all chapters
                        ForEach(bibleText.chapters, id: \.chapterNumber) { chapter in
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Chapter \(chapter.chapterNumber)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.vertical)
                                    .id(chapter.chapterNumber) // For ScrollViewReader
                                
                                ForEach(chapter.verses, id: \.verseNumber) { verse in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(verse.text)
                                            .font(appearanceManager.font)
                                            .padding(.leading, verse.isPoetry ? 32 : 0)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.vertical)
                        }
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
            }
        }
        .navigationTitle(book.name)
        .onAppear {
            loadBook()
        }
    }
    
    private func loadBook() {
        if let text = BibleText.loadBook(named: book.name) {
            bibleText = text
        } else {
            print("Failed to load book: \(book.name)")
            // You might want to show an error message to the user
        }
    }
}

struct BibleResponse: Codable {
    let text: String
} 
