//
//  FeedViewController.swift
//  BeReal-Clone
//
//  Created by Fiyinfoluwa Afolayan on 1/29/25.
//

import UIKit
import ParseSwift
import UserNotifications

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    
    private var posts = [Post]() {
        didSet {
            // Reload table view data any time the posts variable gets updated.
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        tableView.rowHeight = 500
//        tableView.estimatedRowHeight = 200
        
        requestNotificationPermission()
        schedulePostReminder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryPosts()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showCommentsSegue" {
//            guard let commentsVC = segue.destination as? CommentsViewController,
//                  let cell = sender as? PostCell,
//                  let indexPath = tableView.indexPath(for: cell) else {
//                print("❌ Error: Unable to get selected post!")
//                return
//            }
//
//            commentsVC.post = posts[indexPath.row] // Pass the post to fetch its comments
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCommentsSegue" {
            print("🚀 Preparing segue to CommentsViewController")
            
            // Ensure the destination is the CommentsViewController
            guard let commentsVC = segue.destination as? CommentsViewController else {
                print("❌ Error: segue.destination is nil or not a CommentsViewController")
                return
            }

            // Get the button that triggered the segue
            guard let button = sender as? UIButton else {
                print("❌ Error: sender is not a UIButton")
                return
            }

            // Find the PostCell that contains the button
            guard let cell = button.superview?.superview as? PostCell else {
                print("❌ Error: Could not find PostCell from button")
                return
            }

            // Get the index path of the cell
            guard let indexPath = tableView.indexPath(for: cell) else {
                print("❌ Error: Could not get indexPath for PostCell")
                return
            }

            let selectedPost = posts[indexPath.row]
            commentsVC.post = selectedPost
            print("✅ Successfully passing Post with ID: \(selectedPost.objectId ?? "No ID")")
        }
    }

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted!")
            } else {
                print("❌ Notification permission denied.")
            }
        }
    }
    
    func schedulePostReminder() {
        let center = UNUserNotificationCenter.current()

        // Remove existing notifications to prevent duplicates
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Time to BeReal! 📸"
        content.body = "Post your daily moment before time runs out!"
        content.sound = .default

        // Schedule notification for a fixed time (e.g., 8 PM)
        var dateComponents = DateComponents()
        dateComponents.hour = 11  // Set hour (24-hour format)
        dateComponents.minute = 02  // Set minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyPostReminder", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Reminder notification scheduled!")
            }
        }
    }
    
    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
        print("Logout pressed")
    }
    
    private func queryPosts() {
        // TODO: Pt 1 - Query Posts
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!
        
//        let isoDateFormatter = ISO8601DateFormatter()
//        let formattedDate = isoDateFormatter.string(from: yesterdayDate)
// https://github.com/parse-community/Parse-Swift/blob/3d4bb13acd7496a49b259e541928ad493219d363/ParseSwift.playground/Pages/2%20-%20Finding%20Objects.xcplaygroundpage/Contents.swift#L66
        // 1. Create a query to fetch Posts
        // 2. Any properties that are Parse objects are stored by reference in Parse DB and as such need to explicitly use `include_:)` to be included in query results.
        // 3. Sort the posts by descending order based on the created at date
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate)
            .limit(10)

        // Fetch objects (posts) defined in query (async)
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                // Update local posts property with fetched posts
                self?.posts = posts
                // 🔍 Debugging - Print usernames for all posts
                for post in posts {
                    if let user = post.user {
                        print("✅ Post by: \(user.username ?? "No username")")
                        print("📩 Comments: \(post.comments ?? [])")
                    } else {
                        print("❌ post.user is nil for post ID: \(post.objectId ?? "No ID")")
                    }
                }
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }

    }
    
    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension FeedViewController: UITableViewDelegate { }

extension FeedViewController: PostCellDelegate {
    func didPostComment(for post: Post, comment: String) {
        view.endEditing(true)
        print("🔵 Delegate Function Triggered!") // ✅ First check if function is called
            
            var newComment = Comment()
            newComment.text = comment
            newComment.user = User.current
            newComment.post = post

            print("📤 Saving comment: \(comment) for Post ID: \(post.objectId ?? "No ID")")

            newComment.save { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("✅ Comment posted successfully!")
                    case .failure(let error):
                        print("❌ Error posting comment: \(error.localizedDescription)")
                    }
                }
            }
    }
}

