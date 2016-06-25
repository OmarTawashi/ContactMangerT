//
//  ContactsThingy.swift
 //
//  Created by Omar Al tawashi on 6/9/16.
//  Copyright © 2016 Unit one. All rights reserved.
//
import Contacts
let CNContactkeys = [CNContactIdentifierKey ,CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactOrganizationNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactNoteKey,CNContactImageDataKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey]


@available(iOS 9.0, *)
class ContactsThingy {
    var CountNot:Bool = false

    var observer: NSObjectProtocol?
    let  contactStore = CNContactStore()
    
    static let sharedInstance = ContactsThingy()
      let cnSync = ContactSync()
    lazy var dataStack: DATAStack = DATAStack(modelName: "Model")

    init(){
        
        registerObserver()
         let podBundle = NSBundle(forClass: ContactsThingy.self)
          dataStack = DATAStack(modelName: "Model", bundle: podBundle, storeType:  .SQLite)
    }
    
    @objc func addressBookDidChange(notification: NSNotification){
        NSLog("%@", notification)
        if let sourceKey = notification.userInfo!["CNNotificationOriginationExternally"] as? Int  where sourceKey == 1 {
         
            if   !CountNot {
                CountNot = true
                 NSNotificationCenter.defaultCenter().removeObserver(self)
                cnSync.loadAndSaveContact()
             }
            else {
                CountNot = false
                
            }

        }
        
    }
    
//    func contactStoreDidChange(notification: NSNotification) {
//        NSLog("%@", notification)
//    }
    
    func registerObserver() {
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(ContactsViewController.addressBookDidChange(_:)),
            name: CNContactStoreDidChangeNotification,
            object: nil)

//        let center = NSNotificationCenter.defaultCenter()
//        observer = center.addObserverForName(CNContactStoreDidChangeNotification, object: nil, queue: NSOperationQueue.currentQueue(), usingBlock: contactStoreDidChange)
    }
    
    func unregisterObserver() {
        guard let myObserver = observer else { return }
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(myObserver)
    }
    
    func changeContacts(request: CNSaveRequest) {
        unregisterObserver() // stop watching for changes
        defer { registerObserver() } // start watching again after this change even if error
        try! contactStore.executeSaveRequest(request)
    }
    
    
    func requestAccessToContacts(completion: (success: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized: completion(success: true) // authorized previously
        case .Denied, .NotDetermined: // needs to ask for authorization
            ContactsThingy.sharedInstance.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (accessGranted, error) -> Void in
                completion(success: accessGranted)
            })
        default: // not authorized.
            completion(success: false)
        }
    }
}