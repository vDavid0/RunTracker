//
//  Coordinates+CoreDataProperties.swift
//  RunTracker
//
//  Created by Dávid Váradi on 2022. 12. 02..
//
//

import Foundation
import CoreData


extension Coordinates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coordinates> {
        return NSFetchRequest<Coordinates>(entityName: "Coordinates")
    }

    @NSManaged public var longitudes: [Double]?
    @NSManaged public var latitudes: [Double]?
    @NSManaged public var date: [Date]?
    @NSManaged public var training: Training?

}

extension Coordinates : Identifiable {

}
