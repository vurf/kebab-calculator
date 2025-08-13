import Foundation
import CoreData

/// ViewModel responsible for saving, loading and deleting calculations.
final class HistoryViewModel: ObservableObject {
    @Published private(set) var items: [CalculationHistoryItem] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetch()
    }

    /// Fetches all stored calculations from Core Data.
    func fetch() {
        let request = NSFetchRequest<CalculationEntity>(entityName: "CalculationEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let entities = try context.fetch(request)
            items = entities.map(CalculationHistoryItem.init)
        } catch {
            print("Fetch error: \(error)")
        }
    }

    /// Saves a calculation into storage.
    func save(item: CalculationHistoryItem) {
        let entity = CalculationEntity(context: context)
        entity.id = item.id
        entity.date = item.date
        entity.adults = Int16(item.adults)
        entity.nonMeatEaters = Int16(item.nonMeatEaters)
        entity.kids = Int16(item.kids)
        entity.duration = item.duration
        entity.meat = (try? JSONEncoder().encode(item.meat)) ?? Data()
        entity.totalWeight = item.totalWeight
        entity.portionPerPerson = item.portionPerPerson
        persist()
        fetch()
    }

    /// Deletes items at specified offsets.
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let item = items[index]
            let request = NSFetchRequest<CalculationEntity>(entityName: "CalculationEntity")
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            if let entity = try? context.fetch(request).first {
                context.delete(entity)
            }
        }
        persist()
        fetch()
    }

    /// Persists changes to disk.
    private func persist() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }
}
