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
    
    static func customImageName(date:Date = Date()) -> String {
        return #"\#(Self.stringFrom(date:date)).jpg"#
    }
    
    static func stringFrom(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'_'HH_mm_ss"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        return #"\#(dateFormatter.string(from: date))"#
    }
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        return dateFormatter.date(from:self)
    }
}
