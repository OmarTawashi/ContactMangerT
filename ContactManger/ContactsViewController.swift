//
//  ContactsViewController.swift
//  AddressBookContacts
//
//  Created by Ignacio Nieto Carvajal on 20/4/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import CoreData

let keys = [CNContactIdentifierKey,CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactOrganizationNameKey,
            CNContactDepartmentNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactBirthdayKey,CNContactNonGregorianBirthdayKey,CNContactNoteKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactThumbnailImageDataKey,CNContactImageDataAvailableKey,CNContactTypeKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey]
@available(iOS 9.0, *)
@objc public class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,CoreDateUpdataDeleget,UISearchBarDelegate{
    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContactsLabel: UILabel!
    @IBOutlet weak var saveContactsLabel: UILabel!
    // data
    var contactStore = CNContactStore()
    var contacts = [ContactEntry]()
    
    
    @IBOutlet weak var searchBar: UISearchBar!

    var searchActive : Bool = false
    var filterActive : Bool = false
    var filtered:[ContactEntry] = []

    

    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(ContactsViewController.addressBookDidChange(_:)),
            name: CNContactStoreDidChangeNotification,
            object: nil)
        tableView.hidden = true
        noContactsLabel.hidden = false
        noContactsLabel.text = "Retrieving contacts..."
        searchBar.placeholder = "Serach Name"
        //  searchBar.sizeToFit()
        searchBar.showsCancelButton = false // Hide the Search Bar's Cancel button
        
        // searchBar.backgroundColor = UIColor(netHex: 0x10192C)
        searchBar.delegate = self
        loadContact()
        
      
    }
    
    var CountNot:Bool = false
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("deinit \(self)")
    }
    
    var i = 0
    func doneInsert(index:Int){
        //print(self.i)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.i += 1
            
            self.saveContactsLabel.text = NSString(format: "Save %i from %i contact ", self.i,self.contacts.count) as String
        })
        
        
    }

    @objc func addressBookDidChange(notification: NSNotification){
        NSLog("%@", notification)
        if let sourceKey = notification.userInfo!["CNNotificationOriginationExternally"] as? Int  where sourceKey == 1 {

            print(CountNot)
             if   !CountNot {
                CountNot = true
                
                NSNotificationCenter.defaultCenter().removeObserver(self)
                loadAndSaveContact()
                loadContact()
            }
             else {
                CountNot = false

            }
        }
        
    }
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(self.keys)
        
    }
    let keys = [CNContactIdentifierKey ,CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactOrganizationNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactNoteKey,CNContactImageDataKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey]
    
    var saveDate:[[String : AnyObject]] = []
    var index = 0
    //,CNContactThumbnailImageDataKey
    func loadContact(){
        requestAccessToContacts { (success) in
            if success {
                
                let dataStak = ContactsThingy.sharedInstance.dataStack
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                    self.retrieveContacts({ (success, contacts) in
                        self.tableView.hidden = !success
                        
                        if success && contacts?.count > 0 {
                            
                            self.contacts.removeAll()
                            print(contacts?.count)
                            self.index = 0
                            self.contacts = contacts!
                            
                            
                            
                        } else {
                            self.noContactsLabel.text = "Unable to get contacts..."
                        }
                    })
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.noContactsLabel.hidden = success
                        
                        self.tableView.reloadData()
                        //                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                        //
                        //                            self.i = 0
                        //                            let sync = Sync(changes: self.saveDate, inEntityNamed: "Contacts", predicate: nil, dataStack: deleget!.dataStack)
                        //                            Sync.deleget = self
                        //                            Sync.changes(self.saveDate , inEntityNamed: "Contacts", dataStack: deleget!.dataStack, completion: { error in
                        //                                //   self.noContactsLabel.hidden = success
                        //
                        //                                print("Done'")
                        //                            })
                        //
                        //
                        //                        })
                        
                        
                    })
                })
                
                
                
            }
        }
        
    }
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func requestAccessToContacts(completion: (success: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized: completion(success: true) // authorized previously
        case .Denied, .NotDetermined: // needs to ask for authorization
            self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (accessGranted, error) -> Void in
                completion(success: accessGranted)
            })
        default: // not authorized.
            completion(success: false)
        }
    }
    
    func retrieveContacts(completion: (success: Bool, contacts: [ContactEntry]?) -> Void) {
        var contacts = [ContactEntry]()
        self.noContactsLabel.hidden = false
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey,CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactOrganizationNameKey,
                CNContactDepartmentNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactBirthdayKey,CNContactNonGregorianBirthdayKey,CNContactNoteKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactThumbnailImageDataKey,CNContactImageDataAvailableKey,CNContactTypeKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey] )//
            
            try contactStore.enumerateContactsWithFetchRequest(contactsFetchRequest, usingBlock: { (cnContact, error) in
                
                if let contact = ContactEntry(cnContact: cnContact) { contacts.append(contact) }
                
                let data = NSData()
                
                
            })
            completion(success: true, contacts: contacts)
        } catch {
            completion(success: false, contacts: nil)
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.contacts.removeAll()
        self.tableView.reloadData()
        NSNotificationCenter.defaultCenter().removeObserver(self)

        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createNewContact(sender: AnyObject) {
        self.performSegueWithIdentifier("CreateContact", sender: sender)
    }
    
    
    @IBAction func ShowCNContactPickerViewController(sender: AnyObject) {

        let controller =  CNContactPickerViewController()
     //   let con = CNContactViewController()
      self.presentViewController(controller, animated: true, completion: nil)
        
   //   let contact =   CNContactViewController()
    //    self.presentViewController(contact, animated: true, completion: nil)

 
    }

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? CreateContactViewController {
            dvc.type = .CNContact
        }
    }
    
    // UITableViewDataSource && Delegate methods
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive {
            
            return filtered.count ?? 0
        }
        else{
            return contacts.count ?? 0
            
        }
     }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactTableViewCell", forIndexPath: indexPath) as! ContactTableViewCell
        
        var entry:ContactEntry
        if searchActive {
            entry = filtered [indexPath.row]
            
        }
        else{
            entry = contacts [indexPath.row]
            
        }
        
         
        cell.configureWithContactEntry(entry)
        
        
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
   public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("UpdateContactViewControllerNav") as? UINavigationController
        (controller?.viewControllers[0] as? UpdateContactViewController)
         (controller?.viewControllers[0] as? UpdateContactViewController)!.currentCNContact = self.contacts[indexPath.row].cnContact
         (controller?.viewControllers[0] as? UpdateContactViewController)?.currentContacts = self.contacts[indexPath.row]
         (controller?.viewControllers[0] as? UpdateContactViewController)!.type = .CNContact
        self.presentViewController(controller!, animated: true, completion: nil)
        
        print("UpdateContactViewController")
    }
    ////////////////////////////////////////////////////
    func loadAndSaveContact(){
        self.saveContactsLabel.hidden = false
        
        requestAccessToContacts { (success) in
            if success {
                let dataStak = ContactsThingy.sharedInstance.dataStack
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                    self.retrieveAndSaveContacts({ (success, contacts) in
                        if success && contacts?.count > 0 {
                            
                            print(contacts?.count)
                            //                            NSNotificationCenter.defaultCenter().addObserver(
                            //                                self,
                            //                                selector: #selector(ContactsViewController.addressBookDidChange(_:)),
                            //                                name: CNContactStoreDidChangeNotification,
                            //                                object: nil)
                            //
                            //                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                            
                            self.i = 0
                            let sync = Sync(changes: contacts!, inEntityNamed: "Contacts", predicate: nil, dataStack: dataStak)
                            
                            Sync.deleget = self
                            Sync.changes(contacts! , inEntityNamed: "Contacts", dataStack:dataStak, completion: { error in
                                self.saveContactsLabel.hidden = success
                                print("Done'")
                                NSNotificationCenter.defaultCenter().addObserver(
                                    self,
                                    selector: #selector(ContactsViewController.addressBookDidChange(_:)),
                                    name: CNContactStoreDidChangeNotification,
                                    object: nil)
                            })
                            
                            //                            })
                        } else {
                            self.saveContactsLabel.text = "Unable to get contacts..."
                        }
                        
                        
                        
                    })
                })
                
            }
        }
        
    }
    
    func retrieveAndSaveContacts(completion: (success: Bool , contacts: [[String : AnyObject]]?) -> Void) {
        var saveDate:[[String : AnyObject]] = []
        
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey,CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactOrganizationNameKey,
                CNContactDepartmentNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactBirthdayKey,CNContactNonGregorianBirthdayKey,CNContactNoteKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactThumbnailImageDataKey,CNContactImageDataAvailableKey,CNContactTypeKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey] )//
            
            try contactStore.enumerateContactsWithFetchRequest(contactsFetchRequest, usingBlock: { (cnContact, error) in
                
                var phoneNumbers:[[String:AnyObject]] = []
                var email:[[String:AnyObject]] = []
                var potsal:[[String:AnyObject]] = []
                var urlAddresses:[[String:AnyObject]] = []
                var contactRelations:[[String:AnyObject]] = []
                var socialProfiles:[[String:AnyObject]] = []
                var instantMessageAddresses:[[String:AnyObject]] = []
                
                var data =   cnContact.dictionaryWithValuesForKeys(self.keys)
                
                let phones = data[CNContactPhoneNumbersKey] as? [CNLabeledValue]
                
                phoneNumbers =   phones!.map { object1  in
                    let pDic =  object1.dictionaryWithValuesForKeys(["identifier","label","value"])
                    return pDic
                }
                
                data[CNContactPhoneNumbersKey] = phoneNumbers
                
                let potsals = data[CNContactPostalAddressesKey] as? [CNLabeledValue]
                
                potsal =   potsals!.map { object1  in
                    let pDic =  object1.dictionaryWithValuesForKeys(["identifier","label","value"])
                    return pDic
                }
                data[CNContactPostalAddressesKey] = potsal
                
                let emails = data[CNContactEmailAddressesKey] as? [CNLabeledValue]
                
                email =   emails!.map { object1  in
                    let pDic =  object1.dictionaryWithValuesForKeys(["identifier","label","value"])
                    return pDic
                }
                
                data[CNContactEmailAddressesKey] = email
                
                let urlAddress = data[CNContactUrlAddressesKey] as? [CNLabeledValue]
                
                urlAddresses =   urlAddress!.map { object1  in
                    let pDic =  object1.dictionaryWithValuesForKeys(["identifier","label","value"])
                    return pDic
                }
                data[CNContactUrlAddressesKey] = urlAddresses
                
                
                let contactRelation = data[CNContactRelationsKey] as? [CNLabeledValue]
                
                contactRelations =   contactRelation!.map { object1  in
                    let pDic =  object1.dictionaryWithValuesForKeys(["identifier","label","value"])
                    return pDic
                }
                data[CNContactRelationsKey] = contactRelations
                
                let socialProfile = data[CNContactSocialProfilesKey] as? [CNLabeledValue]
                
                socialProfiles =   socialProfile!.map { object1  in
                    let pDic =  object1.dictionaryWithValuesForKeys(["identifier","label","value"])
                    return pDic
                }
                data[CNContactSocialProfilesKey] = socialProfiles
                
                let instantMessageAddresse = data[CNContactInstantMessageAddressesKey] as? [CNLabeledValue]
                
                instantMessageAddresses =   instantMessageAddresse!.map { object1  in
                    let pDic =  object1.dictionaryWithValuesForKeys(["identifier","label","value"])
                    return pDic
                }
                data[CNContactInstantMessageAddressesKey] = instantMessageAddresses
                
                
                saveDate.append(data)
                
                phoneNumbers.removeAll()
                email.removeAll()
                
            })
            completion(success: true, contacts: saveDate)
        } catch {
            completion(success: false, contacts: nil)
        }
    }
    
    
    
    public func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //  searchActive = true;
        
        print("Done")
        
    }
    
    public func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        print("Done")
    }
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    
        print(searchBar.text)
 
    }
    
    public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        
        print(searchText)
        filtered = self.contacts.filter({ (object:ContactEntry) -> Bool in
            
            if let givenName =  object.firstName ,let familyName =  object.lastName  {
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
        self.tableView.reloadData()
    }
    
    
    ////////////OK Done
    

}
