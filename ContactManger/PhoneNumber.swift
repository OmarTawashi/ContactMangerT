import Foundation
import CoreData

@objc(PhoneNumber)
class PhoneNumber: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var id: String
    @NSManaged var username: String
    @NSManaged var data: NSSet
    
}
