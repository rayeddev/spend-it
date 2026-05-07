//
//  PersistenceController.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

internal import CoreData
import CloudKit

// MARK: - Persistence Controller

/// Manages Core Data stack with CloudKit synchronization
class PersistenceController {

    // MARK: - Singleton

    static let shared = PersistenceController()

    // MARK: - Preview Support

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Create sample data for previews
        let plan = PlanEntity.create(
            in: context,
            name: "December 2025 Budget",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        )
        plan.statusEnum = .active

        _ = PlanItemEntity.create(
            in: context,
            plan: plan,
            name: "Salary",
            amount: 4200.00,
            type: .income
        )

        _ = PlanItemEntity.create(
            in: context,
            plan: plan,
            name: "Rent",
            amount: 1200.00,
            type: .outcome
        )

        _ = PlanItemEntity.create(
            in: context,
            plan: plan,
            name: "Groceries",
            amount: 400.00,
            type: .outcome
        )

        _ = PlanItemEntity.create(
            in: context,
            plan: plan,
            name: "Emergency Fund",
            amount: 500.00,
            type: .savings
        )

        do {
            try context.save()
        } catch {
            print("Preview data creation failed: \(error)")
        }

        return controller
    }()

    // MARK: - Core Data Stack

    let container: NSPersistentCloudKitContainer

    // MARK: - Initialization

    init(inMemory: Bool = false) {
        // Use programmatic model
        let model = Self.createModel()
        container = NSPersistentCloudKitContainer(name: "SpendItModel", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure CloudKit container
            guard let description = container.persistentStoreDescriptions.first else {
                fatalError("Failed to retrieve persistent store description")
            }

            // Enable lightweight migration to handle schema changes
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true

            #if DEBUG
            // In DEBUG mode, disable CloudKit sync (no Apple Developer account needed)
            print("📱 DEBUG MODE: CloudKit sync is DISABLED")
            description.cloudKitContainerOptions = nil
            #else
            // In RELEASE mode, enable CloudKit sync
            // Enable persistent history tracking for CloudKit sync
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            // CloudKit configuration
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.spendit.app"
            )
            print("☁️ RELEASE MODE: CloudKit sync is ENABLED")
            #endif
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, handle this error gracefully
                // For now, we'll log and crash
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // Automatically merge changes from parent context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Watch for remote changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(processRemoteStoreChange(_:)),
            name: NSNotification.Name.NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }

    // MARK: - CloudKit Sync

    @objc private func processRemoteStoreChange(_ notification: Notification) {
        // Process remote changes from CloudKit
        // This ensures UI updates when data changes on other devices
        print("Remote store change detected")
    }

    // MARK: - Save Context

    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
                // In production, handle this error appropriately
            }
        }
    }

    // MARK: - Batch Operations

    /// Delete all data (for testing or reset)
    func deleteAllData() {
        let context = container.viewContext

        let entities = ["PlanGroupEntity", "PlanItemEntity", "PlanEntity"]
        entities.forEach { entityName in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("Error deleting \(entityName): \(error)")
            }
        }
    }
}

// MARK: - Core Data Model Definition

extension PersistenceController {

    /// Programmatically define Core Data model
    static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // MARK: Plan Entity

        let planEntity = NSEntityDescription()
        planEntity.name = "PlanEntity"
        planEntity.managedObjectClassName = NSStringFromClass(PlanEntity.self)

        var planProperties: [NSAttributeDescription] = []

        let planId = NSAttributeDescription()
        planId.name = "id"
        planId.attributeType = .UUIDAttributeType
        planId.isOptional = false
        planProperties.append(planId)

        let planName = NSAttributeDescription()
        planName.name = "name"
        planName.attributeType = .stringAttributeType
        planName.isOptional = false
        planProperties.append(planName)

        let startDate = NSAttributeDescription()
        startDate.name = "startDate"
        startDate.attributeType = .dateAttributeType
        startDate.isOptional = false
        planProperties.append(startDate)

        let endDate = NSAttributeDescription()
        endDate.name = "endDate"
        endDate.attributeType = .dateAttributeType
        endDate.isOptional = false
        planProperties.append(endDate)

        let isRecurring = NSAttributeDescription()
        isRecurring.name = "isRecurring"
        isRecurring.attributeType = .booleanAttributeType
        isRecurring.defaultValue = false
        planProperties.append(isRecurring)

        let recurrenceType = NSAttributeDescription()
        recurrenceType.name = "recurrenceType"
        recurrenceType.attributeType = .stringAttributeType
        recurrenceType.isOptional = true
        planProperties.append(recurrenceType)

