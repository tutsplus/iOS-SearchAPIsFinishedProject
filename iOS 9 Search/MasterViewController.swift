//
//  MasterViewController.swift
//  iOS 9 Search
//
//  Created by Davis Allie on 9/07/2015.
//  Copyright © 2015 Davis Allie. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

struct Show {
    var name: String
    var genre: String
    var time: NSDate
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    var objects = [
        Show(name: "Into the Wild", genre: "Documentary", time: NSDate()),
        Show(name: "24/7", genre: "Drama", time: NSDate(timeIntervalSinceNow: 3600 * 1.5)),
        Show(name: "How to become rich", genre: "Talk Show", time: NSDate(timeIntervalSinceNow: 3600 * 2.5)),
        Show(name: "NET Daily", genre: "News", time: NSDate(timeIntervalSinceNow: 3600 * 4))
    ]
    var showToRestore: Show?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        var searchableItems: [CSSearchableItem] = []
        for show in objects {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
            
            attributeSet.title = show.name
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = .ShortStyle
            
            attributeSet.contentDescription = show.genre + "\n" + dateFormatter.stringFromDate(show.time)
            
            var keywords = show.name.componentsSeparatedByString(" ")
            keywords.append(show.genre)
            attributeSet.keywords = keywords
            
            let item = CSSearchableItem(uniqueIdentifier: show.name, domainIdentifier: "tv-shows", attributeSet: attributeSet)
            searchableItems.append(item)
        }
        
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems) { (error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                // Items were indexed successfully
            }
        }
        
        CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithDomainIdentifiers(["tv-shows"]) { (error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                // Items were deleted successfully
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as Show
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
            else if let show = showToRestore {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = show
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as Show
        cell.textLabel!.text = object.name
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    override func restoreUserActivityState(activity: NSUserActivity) {
        
        if let name = activity.userInfo?["name"] as? String,
            let genre = activity.userInfo?["genre"] as? String,
            let time = activity.userInfo?["time"] as? NSDate {
            let show = Show(name: name, genre: genre, time: time)
            self.showToRestore = show
            
            self.performSegueWithIdentifier("showDetail", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Error retrieving information from userInfo:\n\(activity.userInfo)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

