//
//  S5BloodPressureDetailTableViewCell.swift
//  1SKConnect
//
//  Created by TrungDN on 27/12/2021.
//

import UIKit
import RealmSwift

struct S5BloodPressureDetail {
    var timeType: TimeFilterType
    var dataValues: BloodPressureListRecordModel?
}

class S5BloodPressureDetailTableViewCell: UITableViewCell {
    var shadowLayer: CAShapeLayer?
    @IBOutlet weak var chartCollectionView: UICollectionView!
    @IBOutlet weak var shadowView: UIView!
    
    var model: S5BloodPressureDetail? {
        didSet {
            guard let records = model?.dataValues?.bloodPressureList.array else {
                self.records = []
                return
            }
            self.records = records
        }
    }
    
    var records: [BloodPressureRecordModel] = [] {
        didSet {
            if !records.isEmpty {
                if let date = records[0].dateTime.toDate(.ymd) {
                    if date.isInToday == false {
                        self.records.insert(BloodPressureRecordModel(), at: 0)
                    }
                }
            }
            self.reloadChartDetailCLVCell()
            self.setChartData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpView()
    }
    
    private func setUpView() {
        self.selectionStyle = .none
        self.chartCollectionView.delegate = self
        self.chartCollectionView.dataSource = self
        self.chartCollectionView.registerNib(ofType: S5BloodPressureChartCollectionViewCell.self)
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
        guard let data = model.dataValues else { return }
        DispatchQueue.main.async {
            self.chartCollectionView.reloadData()
            if model.timeType == .day {
                self.chartCollectionView.scrollToItem(at: IndexPath(item: self.records.count - 1, section: 0), at: .centeredHorizontally, animated: false)
            } else {
                self.chartCollectionView.scrollToItem(at: IndexPath(item: data.getGraphData(of: model.timeType).count - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - UICollectionViewDelegate
extension S5BloodPressureDetailTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.chartCollectionView.frame.width, height: self.chartCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension S5BloodPressureDetailTableViewCell: UICollectionViewDelegateFlowLayout {}

// MARK: - UICollectionViewDataSource
extension S5BloodPressureDetailTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = self.model else { return 1 }
        guard let data = model.dataValues else { return 1 }
        if model.timeType == .day {
            if self.records.isEmpty { return 1}
            return records.count
        } else if model.timeType == .year {
            return data.getYearGarphData(of: model.timeType).count
        } else {
            return data.getGraphData(of: model.timeType).count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeuCell(ofType: S5BloodPressureChartCollectionViewCell.self, for: indexPath)
        guard let model = self.model else { return cell }
        guard let data = model.dataValues else {
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
            cell.icNextImageView.isHidden = indexPath.item == data.getGraphData(of: model.timeType).count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.weakModel = data.getGraphData(of: model.timeType)[indexPath.item]
        } else if model.timeType == .month {
            cell.icNextImageView.isHidden = indexPath.item == data.getGraphData(of: model.timeType).count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.monthModel = data.getGraphData(of: model.timeType)[indexPath.item]
        } else {
            cell.icNextImageView.isHidden = indexPath.item == data.getYearGarphData(of: model.timeType).count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.yearModel = data.getYearGarphData(of: model.timeType)[indexPath.item]
        }
        return cell
    }
}

extension S5BloodPressureDetailTableViewCell: S5BloodPressureChartCollectionViewCellDelegate {
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
extension S5BloodPressureDetailTableViewCell {
    private func reloadChartDetailCLVCell() {
        DispatchQueue.main.async {
            self.chartCollectionView.reloadData()
        }
    }
}

