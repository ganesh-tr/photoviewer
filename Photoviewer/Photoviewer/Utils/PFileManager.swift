//
//  PFileManager.swift
//  Photoviewer
//
//  Created by Ganesh TR on 15/04/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation
import UIKit

protocol PFileMangerProtocol {
    func resourcePath() -> String?
    func documentDirectoryPath() -> URL?
    func directoryContentAtPath(_ path: String) -> [String]
    func appendFileNameWithPath(_ path:String,fileName:String) -> String
    func appendFileNameWithPath(_ path:URL?,fileName:String) -> URL?
}

class PFileManager : PFileMangerProtocol {
    init() {}
    
    func documentDirectoryPath() -> URL? {
           return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
       
    func directoryContentAtPath(_ path: String) -> [String] {
       do {
           return try FileManager.default.contentsOfDirectory(atPath: path)
       } catch {
           return []
       }
    }
       
    func resourcePath() -> String? {
       return Bundle.main.resourcePath
    }

    func appendFileNameWithPath(_ path:String,fileName:String) -> String {
       return #"\#(path)/\#(fileName)"#
    }

    func appendFileNameWithPath(_ path:URL?,fileName:String) -> URL? {
        return path?.appendingPathComponent(fileName)
    }
}

class PTestFileManager : PFileMangerProtocol {
    init() {}
    
    func documentDirectoryPath() -> URL? {
           return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
       
    func directoryContentAtPath(_ path: String) -> [String] {
        return ["g.jpeg","h.jpeg"]
    }
       
    func resourcePath() -> String? {
       return Bundle.main.resourcePath
    }

    func appendFileNameWithPath(_ path:String,fileName:String) -> String {
       return #"\#(path)/\#(fileName)"#
    }

    func appendFileNameWithPath(_ path:URL?,fileName:String) -> URL? {
        return path?.appendingPathComponent(fileName)
    }
}

