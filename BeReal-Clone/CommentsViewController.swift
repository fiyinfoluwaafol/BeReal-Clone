//
//  CommentsViewController.swift
//  BeReal-Clone
//
//  Created by Fiyinfoluwa Afolayan on 2/10/25.
//

import UIKit
import ParseSwift

class CommentsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var post: Post! // This will store the post passed from FeedViewController
    private var comments = [Comment](){
        didSet {
                    tableView.reloadData()
                }
    } // Stores fetched comments

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        queryComments() // Fetch comments when view loads
    }
    
    // MARK: - Query Comments for the Post
    private func queryComments() {
        guard let postObjectId = post.objectId else { return }

        let query = Comment.query()
            .where("post.objectId" == postObjectId)
            .include("user")
            .order([.descending("createdAt")]) // Latest comments first

        query.find { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedComments):
                    self?.comments = fetchedComments
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("❌ Error fetching comments: \(error.localizedDescription)")
                }
            }
        }
    }
    
}

// MARK: - Table View Data Source
extension CommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        let comment = comments[indexPath.row]
        
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = comment.user?.username ?? "Unknown User"

        return cell
    }
}

// MARK: - Table View Delegate
extension CommentsViewController: UITableViewDelegate {}
