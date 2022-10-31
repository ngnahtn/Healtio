//
//  WeightDetailsView.swift
//  1SKConnect
//
//  Created by tuyenvx on 07/04/2021.
//

import Foundation
import UIKit

protocol WeightDetailsViewDelegate: AnyObject {
    func didSelect(cell inRect: CGRect, item: DetailsItemProtocol)
}

class WeightDetailsView: UIView {
    @IBInspectable var leading: CGFloat {
        get {
            return leadingOffset
        }

        set {
            leadingOffset = newValue
        }
    }

    private lazy var weightDetailsCollectionView: UICollectionView
        = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let itemSpacing: CGFloat = 8
    private let lineSpacing: CGFloat = 10
    private var leadingOffset: CGFloat = 16
    private let cellHeight: CGFloat = 109
    private let headerHeight: CGFloat = 10
    private let footerHeight: CGFloat = 5

    var items: [DetailsItemProtocol] = []

    weak var delegate: WeightDetailsViewDelegate?

    var numberOfItemPerRow: Int {
        let collectionViewWidth = Constant.Screen.width - leadingOffset * 2
        let numberOfItem = Int(collectionViewWidth / cellHeight)
        if CGFloat(numberOfItem) * cellHeight + itemSpacing * CGFloat(numberOfItem - 1) > collectionViewWidth {
            return numberOfItem - 1
        } else {
            return numberOfItem
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func commonSetup() {
        addSubview(weightDetailsCollectionView)
        weightDetailsCollectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        layoutIfNeeded()
        setupWeightDetailsCollectionView()
    }

    private func setupWeightDetailsCollectionView() {
        weightDetailsCollectionView.delegate = self
        weightDetailsCollectionView.dataSource = self
        weightDetailsCollectionView.registerNib(ofType: WeightDetailsCollectionViewCell.self)
        weightDetailsCollectionView.showsHorizontalScrollIndicator = false
        weightDetailsCollectionView.showsVerticalScrollIndicator = false
        weightDetailsCollectionView.isScrollEnabled = true
        weightDetailsCollectionView.backgroundColor = .white
        weightDetailsCollectionView.contentInset = UIEdgeInsets.zero
    }

    func reloadData(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            self.weightDetailsCollectionView.reloadData()
        }, completion: { _ in
            completion()
        })
    }

    func getHeight() -> CGFloat {
        var numberOfRow = CGFloat(items.count / numberOfItemPerRow)
        if items.count % 3 != 0 {
            numberOfRow += 1
        }
        return numberOfRow * cellHeight + (numberOfRow - 1) * lineSpacing + headerHeight + footerHeight
    }
}
// MARK: - UICollectionView DataSource
extension WeightDetailsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeuCell(ofType: WeightDetailsCollectionViewCell.self, for: indexPath)
        cell.config(with: items[indexPath.row])
        return cell
    }
}
// MARK: - UICollectionView Delegate
extension WeightDetailsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let `numberOfItemPerRow` = CGFloat(self.numberOfItemPerRow)
        return CGSize(width: (Constant.Screen.width - (numberOfItemPerRow - 1) * itemSpacing - 2 * leadingOffset) / numberOfItemPerRow,
        height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // get the selected cell frame.
        collectionView.deselectItem(at: indexPath, animated: true)
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        let cellRect = attributes?.frame
        let cellFrameInSuperview = collectionView.convert(cellRect ?? CGRect.zero, to: collectionView.superview?.superview?.superview?.superview)

        // call delegate function.
        delegate?.didSelect(cell: cellFrameInSuperview, item: items[indexPath.row])
    }
}
