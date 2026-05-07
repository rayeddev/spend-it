//
//  PlanGroupEntity+CoreDataClass.swift
//  spenditapp
//
//  Created by Group Planning Feature
//

import Foundation
internal import CoreData

@objc(PlanGroupEntity)
class PlanGroupEntity: NSManagedObject {

    // MARK: - Convenience Methods

    /// Creates a new group relationship between parent and child plans
    static func create(
        in context: NSManagedObjectContext,
        parentPlan: PlanEntity,
        childPlan: PlanEntity,
        sequenceOrder: Int16
    ) -> PlanGroupEntity {
        let group = PlanGroupEntity(context: context)
        group.id = UUID()
        group.parentPlan = parentPlan
        group.childPlan = childPlan
        group.sequenceOrder = sequenceOrder
        group.createdAt = Date()
        group.updatedAt = Date()
        return group
    }

    /// Get all child plans for a parent, sorted by sequence order
    static func getChildPlans(
        for parentPlan: PlanEntity,
        in context: NSManagedObjectContext
    ) -> [PlanEntity] {
        let fetchRequest: NSFetchRequest<PlanGroupEntity> = PlanGroupEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentPlan == %@", parentPlan)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sequenceOrder", ascending: true)]

        do {
            let groups = try context.fetch(fetchRequest)
            return groups.compactMap { $0.childPlan }
        } catch {
            print("Error fetching child plans: \(error)")
            return []
        }
    }

    /// Get parent plan for a child
    static func getParentPlan(
        for childPlan: PlanEntity,
        in context: NSManagedObjectContext
    ) -> PlanEntity? {
        let fetchRequest: NSFetchRequest<PlanGroupEntity> = PlanGroupEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "childPlan == %@", childPlan)
        fetchRequest.fetchLimit = 1

        do {
            let groups = try context.fetch(fetchRequest)
            return groups.first?.parentPlan
        } catch {
            print("Error fetching parent plan: \(error)")
            return nil
        }
    }

    /// Check if a plan is part of a group (either as parent or child)
    static func isPartOfGroup(
        plan: PlanEntity,
        in context: NSManagedObjectContext
    ) -> Bool {
        // Check if it's a parent
        if plan.isGroupParent {
            return true
        }

        // Check if it's a child
        let fetchRequest: NSFetchRequest<PlanGroupEntity> = PlanGroupEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "childPlan == %@", plan)
        fetchRequest.fetchLimit = 1

        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking if plan is part of group: \(error)")
            return false
        }
    }

    /// Delete all group relationships for a plan (both as parent and child)
    static func deleteGroupRelationships(
        for plan: PlanEntity,
        in context: NSManagedObjectContext
    ) throws {
        // Delete as parent
        let parentFetch: NSFetchRequest<PlanGroupEntity> = PlanGroupEntity.fetchRequest()
        parentFetch.predicate = NSPredicate(format: "parentPlan == %@", plan)
        let parentGroups = try context.fetch(parentFetch)
        parentGroups.forEach { context.delete($0) }

        // Delete as child
        let childFetch: NSFetchRequest<PlanGroupEntity> = PlanGroupEntity.fetchRequest()
        childFetch.predicate = NSPredicate(format: "childPlan == %@", plan)
        let childGroups = try context.fetch(childFetch)
        childGroups.forEach { context.delete($0) }
    }
}
