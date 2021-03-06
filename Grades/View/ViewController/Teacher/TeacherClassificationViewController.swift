//
//  TeacherClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import SnapKit
import UIKit

final class TeacherClassificationViewController: BaseViewController, BindableType {
    var segmentedControl: UISegmentedControl!
    var contentView: UIView!
    var currentViewController: UIViewController?

    var viewModel: TeacherClassificationViewModel!

    // MARK: lifecycle

    override func loadView() {
        super.loadView()

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.course.code
        loadUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        displayTab(forIndex: viewModel.defaultScene.rawValue)
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
            contentView.addSubview(currentViewController!.view)
            currentViewController!.view.snp.makeConstraints { make in
                make.edges.equalTo(contentView.safeAreaLayoutGuide)
            }
        }
    }

    // MARK: UI setup

    func loadUI() {
        let segmented = UISegmentedControl(items: [L10n.Teacher.Tab.group, L10n.Teacher.Tab.student])
        segmented.selectedSegmentIndex = viewModel.defaultScene.rawValue
        segmented.center = view.center
        if #available(iOS 13.0, *) {
            segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            segmented.selectedSegmentTintColor = UIColor.Theme.primary
        } else {
            segmented.tintColor = UIColor.Theme.primary
        }
        segmented.setTitleTextAttributes([.font: UIFont.Grades.body, .foregroundColor: UIColor.Theme.text], for: .normal)
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
