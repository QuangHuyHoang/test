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
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var rowOnSelect:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        //spinner.startAnimating()

        //adding the button and changing some of the navigation bar's components
        self.title = "Tracks"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSong))
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //spinner.stopAnimating()
    }
    
    //the number of rows eqials the number of object
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    //fetching data and config the reusable  cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
 
//        cell.textLabel?.isUserInteractionEnabled = true
//        cell.imageView?.isUserInteractionEnabled = true
//
//        let tTap: UITapGestureRecognizer = UITapGestureRecognizer(
//            target: self, action: #selector(titleTapped))
//        let iTap: UITapGestureRecognizer = UITapGestureRecognizer(
//            target: self, action: #selector(imageTapped))
//
//        tTap.delaysTouchesBegan = true
//        iTap.delaysTouchesBegan = true
//
//        cell.textLabel?.addGestureRecognizer(tTap)
//        cell.imageView?.addGestureRecognizer(iTap)
//
//        tTap.delegate = self
//        iTap.delegate = self
        
        return cell
    }
    
    //adding an object
    @objc func addSong() {
    //if a cell is in editing mode, disable the add button
        if table.isEditing {
            return
        }
        //go to the detail view to continnue adding info
        self.performSegue(withIdentifier: "detail", sender: nil)
    }
    //making a delete button and add its function
    //doing it this way allows me to change the button color
    //edit mode is removed due to the lack of overall aesthetic
    //swiping and taping delete is just as fast anyway
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            PersistenceService.context.delete(self.fetchedResultsController.object(at: indexPath))
            PersistenceService.saveContext()
        }
        delete.backgroundColor = UIColor.darkGray
        return [delete]
    }
    //when a row is tapped, go to the edit view
    //bringing the object along to allow editing
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fetchedResultsController.object(at: indexPath)
        self.performSegue(withIdentifier: "edit", sender: nil)
        //the row won't be hillighted forever after you choose it once
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //prepare for the taking of info from master view to edit view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            if let indexPath = table.indexPathForSelectedRow {
                let controller = segue.destination as! EditViewController
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                let object = fetchedResultsController.object(at: indexPath)
                controller.songInfo = object
            }
        }
    }
    //config the content of a cell
    func configureCell(_ cell: UITableViewCell, withEvent event: Song) {
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = event.artist
        if let data = event.image {
            cell.imageView?.image = UIImage(data: data)
        }
    }
    
    //generic fetching methods, taken from a dummy project's masterview
    var fetchedResultsController: NSFetchedResultsController<Song> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Song> = Song.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 50
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceService.context, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Song>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            table.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            table.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
                table.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            table.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(table.cellForRow(at: indexPath!)!, withEvent: anObject as! Song)
        case .move:
            configureCell(table.cellForRow(at: indexPath!)!, withEvent: anObject as! Song)
            table.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table.endUpdates()
    }
}