        let status = NSAttributeDescription()
        status.name = "status"
        status.attributeType = .stringAttributeType
        status.isOptional = false
        status.defaultValue = "draft"
        planProperties.append(status)

        let parentPlanId = NSAttributeDescription()
        parentPlanId.name = "parentPlanId"
        parentPlanId.attributeType = .UUIDAttributeType
        parentPlanId.isOptional = true
        planProperties.append(parentPlanId)

        let currencyCode = NSAttributeDescription()
        currencyCode.name = "currencyCode"
        currencyCode.attributeType = .stringAttributeType
        currencyCode.isOptional = false
        currencyCode.defaultValue = "USD"
        planProperties.append(currencyCode)

        let planCreatedAt = NSAttributeDescription()
        planCreatedAt.name = "createdAt"
        planCreatedAt.attributeType = .dateAttributeType
        planCreatedAt.isOptional = false
        planProperties.append(planCreatedAt)

        let planUpdatedAt = NSAttributeDescription()
        planUpdatedAt.name = "updatedAt"
        planUpdatedAt.attributeType = .dateAttributeType
        planUpdatedAt.isOptional = false
        planProperties.append(planUpdatedAt)

        let isGroupParent = NSAttributeDescription()
        isGroupParent.name = "isGroupParent"
        isGroupParent.attributeType = .booleanAttributeType
        isGroupParent.defaultValue = false
        planProperties.append(isGroupParent)

        let groupType = NSAttributeDescription()
        groupType.name = "groupType"
        groupType.attributeType = .stringAttributeType
        groupType.isOptional = true
        planProperties.append(groupType)

        planEntity.properties = planProperties

        // MARK: PlanItem Entity

        let itemEntity = NSEntityDescription()
        itemEntity.name = "PlanItemEntity"
        itemEntity.managedObjectClassName = NSStringFromClass(PlanItemEntity.self)

        var itemProperties: [NSAttributeDescription] = []

        let itemId = NSAttributeDescription()
        itemId.name = "id"
        itemId.attributeType = .UUIDAttributeType
        itemId.isOptional = false
        itemProperties.append(itemId)

        let itemName = NSAttributeDescription()
        itemName.name = "name"
        itemName.attributeType = .stringAttributeType
        itemName.isOptional = false
        itemProperties.append(itemName)

        let amount = NSAttributeDescription()
        amount.name = "amount"
        amount.attributeType = .decimalAttributeType
        amount.isOptional = false
        amount.defaultValue = NSDecimalNumber.zero
        itemProperties.append(amount)

        let type = NSAttributeDescription()
        type.name = "type"
        type.attributeType = .stringAttributeType
        type.isOptional = false
        itemProperties.append(type)

        let isFrozen = NSAttributeDescription()
        isFrozen.name = "isFrozen"
        isFrozen.attributeType = .booleanAttributeType
        isFrozen.defaultValue = false
        itemProperties.append(isFrozen)

        let sortOrder = NSAttributeDescription()
        sortOrder.name = "sortOrder"
        sortOrder.attributeType = .integer16AttributeType
        sortOrder.defaultValue = 0
        itemProperties.append(sortOrder)

        let icon = NSAttributeDescription()
        icon.name = "icon"
        icon.attributeType = .stringAttributeType
        icon.isOptional = true
        itemProperties.append(icon)

        let color = NSAttributeDescription()
        color.name = "color"
        color.attributeType = .stringAttributeType
        color.isOptional = true
        itemProperties.append(color)

        let notes = NSAttributeDescription()
        notes.name = "notes"
        notes.attributeType = .stringAttributeType
        notes.isOptional = true
        itemProperties.append(notes)

        let itemCreatedAt = NSAttributeDescription()
        itemCreatedAt.name = "createdAt"
        itemCreatedAt.attributeType = .dateAttributeType
        itemCreatedAt.isOptional = false
        itemProperties.append(itemCreatedAt)

        let itemUpdatedAt = NSAttributeDescription()
        itemUpdatedAt.name = "updatedAt"
        itemUpdatedAt.attributeType = .dateAttributeType
        itemUpdatedAt.isOptional = false
        itemProperties.append(itemUpdatedAt)

        let sourceItemId = NSAttributeDescription()
        sourceItemId.name = "sourceItemId"
        sourceItemId.attributeType = .UUIDAttributeType
        sourceItemId.isOptional = true
        itemProperties.append(sourceItemId)

        let groupKey = NSAttributeDescription()
        groupKey.name = "groupKey"
        groupKey.attributeType = .stringAttributeType
        groupKey.isOptional = true
        itemProperties.append(groupKey)

        itemEntity.properties = itemProperties

