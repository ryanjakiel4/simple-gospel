//
//  AppearanceManager.swift
//  simple-gospel
//
//  Created by Ryan Jakiel on 2/9/25.
//


import SwiftUI

class AppearanceManager: ObservableObject {
    @AppStorage("darkMode") private var isDarkMode: Bool = false
    @AppStorage("selectedFont") private var selectedFont: String = "System"
    @AppStorage("fontSize") private var fontSize: Int = 16
    
    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }
    
    var font: Font {
        switch selectedFont {
        case "Georgia":
            return .custom("Georgia", size: CGFloat(fontSize))
        case "Times New Roman":
            return .custom("Times New Roman", size: CGFloat(fontSize))
        case "Helvetica Neue":
            return .custom("Helvetica Neue", size: CGFloat(fontSize))
        default:
            return .system(size: CGFloat(fontSize))
        }
    }
} 