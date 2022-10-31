//
//  GenericDAO.swift
//
//  Created by tuyenvx.
//

import RealmSwift

class GenericDAO<ModelType: Object> {
    var realm: Realm?
    var results: Results<ModelType>?

    init() {
        do {
            realm = try Realm()
            results = realm?.objects(ModelType.self)
        } catch {
            print(error)
            debugPrint("Can't init Realm")
        }
    }
}

extension GenericDAO {
    @discardableResult func add(_ object: ModelType) -> Bool {
        guard let `realm` = realm else {
            return false
        }
        do {
            try realm.write({
                realm.add(object, update: .modified)
            })
        } catch {
            debugPrint("Can not add \(ModelType.self)")
            return false
        }
        return true
    }

    @discardableResult func addList(_ objects: [ModelType]) -> Int {
        var count = 0
        for object in objects {
            if add(object) { count += 1 }
        }
        return count
    }

    func getObject(with id: Any) -> ModelType? {
        return realm?.object(ofType: ModelType.self, forPrimaryKey: id)
    }

    func getFirstObject() -> ModelType? {
        return realm?.objects(ModelType.self).first
    }

    func getAllObject() -> [ModelType] {
        guard let result = realm?.objects(ModelType.self) else {
            return []
        }
        return Array(result)
    }

    func getObjects(with condition: String) -> [ModelType] {
        guard let result = realm?.objects(ModelType.self).filter(condition) else {
            return []
        }
        return Array(result)
    }

    @discardableResult func delete(_ object: ModelType) -> Bool {
        guard let `realm` = realm else {
            return false
        }
        do {
            try realm.write({
                realm.delete(object)
            })
        } catch {
            debugPrint("Can not delete \(ModelType.self)")
            return false
        }
        return true
    }

    func deleteAll() {
        if let res = realm?.objects(ModelType.self) {
            try? realm?.write({
                realm?.delete(res)
            })
        }
    }

    func registerToken(token: inout NotificationToken?, handle: @escaping () -> Void) {
        token = results?.observe({ (_) in
            handle()
        })
    }

    func update(_ updateBlock: (() -> Void)) {
        guard let `realm` = realm else {
            return
        }
        do {
            try realm.write({
                updateBlock()
            })
        } catch {
            debugPrint("Can not update \(ModelType.self)")
            return
        }
    }
}
