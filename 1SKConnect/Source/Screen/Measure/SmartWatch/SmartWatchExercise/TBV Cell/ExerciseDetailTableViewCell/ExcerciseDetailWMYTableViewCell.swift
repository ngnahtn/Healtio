//
//  ExcerciseDetailWMYTableViewCell.swift
//  1SKConnect
//
//  Created by admin on 20/12/2021.
//

import UIKit
import RealmSwift

struct S5WMYExcerciseDetail {
    var timeType: TimeFilterType
    var stepList: StepListRecordModel?
}

class ExcerciseDetailWMYTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var chartCollectionView: UICollectionView!

    var shadowLayer: CAShapeLayer?

    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let sportListModelDAO = GenericDAO<S5SportListRecordModel>()
    var sportNotificationToken: NotificationToken?
    var sportListRecords: [S5SportRecordModel]?

    var model: S5WMYExcerciseDetail? {
        didSet {
            self.setChartData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerStepAndSportToken()
        self.setUpView()
        self.setUpCollectionView()
    }

    // registerToken
    private func registerStepAndSportToken() {
        self.sportListModelDAO.registerToken(token: &self.sportNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onSportListChange()
        }
    }
    
    deinit {
        self.sportNotificationToken?.invalidate()
    }
// MARK: - SetUpView
    private func setUpView() {
        self.selectionStyle = .none
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

    private func setUpCollectionView() {
        self.chartCollectionView.delegate = self
        self.chartCollectionView.dataSource = self
        self.chartCollectionView.registerNib(ofType: ExcerciseChartCLVCell.self)
    }
}

// MARK: - Helpers
extension ExcerciseDetailWMYTableViewCell {

    private func onSportListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let sportList = self.sportListModelDAO.getObject(with: profile.id) {
            self.sportListRecords = sportList.sportList.array
        }
    }

    // handleData for barChart
    private func setChartData() {
        guard let model = self.model else { return }
        guard let stepList = model.stepList else {
            self.chartCollectionView.reloadData()
            return
        }
        DispatchQueue.main.async {
            self.chartCollectionView.reloadData()
            if model.timeType == .week || model.timeType == .month {
                self.chartCollectionView.scrollToItem(at: IndexPath(item: stepList.getGraphData(of: model.timeType).count - 1, section: 0), at: .centeredHorizontally, animated: false)
            } else {
                self.chartCollectionView.scrollToItem(at: IndexPath(item: stepList.getYearGarphData(of: model.timeType).count - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
}
// MARK: - UICollectionViewDelegate
extension ExcerciseDetailWMYTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.chartCollectionView.frame.width, height: self.chartCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ExcerciseDetailWMYTableViewCell: UICollectionViewDelegateFlowLayout {}

// MARK: - UICollectionViewDataSource
extension ExcerciseDetailWMYTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let unwrappedModel = self.model else { return 1 }
        guard let data = unwrappedModel.stepList else {
            return 1
        }
        if unwrappedModel.timeType == .day {
            return 1
        } else if unwrappedModel.timeType == .year {
            return data.getYearGarphData(of: unwrappedModel.timeType).count
        } else {
            return data.getGraphData(of: unwrappedModel.timeType).count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeuCell(ofType: ExcerciseChartCLVCell.self, for: indexPath)
        guard let model = self.model else { return cell }
        guard let data = model.stepList else {
            cell.timeType = model.timeType
            return cell
        }
        cell.delegate = self
        cell.timeType = model.timeType
        if model.timeType == .week {
            cell.icNextImageView.isHidden = indexPath.item == data.getGraphData(of: model.timeType).count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.models = data.getGraphData(of: model.timeType)[indexPath.row]
        }
        if model.timeType == .month {
            cell.icNextImageView.isHidden = indexPath.item == data.getGraphData(of: model.timeType).count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.monthModels = data.getGraphData(of: model.timeType)[indexPath.row]
        }
        if model.timeType == .year {
            cell.icNextImageView.isHidden = indexPath.item == data.getYearGarphData(of: model.timeType).count - 1
            cell.icPreviousImageView.isHidden = indexPath.item == 0
            cell.yearModels = data.getYearGarphData(of: .year)[indexPath.item]
        }
        return cell
    }
}

// MARK: - ExcerciseChartCLVCellDelegate
extension ExcerciseDetailWMYTableViewCell: ExcerciseChartCLVCellDelegate {
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
