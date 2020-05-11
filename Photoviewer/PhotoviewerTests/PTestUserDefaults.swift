//
//  PTestUserDefaults.swift
//  PhotoviewerTests
//
//  Created by Ganesh TR on 09/05/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation
class PDocumentDirectoryTestUserDefaults : UserDefaultsProtocol {
    static let sharedInstance = PDocumentDirectoryTestUserDefaults()
    
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

class PTestCoreDataUserDefaults : UserDefaultsProtocol {
    static let sharedInstance = PTestCoreDataUserDefaults()
    
    private static let KCoreDataImageLoadedKey = "PImageTestLoadedFromLocalBundleToCoreData"
    
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
