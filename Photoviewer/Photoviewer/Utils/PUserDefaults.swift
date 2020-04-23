//
//  PUserDefaults.swift
//  Photoviewer
//
//  Created by Ganesh TR on 16/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation

protocol UserDefaultsProtocol {
    func loadedImageFromLocalBundle()
    func resetLoadedImageFromLocalBundleKey()
    func isImageLoadedFromLocalBundle() -> Bool
}

class PDocumentDirectoryUserDefaults : UserDefaultsProtocol {
    static let sharedInstance = PDocumentDirectoryUserDefaults()
    
    private static let KImageLoadedKey = "PImageLoadedFromLocalBundleToDocumentDirectory"
    
    private init() {
        UserDefaults.standard.set(false, forKey: Self.KImageLoadedKey)
    }
    
    func loadedImageFromLocalBundle() {
        UserDefaults.standard.set(true, forKey: Self.KImageLoadedKey)
    }
    
    func resetLoadedImageFromLocalBundleKey() {
        UserDefaults.standard.set(false, forKey: Self.KImageLoadedKey)
    }
    
    func isImageLoadedFromLocalBundle() -> Bool {
        return UserDefaults.standard.bool(forKey: Self.KImageLoadedKey)
    }
}

class PCoreDataUserDefaults : UserDefaultsProtocol {
    static let sharedInstance = PCoreDataUserDefaults()
    
    private static let KCoreDataImageLoadedKey = "PImageLoadedFromLocalBundleToCoreData"
    
    private init() {
    }
    
    func loadedImageFromLocalBundle() {
        UserDefaults.standard.set(true, forKey: Self.KCoreDataImageLoadedKey)
    }
    
    func resetLoadedImageFromLocalBundleKey() {
        UserDefaults.standard.set(false, forKey: Self.KCoreDataImageLoadedKey)
    }
    
    func isImageLoadedFromLocalBundle() -> Bool {
        return UserDefaults.standard.bool(forKey: Self.KCoreDataImageLoadedKey)
    }
}
