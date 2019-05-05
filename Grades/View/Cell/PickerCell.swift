//
//  PickerCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 28/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

typealias PickerCellConfigurator = TableCellConfigurator<PickerCell, PickerCellViewModel>

final class PickerCell: BasicCell, ConfigurableCell {
    private var pickerLabel: UIPickerLabel!

    var viewModel: PickerCellViewModel!
    private(set) var bag = DisposeBag()

    // MARK: initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }

    // MARK: Configuration

    func configure(data cellViewModel: PickerCellViewModel) {
        viewModel = cellViewModel
        bindViewModel()
    }

    func bindViewModel() {
        titleLabel.text = viewModel.title

        viewModel.selectedOption.asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] text in
                self?.pickerLabel.text = text
            })
            .disposed(by: bag)
    }

    // MARK: UI setup

    private func loadUI() {
        titleLabel.font = UIFont.Grades.boldBody

        let pickerLabel = UIPickerLabel()
        contentView.addSubview(pickerLabel)
        pickerLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        self.pickerLabel = pickerLabel
    }
}
