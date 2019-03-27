//
//  TeacherClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import SnapKit
import UIKit

class TeacherClassificationViewController: BaseViewController, BindableType {
    var segmentedControl: UISegmentedControl!
    var contentView: UIView!
    var currentViewController: UIViewController?

    var viewModel: TeacherClassificationViewModelProtocol!

    // MARK: lifecycle

    override func loadView() {
        super.loadView()
        navigationItem.title = viewModel.course.code
        loadUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        displayTab(forIndex: TeacherSceneIndex.groupClassification.rawValue)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeRightButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }

        if isMovingFromParent {
            viewModel.onBackAction.execute()
        }
    }

    // MARK: methods

    func bindViewModel() {}

    /// Displays child view controller
    func displayTab(forIndex index: Int) {
        if let scene = viewModel.scene(forSegmentIndex: index) {
            currentViewController = scene.viewController()

            addChild(currentViewController!)
            currentViewController!.didMove(toParent: self)
			currentViewController!.view.snp.makeConstraints { make in
				make.edges.equalToSuperview()
			}
            contentView.addSubview(currentViewController!.view)
        }
    }

    // MARK: UI setup

    func loadUI() {
        let segmented = UISegmentedControl(items: [L10n.Teacher.Tab.group, L10n.Teacher.Tab.student])
        segmented.selectedSegmentIndex = TeacherSceneIndex.groupClassification.rawValue
        segmented.center = view.center
        segmented.tintColor = UIColor.Theme.primary
        segmented.layer.cornerRadius = 0
        segmented.addTarget(self, action: #selector(segmentedControlIndexChanged(_:)), for: .valueChanged)
        view.addSubview(segmented)
        segmented.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        segmentedControl = segmented

        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(segmented.snp.bottom).offset(20)
        }
        self.contentView = contentView
    }

    // MARK: events

    @objc func segmentedControlIndexChanged(_ sender: UISegmentedControl) {
        currentViewController!.view.removeFromSuperview()
        currentViewController!.removeFromParent()

        displayTab(forIndex: sender.selectedSegmentIndex)
    }
}
