//
//  ViewController.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

	weak var myLabel: UILabel!

	override func loadView() {
		super.loadView()

		let label = UILabel()
		label.text = "Hello, world!"
		view.addSubview(label)
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		self.myLabel = label
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

}
