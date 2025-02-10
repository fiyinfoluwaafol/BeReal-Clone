//
//  PostViewController.swift
//  BeReal-Clone
//
//  Created by Fiyinfoluwa Afolayan on 1/29/25.
//

import UIKit
import PhotosUI
import ParseSwift
import CoreLocation

class PostViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!
    
    private var pickedImage: UIImage?
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var capturedTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPickedimageTapped(_ sender: Any) {
        // Make sure the user's camera is available
        // NOTE: Camera only available on physical iOS device, not available on simulator.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌📷 Camera not available")
            return
        }

        // Instantiate the image picker
        let imagePicker = UIImagePickerController()

        // Shows the camera (vs the photo library)
        imagePicker.sourceType = .camera

        // Allows user to edit image within image picker flow (i.e. crop, etc.)
        // If you don't want to allow editing, you can leave out this line as the default value of `allowsEditing` is false
        imagePicker.allowsEditing = true

        // The image picker (camera in this case) will return captured photos via it's delegate method to it's assigned delegate.
        // Delegate assignee must conform and implement both `UIImagePickerControllerDelegate` and `UINavigationControllerDelegate`
        imagePicker.delegate = self

        // Present the image picker (camera)
        present(imagePicker, animated: true)
    }
    
    
    @IBAction func onPostTapped(_ sender: UIButton) {
        // Dismiss Keyboard
        view.endEditing(true)
        
        if currentLocation == nil {
                print("❌ Location not available yet, retrying...")
                showAlert(description: "Waiting for location data. Try again in a moment.")
                return
            }
        
        // TODO: Pt 1 - Create and save Post
        // Unwrap optional pickedImage
        guard let image = pickedImage,
              // Create and compress image data (jpeg) from UIImage
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        // Captures time photo was taken
        capturedTime = Date()
        print("✅ Photo taken at: \(capturedTime!)")
        
        // Create a Parse File by providing a name and passing in the image data
        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        // Create Post object
        var post = Post()

        // Set properties
        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.photoTimestamp = capturedTime ?? Date()  // Store captured time

        if let location = currentLocation {
            print("✅ Saving Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            post.imageLocation = try? ParseGeoPoint(latitude: location.coordinate.latitude,
                                        longitude: location.coordinate.longitude)
        } else {
            print("❌ No Location Data Available at Time of Post")
        }

        // Set the user as the current user
        post.user = User.current

        // Save object in background (async)
        post.save { [weak self] result in

            // Switch to the main thread for any UI updates
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")

                    // Get the current user
                    if var currentUser = User.current {

                        // Update the `lastPostedDate` property on the user with the current date.
                        currentUser.lastPostedDate = Date()

                        // Save updates to the user (async)
                        currentUser.save { [weak self] result in
                            switch result {
                            case .success(let user):
                                print("✅ User Saved! \(user)")

                                // Switch to the main thread for any UI updates
                                DispatchQueue.main.async {
                                    // Return to previous view controller
                                    self?.navigationController?.popViewController(animated: true)
                                }

                            case .failure(let error):
                                self?.showAlert(description: error.localizedDescription)
                            }
                        }
                    }

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }

    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()  // Start fetching location
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            self.currentLocation = location
            print("✅ Captured Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//            locationManager.stopUpdatingLocation()  // Stop after getting location
        }
    
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Dismiss the image picker
            picker.dismiss(animated: true)

            // Get the edited image from the info dictionary (if `allowsEditing = true` for image picker config).
            // Alternatively, to get the original image, use the `.originalImage` InfoKey instead.
            guard let image = info[.editedImage] as? UIImage else {
                print("❌📷 Unable to get image")
                return
            }

            // Set image on preview image view
            previewImageView.image = image

            // Set image to use when saving post
            pickedImage = image
    }
}

