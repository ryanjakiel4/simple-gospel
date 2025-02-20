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
        
        print("Loading book: \(bookName)")
        print("Sanitized name: \(sanitizedBookName)")
        
        guard let fileURL = Bundle.main.url(forResource: sanitizedBookName, 
                                          withExtension: "txt") else {
            print("❌ Failed to find file URL")
            return nil
        }
        
        print("📄 Found file at: \(fileURL)")
        
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            print("❌ Failed to read file content")
            return nil
        }
        
        print("📝 Successfully read file content")
        
        var chapters: [Chapter] = []
        var currentChapter: Int = 0
        var currentVerses: [Verse] = []
        var isInPoetrySection = false
        var pendingVerseNumber: String? = nil
        
        let lines = content.components(separatedBy: .newlines)
        print("Found \(lines.count) lines in file")
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty || trimmedLine == "\(bookName) Text" {
                continue
            }
            
            if trimmedLine.starts(with: "Chapter ") {
                print("📚 Found Chapter marker at line \(index): \(trimmedLine)")
                if currentChapter > 0 && !currentVerses.isEmpty {
                    chapters.append(Chapter(chapterNumber: currentChapter, verses: currentVerses))
                    print("✓ Added Chapter \(currentChapter) with \(currentVerses.count) verses")
                    currentVerses = []
                }
                currentChapter = Int(trimmedLine.replacingOccurrences(of: "Chapter ", with: "")) ?? 0
                pendingVerseNumber = nil
            } else if trimmedLine == "[poetry]" {
                isInPoetrySection = true
            } else if trimmedLine == "[bodytext]" {
                isInPoetrySection = false
            } else if trimmedLine.starts(with: "[") {
                // Check if this line contains both verse number and text
                if let verseRange = trimmedLine.range(of: #"^\[\d+(?::\d+)?\]"#, options: .regularExpression) {
                    var verseNumber = String(trimmedLine[verseRange])
                        .replacingOccurrences(of: "[", with: "")
                        .replacingOccurrences(of: "]", with: "")
                    
                    // Convert "chapter:1" format to just "1"
                    if verseNumber.contains(":") {
                        verseNumber = String(verseNumber.split(separator: ":")[1])
                    }
                    
                    let verseStartIndex = trimmedLine.index(verseRange.upperBound, offsetBy: 0)
                    let verseText = String(trimmedLine[verseStartIndex...]).trimmingCharacters(in: .whitespaces)
                    
                    if verseText.isEmpty {
                        // Store the verse number for the next line
                        pendingVerseNumber = verseNumber
                    } else {
                        // Add verse with text on same line
                        currentVerses.append(Verse(
                            verseNumber: verseNumber,
                            text: verseText,
                            isPoetry: isInPoetrySection
                        ))
                        print("📖 Added verse \(verseNumber) to Chapter \(currentChapter)")
                    }
                }
            } else if let verseNumber = pendingVerseNumber {
                // This is the text for a previous verse number
                currentVerses.append(Verse(
                    verseNumber: verseNumber,
                    text: trimmedLine,
                    isPoetry: isInPoetrySection
                ))
                print("📖 Added verse \(verseNumber) to Chapter \(currentChapter)")
                pendingVerseNumber = nil
            }
        }
        
        // Add final chapter
        if !currentVerses.isEmpty {
            chapters.append(Chapter(chapterNumber: currentChapter, verses: currentVerses))
            print("✓ Added final Chapter \(currentChapter) with \(currentVerses.count) verses")
        }
        
        print("📚 Finished loading book with \(chapters.count) chapters")
        if let firstChapter = chapters.first {
            print("First chapter has \(firstChapter.verses.count) verses")
            if let firstVerse = firstChapter.verses.first {
                print("First verse: [\(firstVerse.verseNumber)] \(firstVerse.text)")
            }
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
