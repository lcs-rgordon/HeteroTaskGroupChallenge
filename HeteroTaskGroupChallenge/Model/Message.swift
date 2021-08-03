//
//  Message.swift
//  Message
//
//  Created by Russell Gordon on 2021-08-02.
//

import Foundation

struct Message: Codable, Identifiable {
    let id: Int
    let from: String
    let message: String
}
