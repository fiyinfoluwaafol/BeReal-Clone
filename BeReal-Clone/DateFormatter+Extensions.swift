//
//  DateFormatter+Extensions.swift
//  BeReal-Clone
//
//  Created by Fiyinfoluwa Afolayan on 2/3/25.
//

import Foundation

extension DateFormatter {
    static var postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}
