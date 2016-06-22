//
//  AddressBookViewController.swift
//  AddressBookContacts
//
//  Created by Ignacio Nieto Carvajal on 20/4/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import AddressBook
import  CoreData


@available(iOS 9.0, *)
class AddressBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContactsLabel: UILabel!
    // data
    var contacts = [ContactEntry]()
    var addressBookRef:ABAddressBook?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(keys)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        
        if let addressBook = ABAddressBookCreateWithOptions(nil, nil) {
            
            
            
            let ref = addressBook.takeRetainedValue()
            
             
            ABAddressBookRegisterExternalChangeCallback(ref,
                                                        {ee ,rr,ll in
                                                  
                                                            print("asas")
                                                             },nil)
            //            let callback: @convention(c) (addressBookRef: ABAddressBookRef!, info: CFDictionaryRef!, context: UnsafeMutablePointer<Void>) -> Void = {
            //                (addressBookRef, info, context) in
            //
            //                // do the things you want
            //
            //            }
            //
            //            let addressBookChangeCallback = unsafeBitCast(callback, ABExternalChangeCallback.self)
            //
            //            ABAddressBookRegisterExternalChangeCallback(ref, addressBookChangeCallback, nil)
            //
        }
        
    }
    
    func MyAddressBookExternalChangeCallback(addressBookRef:ABAddressBookRef,info:CFDictionaryRef,context:(Void)) {
        
        print("sdSD'sd'")
    }
    
    
    
    
    
    func addressBookChangeCallback(ntificationaddressbook:ABAddressBookRef,info:CFDictionaryRef){
        
        print(info)
    }
    
    
        override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // initial appearance
        tableView.hidden = true
        noContactsLabel.hidden = false
        noContactsLabel.text = "Retrieving contacts..."
        
        retrieveAddressBookContacts { (success, contacts) in
            self.tableView.hidden = !success
            self.noContactsLabel.hidden = success
            if success && contacts?.count > 0 {
                self.contacts = contacts!
                
                
                
                
                self.tableView.reloadData()
            } else {
                self.noContactsLabel.text = "Unable to get contacts..."
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createNewContact(sender: AnyObject) {
        self.performSegueWithIdentifier("CreateContact", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? CreateContactViewController {
            dvc.type = .AddressBookContact
        }
    }
    
    // AddressBook methods
    func retrieveAddressBookContacts(completion: (success: Bool, contacts: [ContactEntry]?) -> Void) {
        let abAuthStatus = ABAddressBookGetAuthorizationStatus()
        if abAuthStatus == .Denied || abAuthStatus == .Restricted {
            completion(success: false, contacts: nil)
            return
        }
        
        addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    self.showAlertMessage("Sorry, you have no permission for accessing the address book contacts.")
                } else {
                    var contacts = [ContactEntry]()
                    let abPeople = ABAddressBookCopyArrayOfAllPeople(self.addressBookRef).takeRetainedValue() as Array
                    for abPerson in abPeople {
                        if let contact = ContactEntry(addressBookEntry: abPerson) { contacts.append(contact) }
                    }
                    completion(success: true, contacts: contacts)
                }
            }
        }
    }
    
    // UITableViewDataSource && Delegate methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactTableViewCell", forIndexPath: indexPath) as! ContactTableViewCell
        let entry = contacts[indexPath.row]
        cell.configureWithContactEntry(entry)
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("UpdateContactViewController") as? UpdateContactViewController
        controller!.currentABRecord = self.contacts[indexPath.row].addressBookEntry
        controller?.currentContacts = self.contacts[indexPath.row]
        controller!.type = .AddressBookContact
        self.presentViewController(controller!, animated: true, completion: nil)
        
        print("UpdateContactViewController")
    }
}
