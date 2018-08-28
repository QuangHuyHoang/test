/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2018B
 Assessment: Assignment
 Author: Hoang Quang Huy
 ID: s3623383
 Created date: 23/08/2018
 Acknowledgement:
 1. https://developer.apple.com
 2. https://www.youtube.com/watch?v=ssIpdu73p7A
 3. https://www.hackingwithswift.com/example-code/media/how-to-choose-a-photo-from-the-camera-roll-using-uiimagepickercontroller
 4. https://stackoverflow.com/questions/38012284/how-to-set-up-different-auto-layout-constraints-for-different-screen-sizes
 */

import UIKit
import Foundation

class EditViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    @IBOutlet weak var songTitleField: UITextField!
    @IBOutlet weak var songArtistField: UITextField!
    @IBOutlet weak var songYearField: UITextField!
    @IBOutlet weak var songURLField: UITextField!
    
    @IBOutlet weak var goBtn: UIButton!
    
    @IBOutlet weak var songEditImage: UIImageView!
    
    //method to load the data from database to the field
    func configureView() {
        // Update the user interface for the detail item.
        if let title  = songTitleField {
            title.text = songInfo!.title
        }
        if let artist = songArtistField {
            artist.text = songInfo!.artist
        }
        if let year  = songYearField {
            year.text = songInfo!.year
        }
        if let url  = songURLField {
            url.text = songInfo!.url
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        let addBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButton))
        self.navigationItem.rightBarButtonItem = addBtn
        //load the image
            if let data = songInfo!.image {
                songEditImage.image = UIImage(data: data)
        //and load the rest of the data
            configureView()
        }
    }
    
    var songInfo:Song? {
        didSet {
            configureView()
        }
    }
    //same methods of taking picture from camera roll
    @IBAction func getImage(_ sender: UIButton) {
        selectPicture()
    }
    
    func selectPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let usableLink = songInfo?.url
        //disable the button if the url happen to not updated
        //yet when user edit the url
        if usableLink == "Unknown" || songURLField.isTouchInside == true {
            goBtn.isHidden = true
        }
        view.endEditing(true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        //save the newly chosen image
        songEditImage.image = newImage
        songInfo?.image = UIImagePNGRepresentation(newImage) as Data?
        PersistenceService.saveContext()
        
        dismiss(animated: true)
    }
    
    @IBAction func go(_ sender: UIButton) {
        let urlLink = songInfo!.url
        if urlLink != "" && urlLink != nil {
            if urlLink!.starts(with: "http://") {
                let url : URL = URL(string: urlLink!)!
                UIApplication.shared.open(url, options: ["":""], completionHandler: nil)
            } else {
                let url : URL = URL(string: "http://" + urlLink!)!
                UIApplication.shared.open(url, options: ["":""], completionHandler: nil)
            }
        }
    }
    
    @objc func doneButton() {
        //same as before
        //don't want any field to be empty
        if songTitleField.text! == "" {
            let alert = UIAlertController(title: "Empty Title", message: "Your song's title is missing", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        if songArtistField.text! == "" {
            songArtistField.text! = "Unknown"
        }
        if songYearField.text! == "" {
            songYearField.text! = "Unknown"
        }
        if songURLField.text! == "" {
            songURLField.text! = "Unknown"
        }
        
        //update the data and save the change
        songInfo!.title = songTitleField.text
        songInfo!.artist = songArtistField.text
        songInfo!.year = songYearField.text
        songInfo!.url = songURLField.text
        
        PersistenceService.saveContext()
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

