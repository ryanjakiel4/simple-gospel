import Foundation

final class BibleDataManager {
    static let shared = BibleDataManager()
    private var bookCache: [String: BibleData.Book] = [:]
    private var chapterCache: [String: [Int: BibleData.Chapter]] = [:]
    
    private init() {}
    
    func loadBook(_ name: String) -> BibleData.Book? {
        // Return cached book if available
        if let cachedBook = bookCache[name] {
            return cachedBook
        }
        
        // Load book from plist if not cached
        let cleanName = name.replacingOccurrences(of: " ", with: "+")
        if let url = Bundle.main.url(forResource: cleanName, withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let book = try? PropertyListDecoder().decode(BibleData.Book.self, from: data) {
            
            // Cache the book and its chapters separately
            bookCache[name] = book
            var chapterDict: [Int: BibleData.Chapter] = [:]
            for chapter in book.chapters {
                chapterDict[chapter.number] = chapter
            }
            chapterCache[name] = chapterDict
            
            return book
        }
        
        return nil
    }
    
    func getChapter(book: String, number: Int) -> BibleData.Chapter? {
        // Check chapter cache first
        if let chapterDict = chapterCache[book], let chapter = chapterDict[number] {
            return chapter
        }
        
        // If not in cache, load the book
        _ = loadBook(book)
        return chapterCache[book]?[number]
    }
    
    func getChapters(book: String, range: Range<Int>) -> [BibleData.Chapter] {
        var chapters: [BibleData.Chapter] = []
        
        // Ensure book is loaded
        if chapterCache[book] == nil {
            _ = loadBook(book)
        }
        
        if let chapterDict = chapterCache[book] {
            for number in range {
                if let chapter = chapterDict[number] {
                    chapters.append(chapter)
                }
            }
        }
        
        return chapters
    }
    
    // Clear cache if memory warning received
    func clearCache() {
        bookCache.removeAll()
        chapterCache.removeAll()
    }
} 