        // MARK: Relationships

        let planItemsRelationship = NSRelationshipDescription()
        planItemsRelationship.name = "items"
        planItemsRelationship.destinationEntity = itemEntity
        planItemsRelationship.minCount = 0
        planItemsRelationship.maxCount = 0 // to-many
        planItemsRelationship.deleteRule = .cascadeDeleteRule

        let itemPlanRelationship = NSRelationshipDescription()
        itemPlanRelationship.name = "plan"
        itemPlanRelationship.destinationEntity = planEntity
        itemPlanRelationship.minCount = 1
        itemPlanRelationship.maxCount = 1
        itemPlanRelationship.deleteRule = .nullifyDeleteRule

        planItemsRelationship.inverseRelationship = itemPlanRelationship
        itemPlanRelationship.inverseRelationship = planItemsRelationship

        planEntity.properties.append(planItemsRelationship)
        itemEntity.properties.append(itemPlanRelationship)

        // MARK: PlanGroup Entity

        let groupEntity = NSEntityDescription()
        groupEntity.name = "PlanGroupEntity"
        groupEntity.managedObjectClassName = NSStringFromClass(PlanGroupEntity.self)

        var groupProperties: [NSAttributeDescription] = []

        let groupId = NSAttributeDescription()
        groupId.name = "id"
        groupId.attributeType = .UUIDAttributeType
        groupId.isOptional = false
        groupProperties.append(groupId)

        let sequenceOrder = NSAttributeDescription()
        sequenceOrder.name = "sequenceOrder"
        sequenceOrder.attributeType = .integer16AttributeType
        sequenceOrder.defaultValue = 0
        groupProperties.append(sequenceOrder)

        let groupCreatedAt = NSAttributeDescription()
        groupCreatedAt.name = "createdAt"
        groupCreatedAt.attributeType = .dateAttributeType
        groupCreatedAt.isOptional = false
        groupProperties.append(groupCreatedAt)

        let groupUpdatedAt = NSAttributeDescription()
        groupUpdatedAt.name = "updatedAt"
        groupUpdatedAt.attributeType = .dateAttributeType
        groupUpdatedAt.isOptional = false
        groupProperties.append(groupUpdatedAt)

        groupEntity.properties = groupProperties

        // MARK: Group Relationships

        // PlanGroup -> Parent Plan (many-to-one)
        let groupParentRelationship = NSRelationshipDescription()
        groupParentRelationship.name = "parentPlan"
        groupParentRelationship.destinationEntity = planEntity
        groupParentRelationship.minCount = 1
        groupParentRelationship.maxCount = 1
        groupParentRelationship.deleteRule = .cascadeDeleteRule

        // PlanGroup -> Child Plan (many-to-one)
        let groupChildRelationship = NSRelationshipDescription()
        groupChildRelationship.name = "childPlan"
        groupChildRelationship.destinationEntity = planEntity
        groupChildRelationship.minCount = 1
        groupChildRelationship.maxCount = 1
        groupChildRelationship.deleteRule = .cascadeDeleteRule

        // Plan -> Child Groups (one-to-many, inverse of parentPlan)
        let planChildGroupsRelationship = NSRelationshipDescription()
        planChildGroupsRelationship.name = "childGroups"
        planChildGroupsRelationship.destinationEntity = groupEntity
        planChildGroupsRelationship.minCount = 0
        planChildGroupsRelationship.maxCount = 0  // to-many
        planChildGroupsRelationship.deleteRule = .cascadeDeleteRule

        // Plan -> Parent Groups (one-to-many, inverse of childPlan)
        let planParentGroupsRelationship = NSRelationshipDescription()
        planParentGroupsRelationship.name = "parentGroups"
        planParentGroupsRelationship.destinationEntity = groupEntity
        planParentGroupsRelationship.minCount = 0
        planParentGroupsRelationship.maxCount = 0  // to-many
        planParentGroupsRelationship.deleteRule = .cascadeDeleteRule

        // Set inverse relationships
        groupParentRelationship.inverseRelationship = planChildGroupsRelationship
        planChildGroupsRelationship.inverseRelationship = groupParentRelationship

        groupChildRelationship.inverseRelationship = planParentGroupsRelationship
        planParentGroupsRelationship.inverseRelationship = groupChildRelationship

        // Add relationships to entities
        groupEntity.properties.append(groupParentRelationship)
        groupEntity.properties.append(groupChildRelationship)
        planEntity.properties.append(planChildGroupsRelationship)
        planEntity.properties.append(planParentGroupsRelationship)

        model.entities = [planEntity, itemEntity, groupEntity]

        return model
    }
}
