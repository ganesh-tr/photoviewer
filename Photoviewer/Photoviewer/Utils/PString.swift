//
//  PString.swift
//  Photoviewer
//
//  Created by Ganesh TR on 06/05/20.
//  Copyright © 2020 Ganesh TR. All rights reserved.
//

import Foundation

struct PString {

    static func a11yTextForFavourite() -> String {
        return NSLocalizedString("Favourite", comment:"")
    }

    static func a11yTextForFavouriteSelection(selection:Bool) -> String {
        return selection ? NSLocalizedString("Selected", comment:"")
                         : NSLocalizedString("Not Selected", comment:"")
    }
    
    static func a11yTitleTextForAddButton() -> String {
        return NSLocalizedString("Add", comment:"")
    }
    
    static func a11yTextForAddButton() -> String {
        return NSLocalizedString("Add Image", comment:"")
    }
    
    static func a11yTextForFilterButton() -> String {
        return NSLocalizedString("Filter Image", comment:"")
    }
    
    static func a11yTextForRemoveFilter() -> String {
        return NSLocalizedString("Remove Filter", comment:"")
    }
    
    static func a11yTextForCancelButton() -> String {
        return NSLocalizedString("Cancel", comment:"")
    }
}
