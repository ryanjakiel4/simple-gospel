//
//  Book.swift
//  simple-gospel
//
//  Created by Ryan Jakiel on 2/9/25.
//


struct Book: Identifiable {
    let id = UUID()
    let name: String
    let chapters: Int
    let abbreviation: String
    
    static let allBooks = [
        Book(name: "Genesis", chapters: 50, abbreviation: "Gen"),
        Book(name: "Exodus", chapters: 40, abbreviation: "Exo"),
        // Add all books here
        Book(name: "Revelation", chapters: 22, abbreviation: "Rev")
    ]
} 
