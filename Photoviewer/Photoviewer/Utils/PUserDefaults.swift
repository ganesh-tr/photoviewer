//
//  PUserDefaults.swift
//  Photoviewer
//
//  Created by Ganesh TR on 16/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation

class PUserDefaults {
    static let sharedInstance = PUserDefaults()
    private static let KImageLoadedKey = "PImageLoadedFromLocalBundle"
    
    private init() {
        UserDefaults.standard.set(false, forKey: Self.KImageLoadedKey)
    }
    
    func loadedImageFromLocalBundle() {
        UserDefaults.standard.set(true, forKey: Self.KImageLoadedKey)
    }
    func isImageLoadedFromLocalBundle() -> Bool {
        return UserDefaults.standard.bool(forKey: Self.KImageLoadedKey)
    }
}
