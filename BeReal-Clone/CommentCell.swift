//
//  CommentCell.swift
//  BeReal-Clone
//
//  Created by Fiyinfoluwa Afolayan on 2/10/25.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

    func configure(with comment: Comment) {
        usernameLabel.text = comment.user?.username ?? "Sam Wasabi"
        commentLabel.text = comment.text
    }
}
