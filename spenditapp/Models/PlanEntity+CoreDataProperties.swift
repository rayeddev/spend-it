//
//  PlanEntity+CoreDataProperties.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import Foundation
internal import CoreData

extension PlanEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlanEntity> {
        return NSFetchRequest<PlanEntity>(entityName: "PlanEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var isRecurring: Bool
    @NSManaged public var recurrenceType: String?
    @NSManaged public var status: String?
    @NSManaged public var parentPlanId: UUID?
    @NSManaged public var currencyCode: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var items: NSSet?
}

// MARK: Generated accessors for items
extension PlanEntity {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: PlanItemEntity)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: PlanItemEntity)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}

extension PlanEntity: Identifiable {}
