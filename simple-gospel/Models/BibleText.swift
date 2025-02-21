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
        let sectionIndex: Int  // Add this to track which section the verse belongs to
    }
    
    struct Section {
        let verses: [Verse]
        let isPoetry: Bool
    }
    
    struct Chapter {
        let chapterNumber: Int
        let sections: [Section]  // Change from verses to sections
        
        var displayText: String {
            sections.map { section in
                let prefix = section.isPoetry ? "    " : "" // Indent poetry
                // Use Unicode superscript numbers for verse numbers
                let superscriptNumber = section.verses.map { verse in
                    verse.verseNumber.map { char -> String in
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
                }.joined(separator: " ")
                return "\(prefix)\(superscriptNumber)\n\n\(section.verses.map { $0.text }.joined(separator: "\n\n"))"
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
        var currentSectionIndex = 0
        
        let lines = content.components(separatedBy: .newlines)
        print("Found \(lines.count) lines in file")
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty || trimmedLine == "\(bookName) Text" {
                continue
            }
            
            if trimmedLine.starts(with: "Chapter ") {
                if currentChapter > 0 && !currentVerses.isEmpty {
                    let sections = Dictionary(grouping: currentVerses) { $0.sectionIndex }
                        .sorted { $0.key < $1.key }
                        .map { Section(verses: $0.value, isPoetry: $0.value.first?.isPoetry ?? false) }
                    chapters.append(Chapter(chapterNumber: currentChapter, sections: sections))
                    currentVerses = []
                }
                currentChapter = Int(trimmedLine.replacingOccurrences(of: "Chapter ", with: "")) ?? 0
                pendingVerseNumber = nil
            } else if trimmedLine == "[poetry]" {
                if !currentVerses.isEmpty {
                    currentSectionIndex += 1
                }
                isInPoetrySection = true
            } else if trimmedLine == "[bodytext]" {
                if !currentVerses.isEmpty {
                    currentSectionIndex += 1
                }
                isInPoetrySection = false
            } else if trimmedLine.starts(with: "[") && trimmedLine.hasSuffix("]") {
                // This is a standalone verse number
                if let verseRange = trimmedLine.range(of: #"\[(\d+(?::\d+)?)\]"#, options: .regularExpression) {
                    var verseNumber = String(trimmedLine[verseRange])
                        .replacingOccurrences(of: "[", with: "")
                        .replacingOccurrences(of: "]", with: "")
                    
                    // Convert "chapter:verse" format to just "verse"
                    if verseNumber.contains(":") {
                        verseNumber = String(verseNumber.split(separator: ":")[1])
                    }
                    
                    pendingVerseNumber = verseNumber
                }
            } else if !trimmedLine.isEmpty && pendingVerseNumber != nil {
                // This line contains the text for the pending verse number and possibly more verses
                var text = trimmedLine
                var currentVerseNumber = pendingVerseNumber!
                
                // Find all verse numbers in the text, including both [n] and [n:m] formats
                let pattern = #"\[(\d+(?::\d+)?)\]"#  // Changed pattern to match both formats
                let regex = try! NSRegularExpression(pattern: pattern)
                let range = NSRange(text.startIndex..., in: text)
                let matches = regex.matches(in: text, range: range)
                
                if matches.isEmpty {
                    // Just a single verse
                    currentVerses.append(Verse(
                        verseNumber: currentVerseNumber,
                        text: text,
                        isPoetry: isInPoetrySection,
                        sectionIndex: currentSectionIndex
                    ))
                    print("📖 Added single verse \(currentVerseNumber) to Chapter \(currentChapter)")
                } else {
                    // Multiple verses in this text
                    var lastIndex = text.startIndex
                    
                    for match in matches {
                        let matchRange = Range(match.range, in: text)!
                        let verseText = String(text[lastIndex..<matchRange.lowerBound])
                            .trimmingCharacters(in: .whitespaces)
                        
                        if !verseText.isEmpty {
                            currentVerses.append(Verse(
                                verseNumber: currentVerseNumber,
                                text: verseText,
                                isPoetry: isInPoetrySection,
                                sectionIndex: currentSectionIndex
                            ))
                            print("📖 Added verse \(currentVerseNumber) to Chapter \(currentChapter)")
                        }
                        
                        // Extract and clean up the next verse number
                        var nextVerseNumber = String(text[Range(match.range(at: 1), in: text)!])
                        if nextVerseNumber.contains(":") {
                            nextVerseNumber = String(nextVerseNumber.split(separator: ":")[1])
                        }
                        currentVerseNumber = nextVerseNumber
                        lastIndex = matchRange.upperBound
                    }
                    
                    // Add the final verse text
                    let finalText = String(text[lastIndex...]).trimmingCharacters(in: .whitespaces)
                    if !finalText.isEmpty {
                        currentVerses.append(Verse(
                            verseNumber: currentVerseNumber,
                            text: finalText,
                            isPoetry: isInPoetrySection,
                            sectionIndex: currentSectionIndex
                        ))
                        print("📖 Added final verse \(currentVerseNumber) to Chapter \(currentChapter)")
                    }
                }
                
                pendingVerseNumber = nil
            }
        }
        
        // When creating a Chapter, group verses into sections
        if !currentVerses.isEmpty {
            let sections = Dictionary(grouping: currentVerses) { $0.sectionIndex }
                .sorted { $0.key < $1.key }
                .map { Section(verses: $0.value, isPoetry: $0.value.first?.isPoetry ?? false) }
            chapters.append(Chapter(chapterNumber: currentChapter, sections: sections))
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
