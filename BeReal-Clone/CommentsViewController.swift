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
        tableView.rowHeight = 150
//        tableView.estimatedRowHeight = 100
        
        queryComments() // Fetch comments when view loads
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryComments()
        tableView.reloadData()
    }
    
    // MARK: - Query Comments for the Post
    private func queryComments() {
        guard let postObjectId = post.objectId else {
                print("❌ Error: Post objectId is nil!")
                return
            }

            print("🚀 Querying comments for Post ID: \(postObjectId)")

            guard let postPointer = try? post.toPointer() else {
                print("❌ Error: Could not convert post to pointer!")
                return
            }
        
            let query = Comment.query()
                .where("post" == postPointer)
                .include("user")
                .order([.descending("createdAt")]) // Latest comments first

            query.find { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedComments):
                        print("✅ Successfully fetched \(fetchedComments.count) comments")
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }

        let comment = comments[indexPath.row]
        print("📝 Loading Comment: \(comment.text) by \(comment.user?.username ?? "Unknown User")")

        // Call configure function to set up UI
        cell.configure(with: comment)
        
        return cell
    }
}

// MARK: - Table View Delegate
extension CommentsViewController: UITableViewDelegate {}
