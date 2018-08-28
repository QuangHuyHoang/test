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

class DetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    @IBOutlet weak var songTitleField: UITextField!
    @IBOutlet weak var songArtistField: UITextField!
    @IBOutlet weak var songYearField: UITextField!
    @IBOutlet weak var songURLField: UITextField!
    
    @IBOutlet weak var songImage: UIImageView!
    
    //an ivisible button overlayed with the image
    //user change the image by click into the image
    //a invisible button is much easier to do than using
    //the data core way
    @IBAction func getImage(_ sender: UIButton) {
        selectPicture()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        let addBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addButton))
        self.navigationItem.rightBarButtonItem = addBtn
    }

    
    @objc func addButton() {
        //when the title field is empty, disable the add button
        if songTitleField.text! == "" {
            let alert = UIAlertController(title: "Empty Title", message: "Your song's title is missing", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        //when other fields are empty, change them to "Unknown"
        if songArtistField.text! == "" {
            songArtistField.text! = "Unknown"
        }
        if songYearField.text! == "" {
            songYearField.text! = "Unknown"
        }
        if songURLField.text! == "" {
            songURLField.text! = "Unknown"
        }
        //adding and saving the data from fields to the database
        let  songInfo = Song(context: PersistenceService.context)
        
        songInfo.title = songTitleField.text
        songInfo.artist = songArtistField.text
        songInfo.year = songYearField.text
        songInfo.url = songURLField.text
        songInfo.image = UIImagePNGRepresentation(songImage.image!) as Data?
        
        PersistenceService.saveContext()
        //return to master view
        _ = navigationController?.popToRootViewController(animated: true)
    }
    // some methods to select, edit and replace the default picture with one in the camera roll
    func selectPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
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
        songImage.image = newImage
        
        dismiss(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
