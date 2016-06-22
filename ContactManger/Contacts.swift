//
//  Contacts.swift
//  ContactUCard
//
//  Created by Omar on 6/11/16.
//  Copyright © 2016 Omar. All rights reserved.
//

import Foundation
import CoreData

@objc(Contacts)
class Contacts: NSManagedObject {
 
    @NSManaged var identifier: String?
    @NSManaged var namePrefix: String?
    @NSManaged var givenName: String?
    @NSManaged var middleName: String?
    @NSManaged var familyName: String?
    @NSManaged var previousFamilyName: String?
    @NSManaged var nameSuffix: String?
    @NSManaged var nickname: String?
    @NSManaged var phoneticMiddleName: String?
    @NSManaged var phoneticGivenName: String?
    @NSManaged var departmentName: String?
    @NSManaged var organizationName: String?
    @NSManaged var jobTitle: String?
    @NSManaged var note: String?
    @NSManaged var imageData: NSData?
    @NSManaged var thumbnailImageData: NSData?
    @NSManaged var phoneticFamilyName: String?
    @NSManaged var phoneNumbers: NSData?
    @NSManaged var emailAddresses: NSData?
    @NSManaged var postalAddresses: NSData?
}
