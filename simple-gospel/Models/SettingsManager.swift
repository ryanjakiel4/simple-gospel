import SwiftUI

class SettingsManager: ObservableObject {
    @Published var columnsCount: Int {
        didSet {
            UserDefaults.standard.set(columnsCount, forKey: "columns_count")
        }
    }
    
    init() {
        // Register default values
        UserDefaults.standard.register(defaults: [
            "columns_count": 3
        ])
        
        // Load saved value
        self.columnsCount = UserDefaults.standard.integer(forKey: "columns_count")
    }
} 