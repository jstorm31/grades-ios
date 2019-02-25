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
	
	private let config: NSClassificationConfiguration = EnvironmentConfiguration()
	
//	init(config: NSClassificationConfiguration?) {
//		self.config = config ?? EnvironmentConfiguration()
//		super.init(nibName: nil, bundle: nil)
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
	
	override func loadView() {
		super.loadView()

		let label = UILabel()
		view.addSubview(label)
		label.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		self.myLabel = label
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		print(config.authServerUrl)
		myLabel.text = config.authServerUrl
	}

}
