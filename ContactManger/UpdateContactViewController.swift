//
//  UpdateContactViewController.swift
//  AddressBookContacts
//
//  Created by Omar on 6/7/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import AddressBook
import ContactsUI
import Contacts

@available(iOS 9.0, *)
class UpdateContactViewController: UIViewController  , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var emailAddressTextfield: UITextField!
    @IBOutlet weak var phoneNumberTextfield: UITextField!
    
    
    var currentABRecord:ABRecord?
    var currentCNContact:CNContact?
    var currentContacts:ContactEntry?
     // data
    var type: ContactType?
    var contactImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if type == .AddressBookContact {
            
            self.firstNameTextfield.text = currentContacts?.firstName
            self.lastNameTextfield.text = currentContacts?.lastName
            self.emailAddressTextfield.text = currentContacts?.email
            self.phoneNumberTextfield.text = currentContacts?.phone
            self.contactImageView.image = currentContacts?.image
        } else if type == .CNContact {
            
            self.firstNameTextfield.text = currentContacts?.firstName
            self.lastNameTextfield.text = currentContacts?.lastName
            self.emailAddressTextfield.text = currentContacts?.email
            self.phoneNumberTextfield.text = currentContacts?.phone
            self.contactImageView.image = currentContacts?.image
        }
    
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        contactImageView.layer.cornerRadius = contactImageView.frame.size.width / 2.0
        contactImageView.layer.masksToBounds = true
    }
    
    
    // MARK: - Button actions
    @IBAction func createContact(sender: AnyObject) {
        // check if we can create a contact.
        if let firstName = firstNameTextfield.text where firstName.characters.count > 0,
            let lastName = lastNameTextfield.text where lastName.characters.count > 0 {
            let email = emailAddressTextfield.text
            let phone = phoneNumberTextfield.text
            
            if type == .AddressBookContact {
                createAddressBookContactWithFirstName(firstName, lastName: lastName, email: email, phone: phone, image: contactImage)
            }else if type == .CNContact {
                if #available(iOS 9, *) {
                    createCNContactWithFirstName(firstName, lastName: lastName, email: email, phone: phone, image: contactImage)
                } else {
                    self.showAlertMessage("Sorry, you can only use the Contacts framework from iOS 9.")
                }
                
            }
        } else {
            self.showAlertMessage("Please, insert at least a first and last name for the contact.")
        }
    }
    
    @IBAction func changeContactImage(sender: AnyObject) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.contactImage = info[UIImagePickerControllerEditedImage] as? UIImage
        self.contactImageView.image = self.contactImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @available(iOS 9.0, *)
    func createCNContactWithFirstName(firstName: String, lastName: String, email: String?, phone: String?, image: UIImage?) {
        // create contact with mandatory values: first and last name
      
        
        let newContact = currentContacts?.cnContact!.mutableCopy() as! CNMutableContact
        
     
        
        // email
        if email != nil {
            let contactEmail = CNLabeledValue(label: CNLabelHome, value: email!)
            newContact.emailAddresses = [contactEmail]
        }
        // phone
        if phone != nil {
            let contactPhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: phone!))
            newContact.phoneNumbers = [contactPhone]
        }
        
        // image
        if image != nil {
            newContact.imageData = UIImageJPEGRepresentation(image!, 0.9)
        }
        // email
        newContact.givenName = firstName
        newContact.familyName = lastName
         do {
            let newContactRequest = CNSaveRequest()
            
            newContactRequest.updateContact(  newContact )
            try CNContactStore().executeSaveRequest(newContactRequest)
            
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        } catch {
            self.showAlertMessage("I was unable to create the new contact. An error occurred.")
        }
    }

    // create contact
    func createAddressBookContactWithFirstName(firstName: String, lastName: String, email: String?, phone: String?, image: UIImage?) {
        // first check permissions.
        let abAuthStatus = ABAddressBookGetAuthorizationStatus()
        if abAuthStatus == .Denied || abAuthStatus == .Restricted {
            self.showAlertMessage("Sorry, you are not authorize to access the contacts.")
            return
        }
        
        
        // get addressbook reference.
        let addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

           // now let's create the contact.
        let newContact: ABRecordRef = self.currentABRecord!
        
        // first name
        if !ABRecordSetValue(newContact, kABPersonFirstNameProperty, firstName as CFTypeRef, nil) {
            self.showAlertMessage("Error setting first name for the new contact")
            return
        }
        // last name
        if !ABRecordSetValue(newContact, kABPersonLastNameProperty, lastName as CFTypeRef, nil) {
            self.showAlertMessage("Error setting last name for the new contact")
            return
        }
        // email
        if email != nil {
            let emails: ABMutableMultiValue =
                ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
            ABMultiValueAddValueAndLabel(emails, email!, kABHomeLabel, nil)
            if !ABRecordSetValue(newContact, kABPersonEmailProperty, emails, nil) {
                self.showAlertMessage("Error setting email for the new contact")
                return
            }
            
        }
        
        // phone number
        if phone != nil {
            let phoneNumbers: ABMutableMultiValue =
                ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
            ABMultiValueAddValueAndLabel(phoneNumbers, phone, kABPersonPhoneMainLabel, nil)
            if !ABRecordSetValue(newContact, kABPersonPhoneProperty, phoneNumbers, nil) {
                self.showAlertMessage("Error setting phone number for the new contact")
                return
            }
        }
        
        // image
        if image != nil {
            let imageData = UIImageJPEGRepresentation(image!, 0.9)
            if !ABPersonSetImageData(newContact, imageData, nil) {
                self.showAlertMessage("Error setting image for the new contact")
                return
            }
        }
        
        // finally, store person and save addressbook
        var errorSavingContact = false
        if ABAddressBookAddRecord(addressBookRef, newContact, nil) { // stored. Now save addressbook.
            if ABAddressBookHasUnsavedChanges(addressBookRef){
                if !ABAddressBookSave(addressBookRef, nil) {
                    errorSavingContact = true
                }
            }
        }
        
        if errorSavingContact { self.showAlertMessage("There was an error storing your new contact. Please try again.") }
        else { self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil) }
    }
    
    @IBAction func deleteContact(sender: UIButton) {
        
        if type == .AddressBookContact {
            let abAuthStatus = ABAddressBookGetAuthorizationStatus()
            if abAuthStatus == .Denied || abAuthStatus == .Restricted {
                self.showAlertMessage("Sorry, you are not authorize to access the contacts.")
                return
            }
            
//            // get addressbook reference.
//            let addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
//            
//            var errorSavingContact = false
//            print(currentContacts?.addressBookEntry)
//            print(addressBookRef)
// 
//            
////            var error: CFErrorRef? = nil
//            var addressBook: ABAddressBookRef = ABAddressBookCreate().takeRetainedValue()
//            var delete: ABRecordRef = (self.currentContacts?.addressBookEntry)!
//      
//            
//
//            
//             var error: Unmanaged<CFErrorRef>? = nil
//            var success = ABAddressBookRemoveRecord(addressBook, self.currentContacts?.addressBookEntry, &error)
////            var removed: Bool = ABAddressBookRemoveRecord(addressBook, delete, error!)
//
//                
//            
//            if errorSavingContact { self.showAlertMessage("There was an error storing your new contact. Please try again.") }
//            else { self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil) }
//
            
         }else if type == .CNContact {
            if #available(iOS 9, *) {
                do {
                    let newContactRequest = CNSaveRequest()
                    let newContact = currentContacts?.cnContact!.mutableCopy() as! CNMutableContact
                     newContactRequest.deleteContact(  newContact )
                    try CNContactStore().executeSaveRequest(newContactRequest)
                    
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                } catch {
                    self.showAlertMessage("I was unable to create the new contact. An error occurred.")
                }

            
            } else {
                self.showAlertMessage("Sorry, you can only use the Contacts framework from iOS 9.")
            }
            
        }

    }
    var contactStore = CNContactStore()

    @IBAction func UpdateViewControllerShow(sender: AnyObject) {
        
        if !currentCNContact!.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                currentCNContact = try self.contactStore.unifiedContactWithIdentifier(currentCNContact!.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            }
            catch { }
        }
        let viewControllerforContact = CNContactViewController(forContact: currentCNContact!)
        let contact =   CNContactViewController(forContact: self.currentCNContact!)
        self.navigationController?.pushViewController(contact, animated: true)
    }

}
