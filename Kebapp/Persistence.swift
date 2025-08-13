import Foundation
import CoreData

/// Core Data stack configured in code without external model files.
final class PersistenceController {
    static let shared = PersistenceController()

    /// The container that holds the Core Data stack.
    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        // Define the managed object model programmatically.
        let model = NSManagedObjectModel()

        // Entity description
        let entity = NSEntityDescription()
        entity.name = "CalculationEntity"
        entity.managedObjectClassName = NSStringFromClass(CalculationEntity.self)

        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false

        let adultsAttr = NSAttributeDescription()
        adultsAttr.name = "adults"
        adultsAttr.attributeType = .integer16AttributeType
        adultsAttr.isOptional = false

        let nonMeatAttr = NSAttributeDescription()
        nonMeatAttr.name = "nonMeatEaters"
        nonMeatAttr.attributeType = .integer16AttributeType
        nonMeatAttr.isOptional = false

        let kidsAttr = NSAttributeDescription()
        kidsAttr.name = "kids"
        kidsAttr.attributeType = .integer16AttributeType
        kidsAttr.isOptional = false

        let durationAttr = NSAttributeDescription()
        durationAttr.name = "duration"
        durationAttr.attributeType = .stringAttributeType
        durationAttr.isOptional = false

        let meatAttr = NSAttributeDescription()
        meatAttr.name = "meat"
        meatAttr.attributeType = .binaryDataAttributeType
        meatAttr.isOptional = false

        let totalWeightAttr = NSAttributeDescription()
        totalWeightAttr.name = "totalWeight"
        totalWeightAttr.attributeType = .doubleAttributeType
        totalWeightAttr.isOptional = false

        let portionAttr = NSAttributeDescription()
        portionAttr.name = "portionPerPerson"
        portionAttr.attributeType = .doubleAttributeType
        portionAttr.isOptional = false

        entity.properties = [idAttr, dateAttr, adultsAttr, nonMeatAttr, kidsAttr, durationAttr, meatAttr, totalWeightAttr, portionAttr]

        model.entities = [entity]

        container = NSPersistentContainer(name: "HistoryModel", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

/// Core Data managed object representing saved calculation.
@objc(CalculationEntity)
class CalculationEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var adults: Int16
    @NSManaged var nonMeatEaters: Int16
    @NSManaged var kids: Int16
    @NSManaged var duration: String
    @NSManaged var meat: Data
    @NSManaged var totalWeight: Double
    @NSManaged var portionPerPerson: Double
}
