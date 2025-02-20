//
//  BibleText.swift
//  simple-gospel
//
//  Created by Ryan Jakiel on 2/19/25.
//


import Foundation

struct BibleText {
    struct Verse {
        let verseNumber: String
        let text: String
        let isPoetry: Bool
    }
    
    struct Chapter {
        let chapterNumber: Int
        let verses: [Verse]
        
        var displayText: String {
            verses.map { verse in
                let prefix = verse.isPoetry ? "    " : "" // Indent poetry
                return "\(prefix)[\(verse.verseNumber)] \(verse.text)"
            }.joined(separator: "\n\n")
        }
    }
    
    let bookName: String
    let chapters: [Chapter]
    
    var fullText: String {
        chapters.map { chapter in
            "Chapter \(chapter.chapterNumber)\n\n\(chapter.displayText)"
        }.joined(separator: "\n\n")
    }
    
    static func loadBook(named bookName: String) -> BibleText? {
        // Update the file path to handle special characters in book names
        let sanitizedBookName = bookName.replacingOccurrences(of: " ", with: "+")
        
        guard let fileURL = Bundle.main.url(forResource: sanitizedBookName, 
                                          withExtension: "txt"),
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            print("Failed to load book: \(bookName) at path Resources/NETBibleText/\(sanitizedBookName).txt")  // More detailed debug logging
            return nil
        }
        
        var chapters: [Chapter] = []
        var currentChapter: Int = 0
        var currentVerses: [Verse] = []
        var isInPoetrySection = false
        
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            if line.starts(with: "Chapter ") {
                // Start new chapter
                if currentChapter > 0 && !currentVerses.isEmpty {
                    chapters.append(Chapter(chapterNumber: currentChapter, verses: currentVerses))
                    currentVerses = []
                }
                currentChapter = Int(line.replacingOccurrences(of: "Chapter ", with: "")) ?? 0
            } else if line.contains("[poetry]") {
                isInPoetrySection = true
            } else if line.contains("[bodytext]") {
                isInPoetrySection = false
            } else if line.starts(with: "[") && !line.contains("[bodytext]") && !line.contains("[poetry]") {
                // Parse verse
                let cleanedLine = line.trimmingCharacters(in: .whitespaces)
                if let verseRange = cleanedLine.range(of: #"^\[\d+:\d+\]|\[\d+\]"#, options: .regularExpression) {
                    let verseNumber = String(cleanedLine[verseRange])
                        .replacingOccurrences(of: "[", with: "")
                        .replacingOccurrences(of: "]", with: "")
                    let verseText = cleanedLine[verseRange.upperBound...].trimmingCharacters(in: .whitespaces)
                    currentVerses.append(Verse(
                        verseNumber: verseNumber,
                        text: verseText,
                        isPoetry: isInPoetrySection
                    ))
                }
            }
        }
        
        // Add final chapter
        if !currentVerses.isEmpty {
            chapters.append(Chapter(chapterNumber: currentChapter, verses: currentVerses))
        }
        
        return BibleText(bookName: bookName, chapters: chapters)
    }
    
    func saveToFile() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let bookDirectory = documentDirectory.appendingPathComponent("BibleText")
        
        // Create BibleText directory if it doesn't exist
        if !fileManager.fileExists(atPath: bookDirectory.path) {
            try? fileManager.createDirectory(at: bookDirectory, withIntermediateDirectories: true)
        }
        
        // Save each chapter to a file
        for chapter in chapters {
            let fileName = "\(bookName)_\(chapter.chapterNumber).txt"
            let fileURL = bookDirectory.appendingPathComponent(fileName)
            
            try? chapter.displayText.write(to: fileURL, atomically: true, encoding: .utf8)
        }
        
        // Save full book
        let fullBookURL = bookDirectory.appendingPathComponent("\(bookName).txt")
        try? fullText.write(to: fullBookURL, atomically: true, encoding: .utf8)
    }
    
    static func loadChapter(book: String, chapter: Int) -> String? {
        guard let bundlePath = Bundle.main.path(forResource: "\(book)_\(chapter)", 
                                              ofType: "txt",
                                              inDirectory: "BibleText") else { return nil }
        
        return try? String(contentsOfFile: bundlePath, encoding: .utf8)
    }
} 
