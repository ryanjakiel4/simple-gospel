import Foundation

struct Book: Identifiable {
    let id = UUID()
    let name: String
    let chapters: Int
    let abbreviation: String
    
    static let allBooks = [
        // Old Testament (39 books)
        Book(name: "Genesis", chapters: 50, abbreviation: "Gen"),
        Book(name: "Exodus", chapters: 40, abbreviation: "Exo"),
        Book(name: "Leviticus", chapters: 27, abbreviation: "Lev"),
        Book(name: "Numbers", chapters: 36, abbreviation: "Num"),
        Book(name: "Deuteronomy", chapters: 34, abbreviation: "Deu"),
        Book(name: "Joshua", chapters: 24, abbreviation: "Jos"),
        Book(name: "Judges", chapters: 21, abbreviation: "Jdg"),
        Book(name: "Ruth", chapters: 4, abbreviation: "Rut"),
        Book(name: "1 Samuel", chapters: 31, abbreviation: "1Sa"),
        Book(name: "2 Samuel", chapters: 24, abbreviation: "2Sa"),
        Book(name: "1 Kings", chapters: 22, abbreviation: "1Ki"),
        Book(name: "2 Kings", chapters: 25, abbreviation: "2Ki"),
        Book(name: "1 Chronicles", chapters: 29, abbreviation: "1Ch"),
        Book(name: "2 Chronicles", chapters: 36, abbreviation: "2Ch"),
        Book(name: "Ezra", chapters: 10, abbreviation: "Ezr"),
        Book(name: "Nehemiah", chapters: 13, abbreviation: "Neh"),
        Book(name: "Esther", chapters: 10, abbreviation: "Est"),
        Book(name: "Job", chapters: 42, abbreviation: "Job"),
        Book(name: "Psalms", chapters: 150, abbreviation: "Psa"),
        Book(name: "Proverbs", chapters: 31, abbreviation: "Pro"),
        Book(name: "Ecclesiastes", chapters: 12, abbreviation: "Ecc"),
        Book(name: "Song of Solomon", chapters: 8, abbreviation: "Sng"),
        Book(name: "Isaiah", chapters: 66, abbreviation: "Isa"),
        Book(name: "Jeremiah", chapters: 52, abbreviation: "Jer"),
        Book(name: "Lamentations", chapters: 5, abbreviation: "Lam"),
        Book(name: "Ezekiel", chapters: 48, abbreviation: "Ezk"),
        Book(name: "Daniel", chapters: 12, abbreviation: "Dan"),
        Book(name: "Hosea", chapters: 14, abbreviation: "Hos"),
        Book(name: "Joel", chapters: 3, abbreviation: "Joe"),
        Book(name: "Amos", chapters: 9, abbreviation: "Amo"),
        Book(name: "Obadiah", chapters: 1, abbreviation: "Oba"),
        Book(name: "Jonah", chapters: 4, abbreviation: "Jon"),
        Book(name: "Micah", chapters: 7, abbreviation: "Mic"),
        Book(name: "Nahum", chapters: 3, abbreviation: "Nah"),
        Book(name: "Habakkuk", chapters: 3, abbreviation: "Hab"),
        Book(name: "Zephaniah", chapters: 3, abbreviation: "Zep"),
        Book(name: "Haggai", chapters: 2, abbreviation: "Hag"),
        Book(name: "Zechariah", chapters: 14, abbreviation: "Zec"),
        Book(name: "Malachi", chapters: 4, abbreviation: "Mal"),
        
        // New Testament (27 books)
        Book(name: "Matthew", chapters: 28, abbreviation: "Mat"),
        Book(name: "Mark", chapters: 16, abbreviation: "Mrk"),
        Book(name: "Luke", chapters: 24, abbreviation: "Luk"),
        Book(name: "John", chapters: 21, abbreviation: "Jhn"),
        Book(name: "Acts", chapters: 28, abbreviation: "Act"),
        Book(name: "Romans", chapters: 16, abbreviation: "Rom"),
        Book(name: "1 Corinthians", chapters: 16, abbreviation: "1Co"),
        Book(name: "2 Corinthians", chapters: 13, abbreviation: "2Co"),
        Book(name: "Galatians", chapters: 6, abbreviation: "Gal"),
        Book(name: "Ephesians", chapters: 6, abbreviation: "Eph"),
        Book(name: "Philippians", chapters: 4, abbreviation: "Php"),
        Book(name: "Colossians", chapters: 4, abbreviation: "Col"),
        Book(name: "1 Thessalonians", chapters: 5, abbreviation: "1Th"),
        Book(name: "2 Thessalonians", chapters: 3, abbreviation: "2Th"),
        Book(name: "1 Timothy", chapters: 6, abbreviation: "1Ti"),
        Book(name: "2 Timothy", chapters: 4, abbreviation: "2Ti"),
        Book(name: "Titus", chapters: 3, abbreviation: "Tit"),
        Book(name: "Philemon", chapters: 1, abbreviation: "Phm"),
        Book(name: "Hebrews", chapters: 13, abbreviation: "Heb"),
        Book(name: "James", chapters: 5, abbreviation: "Jas"),
        Book(name: "1 Peter", chapters: 5, abbreviation: "1Pe"),
        Book(name: "2 Peter", chapters: 3, abbreviation: "2Pe"),
        Book(name: "1 John", chapters: 5, abbreviation: "1Jn"),
        Book(name: "2 John", chapters: 1, abbreviation: "2Jn"),
        Book(name: "3 John", chapters: 1, abbreviation: "3Jn"),
        Book(name: "Jude", chapters: 1, abbreviation: "Jud"),
        Book(name: "Revelation", chapters: 22, abbreviation: "Rev")
    ]
}

// Add a computed property to get the filename
extension Book {
    var filename: String {
        // Handle special characters in book names
        return name.replacingOccurrences(of: " ", with: "+")
    }
} 
