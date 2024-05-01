//
//  PersistenceService.swift
//  SimpleApp
//
//  Created by Loc on 16/01/2024.
//

import RealmSwift
import Realm

public struct Sorted {
    public var key: String
    public var ascending: Bool = true

    public init(key: String, ascending: Bool) {
        self.key = key
        self.ascending = ascending
    }
}

public enum PersistenceError: CustomNSError {

    case creationFailed
    case saveFailed
    case updateFailed
    case deleteFailed
    case performTransactionsFailed

    public static var errorDomain: String {
        return "com.sph.PersistenceService"
    }

    public var errorCode: Int {
        switch self {
        case .creationFailed:
            return 2000
        case .saveFailed:
            return 2001
        case .updateFailed:
            return 2002
        case .deleteFailed:
            return 2003
        case .performTransactionsFailed:
            return 2004
        }
    }
}

public protocol Persistable {

    static func primaryKey() -> String?

    // To skip saving the object if the persistable object already exists in Realm database
    func skipIfExist() -> Bool

    // To exclude the properties from updating if the persistable object already exists in Realm database
    func skipProperties() -> [String]
}

class Article: Object, Persistable {
    func skipIfExist() -> Bool {
        true
    }

    func skipProperties() -> [String] {
        []
    }
//
//    var bookmarked = true
//    var articleID = ""
    @Persisted var name: String

}

public protocol PersistenceService {
    // Some current functions
    func fetchResults<T: Persistable>(_ model: T.Type, predicate: NSPredicate, sorted: Sorted?, distinctKeys: [String]?) -> Result<Results<Object>, PersistenceError>
    func fetch<T: Persistable>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?, distinctKeys: [String]?) -> Result<[T], PersistenceError>
    func create<T: Persistable>(objects: [T], update: Realm.UpdatePolicy) throws
    func save<T: Persistable>(objects: [T], replace: Bool, update: Realm.UpdatePolicy) throws
    func update(block: () -> Void) throws

    // Some new added functions
    func create<T: Persistable>(objects: [T], update: Realm.UpdatePolicy) async throws
    func save<T: Persistable>(objects: [T], replace: Bool, update: Realm.UpdatePolicy) async throws
    func update(block: () -> Void) async throws
}

final class ActorRealmPersistenceService: PersistenceService {

    var realm: Realm!
    private let realmActor: RealmActor

    init(actor: RealmActor) {
        self.realmActor = actor
    }

    func createTodo(id: String, name: String, status: String) async throws {
        try await realmActor.createTodo(id: id, name: name, status: status)
    }

    func fetchResults<T>(_ model: T.Type, predicate: NSPredicate, sorted: Sorted?, distinctKeys: [String]?) -> Result<RealmSwift.Results<RealmSwift.Object>, PersistenceError> where T : Persistable {
        return .success(realm.objects(model as! Object.Type))
    }

    func fetch<T>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?, distinctKeys: [String]?) -> Result<[T], PersistenceError> where T : Persistable {
        return .success(realm.objects(model as! Object.Type).compactMap { $0 as? T })
    }

    func create<T>(objects: [T], update: RealmSwift.Realm.UpdatePolicy) throws where T : Persistable {
    }

    func save<T>(objects: [T], replace: Bool, update: RealmSwift.Realm.UpdatePolicy) throws where T : Persistable {
    }

    func update(block: () -> Void) throws {
    }

    func create<T>(objects: [T], update: RealmSwift.Realm.UpdatePolicy) async throws where T : Persistable {
        for object in objects {
            if object is Object {
                try await realm.asyncWrite {
                    realm.create(T.self as! Object.Type, value: object)
                }
            }
        }
    }

    func save<T>(objects: [T], replace: Bool, update: RealmSwift.Realm.UpdatePolicy) async throws where T : Persistable {
        for object in objects {
            if let object = object as? Object {
                try await realm.asyncWrite {
                    realm.add(object, update: update)
                }
            }
        }
    }

    func update(block: () -> Void) async throws {
        try await realm.asyncWrite(block)
    }
}

