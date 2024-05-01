//
//  RealmActor.swift
//  SimpleApp
//
//  Created by loc on 02/11/2023.
//

import Foundation
import RealmSwift

class Todo: Object {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var name: String
    @Persisted var status: String
    @Persisted var owner: Person?
}

class Person: Object {
    @Persisted var id = ""
    @Persisted var firstName = ""
    @Persisted var lastName = ""
    @Persisted var age = 0
    @Persisted var fullName = "" // New property for v4 schema

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id: String, firstName: String, lastName: String, age: Int) {
        self.init()
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.fullName = firstName + " " + lastName
    }
}

actor RealmActor {
    static var shared: RealmActor = RealmActor()
    typealias ActorType = RealmActor

    var realm: Realm!

    init() {
    }

    init() async throws {
        realm = try await Realm(actor: self)
    }
    
    var toDosCount: Int {
        realm.objects(Todo.self).count
    }

    // We can't use this function because access Results<Todo> outside of the RealmActor functions cause crashes
    func fetchTodos() -> Results<Todo> {
        let b = TimeInterval(8).rounded(.up)
        let todos = realm.objects(Todo.self)
        let todo = todos.first
        debugPrint(todo?.name)
        return todos
    }

    func createTodo(id: String, name: String, status: String) async throws {
        try await realm.asyncWrite {
            realm.create(Todo.self, value: [
                "id": id,
                "name": name,
                "status": status
            ])
        }
    }
    
    func updateTodo(id: String, name: String, status: String) async throws {
        try await realm.asyncWrite {
            let owner = Person(id: "1", firstName: "L", lastName: "N", age: 25)
            realm.create(Todo.self, value: [
                "id": id,
                "name": name,
                "owner": owner,
                "status": status
            ], update: .modified)
        }
    }
    
    func deleteTodo(todo: Todo) async throws {
        try await realm.asyncWrite {
            realm.delete(todo)
        }
    }
    
    func close() {
        realm = nil
    } 

    func observeTodos() async {
        let todos =  realm.objects(Todo.self)
        
        let token = await todos.observe(on: RealmActor.shared, { actor, changes in
            print("A change occurred on actor: \(actor)")
            switch changes {
            case .initial:
                print("The initial value of the changed object was: \(changes)")
            case .update(_, let deletions, let insertions, let modifications):
                if !deletions.isEmpty {
                    print("An object was deleted: \(changes)")
                } else if !insertions.isEmpty {
                    Task {
                        let todos = await self.realm.objects(Todo.self)
                        print(">>>> Current Todo(s): \(todos)")
                    }
                    print("An object was inserted: \(changes)")
                } else if !modifications.isEmpty {
                    print("An object was modified: \(changes)")
                }
            case .error(let error):
                print("An error occurred: \(error.localizedDescription)")
            }
        })
    }
}
