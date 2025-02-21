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
    
    private func formatSection(_ section: BibleText.Section) -> some View {
        Text(section.verses.map { verse in
            "\(verse.verseNumber.superscript) \(verse.text)"
        }.joined(separator: " "))
        .font(appearanceManager.font)
        .padding(.leading, section.isPoetry ? 32 : 0)
        .padding(.bottom, 8)
    }
    
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
                        ForEach(bibleText.chapters, id: \.chapterNumber) { chapter in
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Chapter \(chapter.chapterNumber)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.vertical)
                                    .id(chapter.chapterNumber)
                                
                                ForEach(Array(chapter.sections.enumerated()), id: \.0) { index, section in
                                    formatSection(section)
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

// Add extension for superscript conversion
extension String {
    var superscript: String {
        map { char -> String in
            switch char {
            case "0": return "⁰"
            case "1": return "¹"
            case "2": return "²"
            case "3": return "³"
            case "4": return "⁴"
            case "5": return "⁵"
            case "6": return "⁶"
            case "7": return "⁷"
            case "8": return "⁸"
            case "9": return "⁹"
            default: return String(char)
            }
        }.joined()
    }
}

struct BibleResponse: Codable {
    let text: String
} 
