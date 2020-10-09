//
//  BoltDetails.swift
//  SparkPerso
//
//  Created by Florian on 08/10/2020.
//  Copyright © 2020 AlbanPerli. All rights reserved.
//

import Foundation

struct BoltDetails: Codable {
    let UUID: UUID
    let type: String
    let clan: String
    let activity: String
    let link: Int
}
