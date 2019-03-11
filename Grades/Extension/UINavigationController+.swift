//
//  UINavigationController+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 11/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

extension UINavigationController {
	open override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	open override var shouldAutorotate: Bool {
		if let visibleVC = visibleViewController {
			return visibleVC.shouldAutorotate
		}
		return super.shouldAutorotate
	}
	
	open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		if let visibleVC = visibleViewController {
			return visibleVC.preferredInterfaceOrientationForPresentation
		}
		return super.preferredInterfaceOrientationForPresentation
	}
	
	open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if let visibleVC = visibleViewController {
			return visibleVC.supportedInterfaceOrientations
		}
		return super.supportedInterfaceOrientations
	}
}
