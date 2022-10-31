//
//  ScaleResultCollectionChart.swift
//  1SKConnect
//
//  Created by Elcom Corp on 05/11/2021.
//

import UIKit

class ScaleResultCollectionChart: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var standarLabel: UILabel!

    @IBOutlet weak var firstVerticalView: UIView!
    @IBOutlet weak var lastVerticalView: UIView!
    @IBOutlet weak var firstHorizontalView: UIView!
    @IBOutlet weak var lastHorizontalView: UIView!

    @IBOutlet weak var resultCollectionView: UICollectionView!

    var dataSource = BodyTypeDataSource.shared.dataSource
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// Setup default value
    func commonInit() {
        let nib = UINib(nibName: "ScaleResultCollectionChart", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        self.resultCollectionView.registerNib(ofType: BodyTypeCollecionViewCell.self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        [self.fatLabel, highLabel, standarLabel, lowLabel].forEach { $0?.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2) }
        self.firstVerticalView.roundCorner(corners: [.topLeft, .topRight], radius: 3)
        self.lastVerticalView.roundCorner(corners: [.bottomLeft, .bottomRight], radius: 3)

        self.firstHorizontalView.roundCorner(corners: [.topLeft, .bottomLeft], radius: 3)
        self.lastHorizontalView.roundCorner(corners: [.topRight, .bottomRight], radius: 3)
    }

    func setUpView(bodyFat: BodyFat) {
        for i in 0 ..< self.dataSource.count where dataSource[i].bodyType == bodyFat.bodyType.value {
            self.dataSource[i].isSelected = true
        }
    }
}

// MARK: UICollectionViewDelegate
extension ScaleResultCollectionChart: UICollectionViewDelegate {

}

// MARK: UICollectionViewDataSource
extension ScaleResultCollectionChart: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeuCell(ofType: BodyTypeCollecionViewCell.self, for: indexPath)
        cell.dataSource = dataSource[indexPath.item]
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ScaleResultCollectionChart: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 78
        let padding: CGFloat = 4
        let width: CGFloat = (collectionView.frame.width - padding * 2) / 3
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
