//
//  ContactSync.swift
//  ContactManger
//
//  Created by Omar Al tawashi on 6/25/16.
//  Copyright © 2016 Unit one. All rights reserved.
//

import Foundation
import Contacts

class  ContactSync:CoreDateUpdataDeleget{
    
    var i = 0
    func doneInsert(index:Int){
         
        dispatch_async(dispatch_get_main_queue(), {
            self.i += 1
            
         })
     }
    
    ////////////////////////////////////////////////////
    func loadAndSaveContact(){
        
        ContactsThingy.sharedInstance.requestAccessToContacts({ (success) in
            if success {
                let dataStak = ContactsThingy.sharedInstance.dataStack
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
                    self.retrieveAndSaveContacts({ (success, contacts) in
                        if success && contacts?.count > 0 {
                            
                             self.i = 0
                            let sync = Sync(changes: contacts!, inEntityNamed: "Contacts", predicate: nil, dataStack: dataStak)
                            
                            Sync.deleget = self
                            Sync.changes(contacts! , inEntityNamed: "Contacts", dataStack:dataStak, completion: { error in

                                print("Done'")
                                NSNotificationCenter.defaultCenter().addObserver(
                                    self,
                                    selector: #selector(ContactsViewController.addressBookDidChange(_:)),
                                    name: CNContactStoreDidChangeNotification,
                                    object: nil)
                            })
                            
                            //                            })
                        } else {

                        }
                        
                        
                        
                    })
                })
                
            }
        })
        
    }
    
    func retrieveAndSaveContacts(completion: (success: Bool , contacts: [[String : AnyObject]]?) -> Void) {
        var saveDate:[[String : AnyObject]] = []
        
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey,CNContactNamePrefixKey,CNContactGivenNameKey,CNContactMiddleNameKey,CNContactFamilyNameKey,CNContactPreviousFamilyNameKey,CNContactNameSuffixKey,CNContactNicknameKey,CNContactPhoneticGivenNameKey,CNContactPhoneticMiddleNameKey,CNContactPhoneticFamilyNameKey,CNContactOrganizationNameKey,
                CNContactDepartmentNameKey,CNContactDepartmentNameKey,CNContactJobTitleKey,CNContactBirthdayKey,CNContactNonGregorianBirthdayKey,CNContactNoteKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactThumbnailImageDataKey,CNContactImageDataAvailableKey,CNContactTypeKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactPostalAddressesKey,CNContactDatesKey,CNContactUrlAddressesKey,CNContactRelationsKey,CNContactSocialProfilesKey,CNContactInstantMessageAddressesKey] )//
            
            try ContactsThingy.sharedInstance.contactStore.enumerateContactsWithFetchRequest(contactsFetchRequest, usingBlock: { (cnContact, error) in
                
                var phoneNumbers:[[String:AnyObject]] = []
                var email:[[String:AnyObject]] = []
                var potsal:[[String:AnyObject]] = []
                var urlAddresses:[[String:AnyObject]] = []
                var contactRelations:[[String:AnyObject]] = []
                var socialProfiles:[[String:AnyObject]] = []
                var instantMessageAddresses:[[String:AnyObject]] = []
                
                var data =   cnContact.dictionaryWithValuesForKeys(CNContactkeys)
                
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
    
  
}