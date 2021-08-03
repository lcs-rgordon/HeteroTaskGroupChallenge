//
//  ConsolidatedUser.swift
//  ConsolidatedUser
//
//  Created by Russell Gordon on 2021-08-03.
//

import Foundation

struct ConsolidatedUser {
    let username: String
    let messages: [Message]
    let favourites: Set<Int>
}
