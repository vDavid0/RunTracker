//
//  Training+CoreDataProperties.swift
//  RunTracker
//
//  Created by Dávid Váradi on 2022. 12. 02..
//
//

import Foundation
import CoreData


extension Training {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Training> {
        return NSFetchRequest<Training>(entityName: "Training")
    }

    @NSManaged public var distance: Double
    @NSManaged public var steps: Int64
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var coordinates: Coordinates?

}

extension Training : Identifiable {

}
