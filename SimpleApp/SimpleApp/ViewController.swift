//
//  ViewController.swift
//  SimpleApp
//
//  Created by loc on 05/07/2023.
//

import RealmSwift
import Speech

class ViewController: UIViewController {

    var tasks = [Task<Void, Never>]()
    var token: NotificationToken!
    var persistenceService: ActorRealmPersistenceService!
    var actor: RealmActor!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // Example 1: Actor attribute
    @IBAction func buttonF1Pressed(_ sender: Any) {
        Task {
            try await f1()
        }
    }

    @MainActor
    func f1() async throws {
        let realm = try await Realm(actor: MainActor.shared)
        var todos = realm.objects(Todo.self)
        print("1. MAIN THREAD: The number of ToDo objects is: \(todos.count)")

        try await observeDataChanges()
        try await saveTodoInBackgroundThread()

        // Fetch directly after save data (not recommended)
        await realm.asyncRefresh()
        todos = realm.objects(Todo.self)
        print("2. MAIN THREAD: The number of ToDo objects is: \(todos.count)")
        debugPrint(">>>> MAIN THREAD LAST TODO: \(todos.last?.name ?? "")")
    }

    // Observe Data changes on Main Actor
    @MainActor
    func observeDataChanges() async throws {
        if token == nil {
            let realm = try await Realm(actor: MainActor.shared)
            let todos = realm.objects(Todo.self)
            token = await todos.observe(on: MainActor.shared, { actor, changes in
                switch changes {
                case .initial:
                    break
                case .error(let error):
                    print("An error occurred: \(error.localizedDescription)")
                case .update(_, let deletions, let insertions, let modifications):
                    print("A change occurred on actor: \(actor)")
                    print(changes)
                }
            })
        }
    }

    @BackgroundActor
    func saveTodoInBackgroundThread() async throws {
        // Explicitly specifying the actor is required for anything that is not MainActor
        let realm = try await Realm(actor: BackgroundActor.shared)
        try realm.write {
            _ = realm.create(Todo.self, value: [
                "name": "HHHHH",
                "status": "In Progress"
            ])
        }
        let todoCount = realm.objects(Todo.self).count
        try await realm.asyncWrite {
            _ = realm.create(Todo.self, value: [
                "name": "TODO_\(todoCount + 1)",
                "status": "In Progress"
            ])
        }
    }

    // Example 2: Local Actor
    @IBAction func buttonF2Pressed(_ sender: Any) {
        Task {
            await f2()
        }
    }

    func f2() async {
        actor = try! await RealmActor()

        var todoCount = await actor.toDosCount
        try! await actor.createTodo(id: "11", name: "TODO_\(todoCount + 1)", status: "DONE")

        try! await actor.updateTodo(id: "11", name: "NewName", status: "NewStatus")
        todoCount = await actor.toDosCount
        print("Actor has \(todoCount) Todo(s)")

        // App is crashing if using realm or fectched object outside of RealmActor
        let todos = await actor.fetchTodos()
        let realm = await actor.realm
        debugPrint(realm)
        debugPrint(todos.first)
    }
}

@globalActor
actor BackgroundActor: GlobalActor {
    static var shared = BackgroundActor()
}

@globalActor
actor AnotherBackgroundActor: GlobalActor {
    static var shared = BackgroundActor()
}
