//
//  S5HeartRateDetailTableViewCell.swift
//  1SKConnect
//
//  Created by Be More on 27/12/2021.
//

import UIKit
import RealmSwift

struct S5HeartRateDetail {
    var timeType: TimeFilterType
    var dataValues: S5HeartRateListRecordModel?
}

class S5HeartRateDetailTableViewCell: UITableViewCell {
    
    var shadowLayer: CAShapeLayer?
    @IBOutlet weak var chartCollectionView: UICollectionView!
    @IBOutlet weak var shadowView: UIView!
    
    var model: S5HeartRateDetail? {
        didSet {
            guard let records = model?.dataValues?.hrList.array else {
                self.records = []
                return
            }
            self.records = records
        }
    }
    
    var records: [S5HeartRateRecordModel] = [] {
        didSet {
            if !records.isEmpty {
                if let date = records[0].dateTime.toDate(.ymd) {
                    if date.isInToday == false {
                        self.records.insert(S5HeartRateRecordModel(), at: 0)
                    }
                }
            }
            self.reloadHrDetailCLVCell()
            self.setChartData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setUpView() {
        self.selectionStyle = .none
        self.chartCollectionView.delegate = self
        self.chartCollectionView.dataSource = self
        self.chartCollectionView.registerNib(ofType: S5HeartRateChartCollectionViewCell.self)
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

    private func setChartData() {
        guard let model = self.model else { return }
        guard let hrList = model.dataValues else { return }
        DispatchQueue.main.async {
            self.chartCollectionView.reloadData()
            if model.timeType == .day {
                self.chartCollectionView.scrollToItem(at: IndexPath(item: self.records.count - 1, section: 0), at: .centeredHorizontally, animated: false)
            } else {
                self.chartCollectionView.scrollToItem(at: IndexPath(item: hrList.getGraphData(of: model.timeType).count - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension S5HeartRateDetailTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.chartCollectionView.frame.width, height: self.chartCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UICollectionViewDataSource
extension S5HeartRateDetailTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = self.model else { return 1 }
        guard let data = self.model?.dataValues else { return 1 }
        if model.timeType == .day {
            if self.records.isEmpty {
                return 1
            }
            return self.records.count
        } else if model.timeType == .year {
            return data.getYearGarphData(of: model.timeType).count
        } else {
            return data.getGraphData(of: model.timeType).count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeuCell(ofType: S5HeartRateChartCollectionViewCell.self, for: indexPath)
        guard let model = self.model else { return cell }
        guard let hrList = model.dataValues else {
            cell.timeType = model.timeType
            return cell
        }
        cell.delegate = self
        cell.timeType = model.timeType
        if model.timeType == .day {
            cell.icNextImageView.isHidden = indexPath.item == self.records.count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.dayModel = self.records.reversed()[indexPath.item]
        } else if model.timeType == .week {
            cell.icNextImageView.isHidden = indexPath.item == hrList.getGraphData(of: model.timeType).count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.weakModel = hrList.getGraphData(of: model.timeType)[indexPath.item]
        } else if model.timeType == .month {
            cell.icNextImageView.isHidden = indexPath.item == hrList.getGraphData(of: model.timeType).count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.monthModel = hrList.getGraphData(of: model.timeType)[indexPath.item]
        } else {
            cell.icNextImageView.isHidden = indexPath.item == hrList.getYearGarphData(of: model.timeType).count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.yearModel = hrList.getYearGarphData(of: model.timeType)[indexPath.item]
        }
        return cell
    }
}

extension S5HeartRateDetailTableViewCell: S5HeartRateChartCollectionViewCellDelegate {
    func onSelectNext(_ cell: UICollectionViewCell) {
        if let index = self.chartCollectionView.indexPath(for: cell) {
            self.chartCollectionView.scrollToItem(at: IndexPath(item: index.item + 1, section: 0), at: .centeredVertically, animated: true)
        }
    }

    func onSelectPrevious(_ cell: UICollectionViewCell) {
        if let index = self.chartCollectionView.indexPath(for: cell) {
            self.chartCollectionView.scrollToItem(at: IndexPath(item: index.item - 1, section: 0), at: .centeredVertically, animated: true)
        }
    }
}

// MARK: - Helpers
extension S5HeartRateDetailTableViewCell {
    private func reloadHrDetailCLVCell() {
        DispatchQueue.main.async {
            self.chartCollectionView.reloadData()
        }
    }
}
