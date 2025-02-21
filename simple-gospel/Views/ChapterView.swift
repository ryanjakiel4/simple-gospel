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
    @State private var chapters: [BibleData.Chapter]?
    @State private var isDragging = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    // Break out verse view into separate component
    private struct VerseView: View {
        let verse: BibleData.Verse
        
        var body: some View {
            Text("\(String(verse.number).superscript)\(verse.text)")
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.leading, verse.isPoetry ? 32 : 0)
                .padding(.bottom, 8)
        }
    }
    
    // Break out chapter content into separate component
    private struct ChapterContentView: View {
        let chapter: BibleData.Chapter
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(chapter.number)")
                    .font(.title)
                    .fontWeight(.bold)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .id(chapter.number)
                
                ForEach(chapter.verses) { verse in
                    VerseView(verse: verse)
                }
                
                Divider()
                    .padding(.vertical)
            }
            .padding(.horizontal)
        }
    }
    
    // Break out scroll bar into separate component
    private struct ScrollBarView: View {
        let maxChapters: Int
        @Binding var selectedChapter: Int
        @Binding var isDragging: Bool
        let scrollProxy: ScrollViewProxy
        
        var body: some View {
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
                                let targetChapter = Int(percentage * CGFloat(maxChapters)) + 1
                                selectedChapter = max(1, min(maxChapters, targetChapter))
                                
                                withAnimation(.interactiveSpring()) {
                                    scrollProxy.scrollTo(selectedChapter, anchor: .top)
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
                                Text("\(selectedChapter)")
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
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .trailing) {
                ScrollView {
                    if let chapters = chapters {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(chapters, id: \.number) { chapter in
                                ChapterContentView(chapter: chapter)
                            }
                        }
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
                
                ScrollBarView(
                    maxChapters: book.chapters,
                    selectedChapter: $selectedChapter,
                    isDragging: $isDragging,
                    scrollProxy: proxy
                )
            }
        }
        .navigationTitle(book.name)
        .onAppear {
            loadBook()
        }
    }
    
    private func loadBook() {
        if let bookData = BibleDataManager.shared.loadBook(book.name) {
            chapters = bookData.chapters
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


