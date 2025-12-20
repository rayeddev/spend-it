//
//  PlanItemEntity+CoreDataProperties.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import Foundation
internal import CoreData

extension PlanItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanItemEntity> {
        return NSFetchRequest<PlanItemEntity>(entityName: "PlanItemEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var type: String?
    @NSManaged public var isFrozen: Bool
    @NSManaged public var sortOrder: Int16
    @NSManaged public var icon: String?
    @NSManaged public var color: String?
    @NSManaged public var notes: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var plan: PlanEntity?
}

extension PlanItemEntity: Identifiable {}
