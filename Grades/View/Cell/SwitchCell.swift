//
//  SwitchCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 26/09/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxBiBinding
import RxSwift
import UIKit

typealias SwitchCellConfigurator = TableCellConfigurator<SwitchCell, SwitchCellViewModel>

final class SwitchCell: BasicCell, ConfigurableCell {
    private var enabledSwitch: UIPrimarySwitch!
    private(set) var bag = DisposeBag()

    var viewModel: SwitchCellViewModel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()

        selectionStyle = .none
    }

    func configure(data switchViewModel: SwitchCellViewModel) {
        viewModel = switchViewModel
        bindViewModel()
    }

    private func bindViewModel() {
        titleLabel.text = viewModel.title
        (enabledSwitch.rx.value <-> viewModel.isEnabled).disposed(by: bag)
    }

    private func loadUI() {
        titleLabel.textColor = UIColor.Theme.text

        let enabledSwitch = UIPrimarySwitch()
        contentView.addSubview(enabledSwitch)
        enabledSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        self.enabledSwitch = enabledSwitch
    }
}
