//
//  Post.swift
//  BeReal-Clone
//
//  Created by Fiyinfoluwa Afolayan on 1/29/25.
//

import Foundation
import ParseSwift

struct Post: ParseObject {
    // These are required by ParseObject
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Your own custom properties.
    var caption: String?
    var user: User?
    var imageFile: ParseFile?
    var photoTimestamp: Date?
    var imageLocation: ParseGeoPoint?
    var comments: [Comment]? 
}
