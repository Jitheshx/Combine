//
//  SampleModel.swift
//  CombineWithSwift
//
//  Created by Jithesh Xavier on 05/04/23.
//

import Foundation

// MARK: - Welcome
class Welcome: Codable {
    let page, perPage, total, totalPages: Int?
    let data: [Datum]?
    let support: Support?

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case data, support
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try container.decodeIfPresent(Int.self, forKey: .page)
        self.perPage = try container.decodeIfPresent(Int.self, forKey: .perPage)
        self.total = try container.decodeIfPresent(Int.self, forKey: .total)
        self.totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        self.data = try container.decodeIfPresent([Datum].self, forKey: .data)
        self.support = try container.decodeIfPresent(Support.self, forKey: .support)
    }
}

// MARK: - Datum
class Datum: Codable {
    let id: Int?
    let name: String?
    let year: Int?
    let color, pantoneValue: String?

    enum CodingKeys: String, CodingKey {
        case id, name, year, color
        case pantoneValue = "pantone_value"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.year = try container.decodeIfPresent(Int.self, forKey: .year)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
        self.pantoneValue = try container.decodeIfPresent(String.self, forKey: .pantoneValue)
    }
}

// MARK: - Support
class Support: Codable {
    let url: String?
    let text: String?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
    }
}
