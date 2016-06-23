//
//  ContactsThingy.swift
//  AddressBookContacts
//
//  Created by Omar on 6/9/16.
//  Copyright © 2016 Ignacio Nieto Carvajal. All rights reserved.
//
import Contacts

@available(iOS 9.0, *)
class ContactsThingy {
    
    var observer: NSObjectProtocol?
    let contacts = CNContactStore()
    
    static let sharedInstance = ContactsThingy()
    lazy var dataStack: DATAStack = DATAStack(modelName: "Model")

    init(){
        
        var modelBundle = NSBundle(identifier: "unitone.ContactManger")
        
        print(modelBundle)
        dataStack = DATAStack(modelName: "Model", bundle: modelBundle!, storeType:  .SQLite)
    }
    
    
    
    func contactStoreDidChange(notification: NSNotification) {
        NSLog("%@", notification)
    }
    
    func registerObserver() {
        let center = NSNotificationCenter.defaultCenter()
        observer = center.addObserverForName(CNContactStoreDidChangeNotification, object: nil, queue: NSOperationQueue.currentQueue(), usingBlock: contactStoreDidChange)
    }
    
    func unregisterObserver() {
        guard let myObserver = observer else { return }
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(myObserver)
    }
    
    func changeContacts(request: CNSaveRequest) {
        unregisterObserver() // stop watching for changes
        defer { registerObserver() } // start watching again after this change even if error
        try! contacts.executeSaveRequest(request)
    }
}