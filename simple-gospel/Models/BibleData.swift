struct BibleData {
    struct Verse: Identifiable {
        let id: String  // e.g. "GEN_1_1"
        let number: Int
        let text: String
        let isPoetry: Bool
    }
    
    struct Chapter {
        let number: Int
        let verses: [Verse]
    }
    
    struct Book {
        let name: String
        let chapters: [Chapter]
    }
}

// Make the types property list serializable
extension BibleData.Verse: Codable {}
extension BibleData.Chapter: Codable {}
extension BibleData.Book: Codable {} 