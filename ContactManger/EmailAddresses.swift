//
//  EmailAddresses.swift
//  ContactUCard
//
//  Created by Omar on 6/11/16.
//  Copyright © 2016 Omar. All rights reserved.
//

import Foundation
import CoreData


class EmailAddresses: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    @NSManaged var identifier: String?
    @NSManaged var label: String?
    @NSManaged var value: String?

}

/*
 //
 //  ContactsViewController.swift
 //  AddressBookContacts
 //
 //  Created by Ignacio Nieto Carvajal on 20/4/16.
 //  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
 //
 
 import UIKit
 import Contacts
 import CoreData
 import Sync
 let keys = [CNContactIdentifierKey,CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactOrganizationNameKey,
 CNContactDepartmentNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactBirthdayKey,CNContactNonGregorianBirthdayKey,CNContactNoteKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactThumbnailImageDataKey,CNContactImageDataAvailableKey,CNContactTypeKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey]
 @available(iOS 9.0, *)
 class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 // outlets
 @IBOutlet weak var tableView: UITableView!
 @IBOutlet weak var noContactsLabel: UILabel!
 
 // data
 var contactStore = CNContactStore()
 var contacts = [ContactEntry]()
 
 override func viewDidLoad() {
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
 
 
 
 }
 
 
 func saveName(cn: CNContact) {
 //1
 let appDelegate =
 UIApplication.sharedApplication().delegate as! AppDelegate
 
 let managedContext = appDelegate.dataStack.mainContext
 
 //2
 let entity =  NSEntityDescription.entityForName("Contact",
 inManagedObjectContext:managedContext)
 
 let person = NSManagedObject(entity: entity!,
 insertIntoManagedObjectContext: managedContext)
 
 //3
 person.setValue(cn.givenName, forKey: "givenName")
 person.setValue(cn.familyName, forKey: "familyName")
 person.setValue(cn.identifier ,forKey: "identifier")
 let archivedLocation = NSKeyedArchiver.archivedDataWithRootObject(cn)
 person.setValue(archivedLocation, forKey: "cn")
 //4
 do {
 try managedContext.save()
 //5
 //            people.append(person)
 } catch let error as NSError  {
 print("Could not save \(error), \(error.userInfo)")
 }
 }
 
 
 
 
 
 @objc func addressBookDidChange(notification: NSNotification){
 
 loadContact()
 print(notification.userInfo)
 }
 override func viewWillAppear(animated: Bool) {
 super.viewWillAppear(animated)
 
 print(self.keys)
 
 }
 let keys = [CNContactIdentifierKey ,CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactOrganizationNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactNoteKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey]
 
 func loadContact(){
 requestAccessToContacts { (success) in
 if success {
 
 dispatch_async(dispatch_get_main_queue(), {
 self.retrieveContacts({ (success, contacts) in
 self.tableView.hidden = !success
 self.noContactsLabel.hidden = success
 
 if success && contacts?.count > 0 {
 
 var saveDate:[[String : AnyObject]] = []
 var phoneNumbers:[[String:AnyObject]] = []
 var email:[[String:AnyObject]] = []
 for con in contacts! {
 
 //  self.saveName(con.cnContact!)
 // print(con.cnContact?.phoneNumbers)
 //  print(con.cnContact?.emailAddresses)
 //, CNContactBirthdayKey,CNContactNonGregorianBirthdayKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactThumbnailImageDataKey,CNContactImageDataAvailableKey,CNContactTypeKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey]
 var data =  con.cnContact?.dictionaryWithValuesForKeys(self.keys)
 
 let phones = data![CNContactPhoneNumbersKey] as? [CNLabeledValue]
 
 phoneNumbers =   phones!.map { object1  in
 let pDic =  object1.dictionaryWithValuesForKeys(["identifier","label","value"])
 return pDic
 }
 
 
 //                                for p in phones! {
 //
 //                                    var pDic =  p.dictionaryWithValuesForKeys(["identifier","label","value"])
 //                                    pDic["useridentifier"] = data!["identifier"]
 //
 //                                     phoneNumbers.append(pDic)
 //                                }
 //
 data![CNContactPhoneNumbersKey] = phoneNumbers
 
 var emails = data![CNContactEmailAddressesKey] as? [CNLabeledValue]
 
 for p in emails! {
 
 var pDic =  p.dictionaryWithValuesForKeys(["identifier","label","value"])
 email.append(pDic)
 }
 
 data![CNContactEmailAddressesKey] = emails
 
 saveDate.append(data!)
 
 }
 
 // print(saveDate)
 
 let deleget =    UIApplication.sharedApplication().delegate as? AppDelegate
 
 
 
 Sync.changes(saveDate , inEntityNamed: "Contacts", dataStack: deleget!.dataStack, completion: { error in
 // print(error)
 do{
 
 Sync.changes(phoneNumbers , inEntityNamed: "PhoneNumbers", dataStack: deleget!.dataStack, completion: { error in
 // print(error)
 })
 let request = NSFetchRequest(entityName: "Contacts")
 
 let items = (try!  deleget!.dataStack.mainContext.executeFetchRequest(request)) as? [Contacts]
 
 print("items")
 //  print(items)
 let mange = try deleget!.dataStack.mainContext.executeFetchRequest(request)
 print((mange[0] as? Contacts))
 //                                    print((mange as? NSManagedObject)?.valueForKey("namePrefix"))
 //                                 //   print((mange as? NSManagedObject)?.valueForKey("phoneNumbers"))
 //                                    print((mange as? NSManagedObject)?.valueForKey("emailAddresses"))
 
 //     print(mange)
 
 //                                    let phoneNumbers = NSKeyedUnarchiver.unarchiveObjectWithData(((mange as? NSManagedObject)?.valueForKey("phoneNumbers"))! as! NSData) as? NSArray
 //                                    let emails = NSKeyedUnarchiver.unarchiveObjectWithData(((mange as? NSManagedObject)?.valueForKey("emailAddresses"))! as! NSData) as? NSArray
 //
 //                                    print(phoneNumbers)
 //                                    let labelPhone = phoneNumbers?.firstObject   as? NSDictionary
 //                                    print( (labelPhone!["value"] as? CNPhoneNumber) )
 //                                    print( (labelPhone!["value"] as? CNPhoneNumber)!.stringValue )
 //
 //                                    let labelemail = emails?.firstObject   as? NSDictionary
 //                                    print( emails )
 //                                    print((emails![0] as?CNLabeledValue)?.value)
 //    print( labelemail!["value"] )
 
 
 
 }
 catch{
 
 }
 })
 
 
 self.contacts = contacts!
 
 
 self.tableView.reloadData()
 } else {
 self.noContactsLabel.text = "Unable to get contacts..."
 }
 })
 
 });
 
 }
 }
 
 }
 override func viewDidAppear(animated: Bool) {
 super.viewDidAppear(animated)
 loadContact()
 
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
 do {
 let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey,CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactOrganizationNameKey,
 CNContactDepartmentNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactBirthdayKey,CNContactNonGregorianBirthdayKey,CNContactNoteKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactThumbnailImageDataKey,CNContactImageDataAvailableKey,CNContactTypeKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey] )//[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactImageDataAvailableKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey])
 try contactStore.enumerateContactsWithFetchRequest(contactsFetchRequest, usingBlock: { (cnContact, error) in
 if let contact = ContactEntry(cnContact: cnContact) { contacts.append(contact) }
 })
 completion(success: true, contacts: contacts)
 } catch {
 completion(success: false, contacts: nil)
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
 dvc.type = .CNContact
 }
 }
 
 // UITableViewDataSource && Delegate methods
 func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return contacts.count ?? 0
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
 controller!.currentCNContact = self.contacts[indexPath.row].cnContact
 controller?.currentContacts = self.contacts[indexPath.row]
 controller!.type = .CNContact
 self.presentViewController(controller!, animated: true, completion: nil)
 
 print("UpdateContactViewController")
 }
 }
*/