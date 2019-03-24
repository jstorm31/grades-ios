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

    var viewModel: TeacherClassificationViewModelProtocol!

    // MARK: lifecycle

    override func loadView() {
        super.loadView()
        navigationItem.title = viewModel.course.code
        loadUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeRightButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBackAction.execute()
        }
    }

    // MARK: methods

    func bindViewModel() {}

    // MARK: UI setup

    func loadUI() {
        let segmented = UISegmentedControl(items: ["Klasifikace", "Student"])
        segmented.selectedSegmentIndex = 0
        segmented.center = view.center
        segmented.addTarget(self, action: #selector(segmentedControlIndexChanged(_:)), for: .valueChanged)
        view.addSubview(segmented)
        segmented.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
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

    @objc func segmentedControlIndexChanged(_: UISegmentedControl) {
        Log.info("Segmented index changed: \(segmentedControl.selectedSegmentIndex)")
    }
}
