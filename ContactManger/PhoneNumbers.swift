//
//  PhoneNumbers.swift
//  ContactUCard
//
//  Created by Omar on 6/11/16.
//  Copyright © 2016 Omar. All rights reserved.
//

import Foundation
import CoreData

@objc(PhoneNumbers)
class PhoneNumbers: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    @NSManaged var identifier: String?
    @NSManaged var label: String?
    @NSManaged var value: NSNumber?

}
