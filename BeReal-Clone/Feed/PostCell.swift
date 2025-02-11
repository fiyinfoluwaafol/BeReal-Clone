//
//  PostCell.swift
//  BeReal-Clone
//
//  Created by Fiyinfoluwa Afolayan on 2/3/25.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreLocation
import ParseSwift


protocol PostCellDelegate: AnyObject {
    func didPostComment(for post: Post, comment: String)
}

class PostCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var usernameInitialsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var postCommentButton: UIButton!
    
    weak var delegate: PostCellDelegate?
    private var post: Post?
    
    private var imageDataRequest: DataRequest?
    
    func configure(with post: Post) {
        // TODO: Pt 1 - Configure Post Cell
        self.post = post
        // Username
        if let user = post.user {
            usernameLabel.text = user.username
        } else {
            usernameLabel.text = "Sam Wasabi"
        }

        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {
            
            // Use AlamofireImage helper to fetch remote image from URL
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    // Set image view image with fetched image
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }

        // Caption
        captionLabel.text = post.caption
        
        // ✅ Convert GPS coordinates to location name
            if let location = post.imageLocation {
                getAddressFromLocation(location) { locationName in
                    DispatchQueue.main.async {
                        self.locationLabel.text = locationName ?? "Location unknown"
                    }
                }
            } else {
                locationLabel.text = "Location unknown"
            }

        // Date
        if let date = post.createdAt {
            dateTimeLabel.text = DateFormatter.postFormatter.string(from: date)
        }
        
        // A lot of the following returns optional values so we'll unwrap them all together in one big `if let`
        // Get the current user.
        if let currentUser = User.current,

            // Get the date the user last shared a post (cast to Date).
           let lastPostedDate = currentUser.lastPostedDate,

            // Get the date the given post was created.
           let postCreatedDate = post.createdAt,

            // Get the difference in hours between when the given post was created and the current user last posted.
           let diffHours = Calendar.current.dateComponents([.hour], from: postCreatedDate, to: lastPostedDate).hour {

            // Hide the blur view if the given post was created within 24 hours of the current user's last post. (before or after)
            blurView.isHidden = abs(diffHours) < 24
        } else {

            // Default to blur if we can't get or compute the date's above for some reason.
            blurView.isHidden = false
        }
    }
    
    @IBAction func onPostCommentTapped(_ sender: UIButton) {
        print("📩 Comment Button Pressed")  // ✅ Check if button press is registered
            
            guard let post = post else {
                print("❌ No post found in PostCell!")
                return
            }
            
            guard let commentText = commentTextField.text, !commentText.isEmpty else {
                print("❌ Comment text is empty!")
                return
            }
            
            print("📤 Sending Comment: \(commentText)")
            
            delegate?.didPostComment(for: post, comment: commentText)
            
            // ✅ Clear text field after posting
            commentTextField.text = ""
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // TODO: P1 - Cancel image download
        // Reset image view image.
        postImageView.image = nil

        // Cancel image request.
        imageDataRequest?.cancel()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        usernameInitialsLabel.layer.cornerRadius = usernameInitialsLabel.frame.size.width / 2
        usernameInitialsLabel.clipsToBounds = true
    }
    
    func getAddressFromLocation(_ location: ParseGeoPoint, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            if let error = error {
                print("❌ Error getting location name: \(error.localizedDescription)")
                completion(nil)
                return
            }
            let place = placemarks?.first
            let locationString = "\(place?.locality ?? "Unknown"), \(place?.country ?? "Unknown")"
            completion(locationString)
        }
    }

}
