//
//  SerachViewController.swift
//  GoAppMedia
//
//  Created by Omar Al tawashi on 3/27/16.
//  Copyright ©  2016 unitone itc. All rights reserved.
//

import UIKit
import Contacts
import CoreData

//UISearchResultsUpdating
@available(iOS 9.0, *)
class SerachViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate ,UITextFieldDelegate{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblSearchResults: UITableView!
    var searchActive : Bool = false
    var filterActive : Bool = false
    var filtered:[Contacts] = []
    
    var Pfusers:[NSManagedObject]! = []
    var contact = [Contacts]()
    
    
    @IBAction func DismisSAction(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bundle = NSBundle(forClass: ContactsViewController.self)

        tblSearchResults.registerNib(UINib(nibName: "SearchResultCell", bundle: bundle), forCellReuseIdentifier: "idSearchResultCell")
        
        searchBar.placeholder = "Serach Name"
        //  searchBar.sizeToFit()
        searchBar.showsCancelButton = false // Hide the Search Bar's Cancel button
        
        // searchBar.backgroundColor = UIColor(netHex: 0x10192C)
        searchBar.delegate = self
        //  searchDisplayController?.displaysSearchBarInNavigationBar = true
        
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        textFieldInsideSearchBar?.backgroundColor = UIColor.grayColor()
        
        
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.tableHeaderView = UIView()
        Pfusers = [NSManagedObject]()
        
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadContactFromCoredata()
    }
    
    func loadContactFromCoredata(){
        //1
          let dataStak = ContactsThingy.sharedInstance.dataStack

        let managedContext = dataStak.mainContext
        
       //managedObjectContext
        
        
        
        
   
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Contacts")
        
        //3
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)  as? [Contacts]
            self.contact = results!
            self.tblSearchResults.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("didReceiveMemoryWarning")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {

            return filtered.count
        }
        else{
            return contact.count
            
        }

    }
    
    
    
    func tableView(tableView: UITableView,
                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
    }
 
 

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idSearchResultCell", forIndexPath: indexPath) as! SearchResultCell
        
        var lc:Contacts
        if searchActive {
              lc = filtered [indexPath.row]
            
        }
        else{
              lc = contact [indexPath.row]
            
        }
      
      //  let lc = NSKeyedUnarchiver.unarchiveObjectWithData(co.valueForKey("cn") as! NSData) as! CNContact
    
        print("identifier")

        print(lc.identifier)
         cell.name_Label.text = lc.givenName//co.valueForKey("givenName") as? String
        cell.FirsNameLabel.text = lc.givenName//co.valueForKey("givenName") as? String
        cell.LastNameLabel.text = lc.familyName//co.valueForKey("familyName") as? String
        cell.LastNameLabel.text = lc.familyName//co.valueForKey("familyName") as? String
        
        if let imageData = lc.imageData  {
            cell.avatar_Image.image = UIImage(data: imageData)

        }
        else{
          cell.avatar_Image.image = UIImage(named: "defaultUser")

        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //////
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
      //  searchActive = true;
        

        
        print("Done")
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        print("Done")
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        
        
        print(searchBar.text)
        
        
        //    let param :[ String:AnyObject ] = ["cityID":(selectedCity?.objectId)! ,"ServiceID":self.selectedService.objectId!]
        
        // print(param)
        //        ParseManager.loadUserPerLocation(param, completion: {
        //            objects in
        //            self.Pfusers = objects
        //            self.tblSearchResults.reloadData()
        //
        //            }, Failure: {
        //                 errorType in
        //
        //        })
        
        //        loadUserResult2("", userCategory: selectedService, location: selectedCity)
        
        //        ParseManager.loadUsers(searchBar.text!,userCategory: self.CategoryTextView.text!,location: self.LocationTextView.text!,user: PFUser.currentUser()!, completion: {
        //            objects in
        //            self.Pfusers = objects
        //            self.tblSearchResults.reloadData()
        //
        //            }, Failure: {
        //                errortype in
        //
        //        })
        //
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        
 
        print(searchText)
        filtered = self.contact.filter({ (object:Contacts) -> Bool in
            
            if let givenName =  object.givenName ,let familyName =  object.familyName  {
                let tmp: NSString = givenName + familyName
                let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return range.location != NSNotFound
            }
            return false
            
        })
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tblSearchResults.reloadData()
    }
    
    
    ////////////OK Done
    
    
    
}