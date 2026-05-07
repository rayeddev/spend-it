//
//  PlanGroupEntity+CoreDataProperties.swift
//  spenditapp
//
//  Created by Group Planning Feature
//

import Foundation
internal import CoreData

extension PlanGroupEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanGroupEntity> {
        return NSFetchRequest<PlanGroupEntity>(entityName: "PlanGroupEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var sequenceOrder: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var parentPlan: PlanEntity?
    @NSManaged public var childPlan: PlanEntity?
}

extension PlanGroupEntity: Identifiable {}
