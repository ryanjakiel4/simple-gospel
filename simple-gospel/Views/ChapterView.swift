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
    @State private var isDragging = false
    @State private var currentChapter = 1
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private func formatSection(_ section: BibleText.Section) -> some View {
        Text(section.verses.map { verse in
            "\(verse.verseNumber.superscript)\(verse.text)"
        }.joined(separator: " "))
        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        .font(.body)
        // Use primary text color that adapts automatically
        .foregroundColor(.primary)
        .padding(.leading, section.isPoetry ? 32 : 0)
        .padding(.bottom, 8)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .trailing) {
                // Main content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let bibleText = bibleText {
                            ForEach(bibleText.chapters, id: \.chapterNumber) { chapter in
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("\(chapter.chapterNumber)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
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
                
                // Scroll bar area
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 44)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isDragging = true
                                    let percentage = min(max(value.location.y / geometry.size.height, 0), 1)
                                    let targetChapter = Int(percentage * CGFloat(book.chapters)) + 1
                                    currentChapter = max(1, min(book.chapters, targetChapter))
                                    
                                    withAnimation(.interactiveSpring()) {
                                        proxy.scrollTo(currentChapter, anchor: .top)
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        isDragging = false
                                    }
                                }
                        )
                        .overlay(
                            Group {
                                if isDragging {
                                    Text("\(currentChapter)")
                                        .font(.system(size: 16, weight: .bold))
                                        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color.accentColor)
                                        .clipShape(Circle())
                                        .transition(.scale.combined(with: .opacity))
                                        .offset(x: -50)
                                }
                            }
                        )
                }
                .frame(width: 44)
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

// Preference key to track content height
struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 
