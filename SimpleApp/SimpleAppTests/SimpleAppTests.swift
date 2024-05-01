//
//  SimpleAppTests.swift
//  SimpleAppTests
//
//  Created by realloxer on 01/04/2024.
//

import FBSnapshotTestCase
@testable import SimpleApp

final class SimpleAppTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        recordMode = true
    }

//    func testExample() {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
//        view.backgroundColor = UIColor.green
//        FBSnapshotVerifyView(view)
//        FBSnapshotVerifyLayer(view.layer)
//    }

    func testViewController() {
        let viewController = ArticleViewController.initializeVC()
        let view = viewController.view!
        FBSnapshotVerifyView(view)
        FBSnapshotVerifyLayer(view.layer)
    }
}
