//
//  SwiftSnapshotTests.swift
//  SimpleAppTests
//
//  Created by realloxer on 02/04/2024.
//

import SnapshotTesting
import XCTest
@testable import SimpleApp

class MyViewControllerTests: XCTestCase {

    func testArticleViewController() {
        let vc = ArticleViewController.initializeVC()
        assertSnapshot(of: vc, as: .image(on: .iPhone12))
    }

}
