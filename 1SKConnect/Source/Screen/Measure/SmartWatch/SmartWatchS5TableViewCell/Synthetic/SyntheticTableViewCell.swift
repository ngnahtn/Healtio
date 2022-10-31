//
//  SyntheticTableViewCell.swift
//  1SKConnect
//
//  Created by Be More on 10/12/2021.
//

import UIKit
import Alamofire

class SyntheticTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableViewContentView: UIView!
    var shadowLayer: CAShapeLayer?
    
    var model: SyntheticData? {
        didSet {
            setData()
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.registerNib(ofType: SyntheticCategoriesTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupTableView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.createShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

// MARK: - Helpers
extension SyntheticTableViewCell {
    private func setData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        DispatchQueue.main.async {
            self.tableViewContentView.addSubview(self.tableView)
            self.tableView.anchor(top: self.titleLabel.bottomAnchor,
                                  left: self.tableViewContentView.leftAnchor,
                                  bottom: self.tableViewContentView.bottomAnchor,
                                  right: self.tableViewContentView.rightAnchor,
                                  paddingTop: 13)
        }
    }
    
    private func createShadow() {
        DispatchQueue.main.async {
            if self.shadowLayer == nil {
                let shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, cornerRadius: 4)
                self.shadowLayer = CAShapeLayer()
                self.shadowLayer?.shadowPath = shadowPath.cgPath
                self.shadowLayer?.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.11).cgColor
                self.shadowLayer?.shadowOpacity = 1
                self.shadowLayer?.shadowRadius = 5
                self.shadowLayer?.shadowOffset = CGSize(width: 0, height: 4)
                self.shadowView.layer.insertSublayer(self.shadowLayer!, at: 0)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension SyntheticTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SyntheticTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.haveFullCategories() {
            return syntheticFullCategoriesDataSource.count
        } else {
            return syntheticCategoriesDataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: SyntheticCategoriesTableViewCell.self, for: indexPath)
        
        if self.haveFullCategories() {
            cell.model = syntheticFullCategoriesDataSource[indexPath.row]
        } else {
            cell.model = syntheticCategoriesDataSource[indexPath.row]
        }
        
        if cell.model != nil {
            if let model = self.model {
                switch cell.model!.type {
                case .step:
                    cell.model?.value = model.step
                case .calo:
                    cell.model?.value = model.calo
                case .hr:
                    cell.model?.value = model.hr
                case .spO2:
                    cell.model?.value = model.spO2
                case .bp:
                    cell.model?.value = model.bp
                case .temp:
                    cell.model?.value = model.temp
                case .sleep:
                    cell.model?.value = model.sleep
                case .run:
                    cell.model?.value = model.run
                }
            }
        }
        return cell
    }
}

// MARK: - Helpers
extension SyntheticTableViewCell {
    private func haveFullCategories() -> Bool {
        guard let model = self.model else  { return true }
        return !String.isNilOrEmpty(model.run) && model.run != "-"
    }
}
