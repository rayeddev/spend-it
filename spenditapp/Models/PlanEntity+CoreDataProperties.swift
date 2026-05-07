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
    @NSManaged public var isGroupParent: Bool
    @NSManaged public var groupType: String?
    @NSManaged public var items: NSSet?
    @NSManaged public var childGroups: NSSet?
    @NSManaged public var parentGroups: NSSet?
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

// MARK: Generated accessors for childGroups
extension PlanEntity {

    @objc(addChildGroupsObject:)
    @NSManaged public func addToChildGroups(_ value: PlanGroupEntity)

    @objc(removeChildGroupsObject:)
    @NSManaged public func removeFromChildGroups(_ value: PlanGroupEntity)

    @objc(addChildGroups:)
    @NSManaged public func addToChildGroups(_ values: NSSet)

    @objc(removeChildGroups:)
    @NSManaged public func removeFromChildGroups(_ values: NSSet)
}

// MARK: Generated accessors for parentGroups
extension PlanEntity {

    @objc(addParentGroupsObject:)
    @NSManaged public func addToParentGroups(_ value: PlanGroupEntity)

    @objc(removeParentGroupsObject:)
    @NSManaged public func removeFromParentGroups(_ value: PlanGroupEntity)

    @objc(addParentGroups:)
    @NSManaged public func addToParentGroups(_ values: NSSet)

    @objc(removeParentGroups:)
    @NSManaged public func removeFromParentGroups(_ values: NSSet)
}

extension PlanEntity: Identifiable {}
