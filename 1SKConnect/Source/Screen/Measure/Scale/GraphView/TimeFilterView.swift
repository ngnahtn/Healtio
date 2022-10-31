//
//  TimeFilterView.swift
//  1SKConnect
//
//  Created by tuyenvx on 14/04/2021.
//

protocol TimeFilterViewDelegate: AnyObject {
    func filterTypeDidSelected(_ filterType: TimeFilterType)
}

class TimeFilterView: UIView {
    var filterTypes: [TimeFilterType] = []
    var currentType: TimeFilterType = .day

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.backgroundColor = UIColor(hex: "F0F1F2")
        return stackView
    }()

    weak var delegate: TimeFilterViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    // MARK: - Setup
    private func setupDefaults() {
        backgroundColor = UIColor(hex: "F0F1F2")
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    private func addArrangedSubViewsToStackView() {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview()})
        for (index, filterType) in filterTypes.enumerated() {
            let item = createTimeFilterItem(from: filterType)
            let isSelected = index == 0
            if let button = item.subviews.first as? UIButton {
                button.backgroundColor = !isSelected ? .clear : R.color.subTitle()
                button.setTitleColor(!isSelected ? R.color.subTitle() : .white, for: .normal)
            }
            stackView.addArrangedSubview(item)
        }
    }

    private func createTimeFilterItem(from filterType: TimeFilterType) -> UIView {
        let item = UIView()
        //
//        let titleLabel = UILabel()
//        titleLabel.text = filterType.name
//        item.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        //
        let button = UIButton()
        button.cornerRadius = 16
        button.setTitle(filterType.name, for: .normal)
        button.titleLabel?.font = R.font.robotoRegular(size: 16)
        button.tag = filterTypes.firstIndex(of: filterType) ?? 0
        button.addTarget(self, action: #selector(onItemDidSelected(sender:)), for: .touchUpInside)
        item.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(2)
            make.bottom.trailing.equalToSuperview().inset(2)
        }
        //
        return item
    }
    // MARK: - Action
    func setFilterTypes(_ filterTypes: [TimeFilterType]) {
        self.filterTypes = filterTypes
        addArrangedSubViewsToStackView()
        currentType = filterTypes.first ?? .day
    }

    @objc func onItemDidSelected(sender: UIButton) {
        for (index, subView) in stackView.arrangedSubviews.enumerated() {
            let isSelected = index == sender.tag
            if let button = subView.subviews.first as? UIButton {
                button.backgroundColor = !isSelected ? .clear : R.color.subTitle()
                button.setTitleColor(!isSelected ? R.color.subTitle() : .white, for: .normal)
            }
        }
        let filterType = filterTypes[sender.tag]
        currentType = filterType
        delegate?.filterTypeDidSelected(filterType)
    }
}
