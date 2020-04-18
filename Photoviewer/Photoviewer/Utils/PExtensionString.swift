//
//  PExtensionString.swift
//  Photoviewer
//
//  Created by Ganesh TR on 16/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation

extension String {
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }
    var pathExtension: String {
        return fileURL.pathExtension
    }
    var lastPathComponent: String {
        return fileURL.lastPathComponent
    }
    
    static func customImageName() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'_'HH_mm_ss"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        return #"\#(dateFormatter.string(from: date)).jpg"#
    }
}
