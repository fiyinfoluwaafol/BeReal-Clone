//
//  Comment.swift
//  BeReal-Clone
//
//  Created by Fiyinfoluwa Afolayan on 2/10/25.
//

import Foundation
import ParseSwift

struct Comment: ParseObject {
    // These are required by ParseObject
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Your own custom properties.
    var text: String?
    var user: User?
    var post: Post?
}
