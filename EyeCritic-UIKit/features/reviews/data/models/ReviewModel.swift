//
//  ReviewModel.swift
//  EyeCritic-UIKit
//
//  Created by Pedro Rodrigues on 21/08/21.
//

import Foundation

struct ReviewModel: Codable {
    var display_title: String
    var mpaa_rating: String
    var byline: String
    var headline: String
    var summary_short: String
    var publication_date: String
    var multimedia: Multimedia?
    var link: Link
    
    func toReview() -> Review {
        Review(
            displayTitle: self.display_title,
            rating: self.mpaa_rating,
            byLine: self.byline,
            headline: self.headline,
            summary: self.summary_short,
            publicationDate: self.publication_date,
            imageUrl: self.multimedia?.src ?? "",
            link: self.link.url,
            favorite: false
        )
    }
    
    static func fromCacheReview(data: ReviewData) -> ReviewModel {
        return ReviewModel(
            display_title: data.display_title!,
            mpaa_rating: data.mpaa_rating!,
            byline: data.byline!,
            headline: data.headline!,
            summary_short: data.summary_short!,
            publication_date: data.publication_date!,
            multimedia: Multimedia(src: data.imageUrl!),
            link: Link(url: data.link!)
        )
    }
}

struct Multimedia: Codable {
    var src: String
}

struct Link: Codable {
    var url: String
}
