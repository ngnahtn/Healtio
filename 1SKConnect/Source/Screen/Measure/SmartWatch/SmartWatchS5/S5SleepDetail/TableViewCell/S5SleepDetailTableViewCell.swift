//
//  S5SleepDetailTableViewCell.swift
//  1SKConnect
//
//  Created by Be More on 11/01/2022.
//

import UIKit

struct S5SleepDetail {
    var timeType: TimeFilterType
    var dataValues: SleepListRecordModel?
}

class S5SleepDetailTableViewCell: UITableViewCell {

    var shadowLayer: CAShapeLayer?
    @IBOutlet weak var chartCollectionView: UICollectionView!
    @IBOutlet weak var shadowView: UIView!
    
    var model: S5SleepDetail? {
        didSet {
            guard let data = model?.dataValues?.sleepList.array else {
                self.records = []
                return
            }
            self.records = data
        }
    }
    
    var records: [SleepRecordModel] = [] {
        didSet {
            if !records.isEmpty {
                if let date = records[0].dateTime.toDate(.ymd) {
                    if date.isInToday == false {
                        self.records.insert(SleepRecordModel(), at: 0)
                    }
                }
            }
            self.setChartData()
        }
    }
    
    private func setChartData() {
        guard let model = self.model else { return }
        guard let data = model.dataValues else {
            DispatchQueue.main.async {
                self.chartCollectionView.reloadData()
            }
            return
        }
        DispatchQueue.main.async {
            self.chartCollectionView.reloadData()
            if model.timeType == .day {
                self.chartCollectionView.scrollToItem(at: IndexPath(item: self.records.count - 1, section: 0), at: .centeredHorizontally, animated: false)
            } else {
                self.chartCollectionView.scrollToItem(at: IndexPath(item: data.getGraphData(of: model.timeType).count - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setUpView() {
        self.selectionStyle = .none
        self.chartCollectionView.delegate = self
        self.chartCollectionView.dataSource = self
        self.chartCollectionView.registerNib(ofType: S5SleepChartCollectionViewCell.self)
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

// MARK: - UICollectionViewDelegate
extension S5SleepDetailTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.chartCollectionView.frame.width, height: self.chartCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension S5SleepDetailTableViewCell: UICollectionViewDelegateFlowLayout {}

// MARK: - UICollectionViewDataSource
extension S5SleepDetailTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = self.model else { return 1 }
        guard let data = model.dataValues else { return 1 }
        if model.timeType == .day {
            if records.isEmpty { return 1 }
            return records.count
        } else if model.timeType == .year {
            return data.getYearGarphData(of: model.timeType).count
        } else {
            return data.getGraphData(of: model.timeType).count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeuCell(ofType: S5SleepChartCollectionViewCell.self, for: indexPath)
        cell.delegate = self
        guard let model = self.model else { return cell }
        guard let data = model.dataValues else {
            cell.timeType = model.timeType
            return cell
        }
        if model.timeType == .day {
            cell.icNextImageView.isHidden = indexPath.item == self.records.count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.dayModel = self.records.reversed()[indexPath.row]
//            cell.dayModel = data.sleepList.array.reversed()[indexPath.item]
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

extension S5SleepDetailTableViewCell: S5SleepChartCollectionViewCellDelegate {
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
