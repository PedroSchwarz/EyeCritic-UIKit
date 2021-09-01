//
//  Review.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 21/08/21.
//

import Foundation

struct Review {
    var displayTitle: String
    var rating: String
    var byLine: String
    var headline: String
    var summary: String
    var publicationDate: String
    var imageUrl: String
    var link: String
    var favorite: Bool
    
    var id: String {
        self.displayTitle
    }
    
    var formattedDate: String {
        if let date = DateFormatters.fromStringFormat.date(from: self.publicationDate) {
            let formatter = DateFormatters.localDateFormat
            return formatter.string(from: date)
        } else {
            return "N/A"
        }
    }
}
