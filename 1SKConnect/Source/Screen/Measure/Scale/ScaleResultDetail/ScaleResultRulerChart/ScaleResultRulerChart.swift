//
//  ScaleResultRulerChart.swift
//  1SKConnect
//
//  Created by Elcom Corp on 03/11/2021.
//

import UIKit

class ScaleResultRulerChart: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var valueSlider: UISlider!

    // first view
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var firstLineView: UIView!
    @IBOutlet weak var firstValueLabel: UILabel!
    @IBOutlet weak var firstDescriptionLabel: UILabel!
    @IBOutlet weak var firstViewWidthConstraint: NSLayoutConstraint!

    // second view
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var secondLineView: UIView!
    @IBOutlet weak var secondValueLabel: UILabel!
    @IBOutlet weak var secondDescriptionLabel: UILabel!
    @IBOutlet weak var secondViewWidthConstraint: NSLayoutConstraint!

    // third view
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var thirdLineView: UIView!
    @IBOutlet weak var thirdValueLabel: UILabel!
    @IBOutlet weak var thirdDesctiptionLabel: UILabel!
    @IBOutlet weak var thirdViewWidthConstraint: NSLayoutConstraint!

    // fourth view
    @IBOutlet weak var fourthView: UIView!
    @IBOutlet weak var fourthLineView: UIView!
    @IBOutlet weak var fourthValueLabel: UILabel!
    @IBOutlet weak var fourthDescriptionLabel: UILabel!
    @IBOutlet weak var fourthViewWidthConstraint: NSLayoutConstraint!

    // last view
    @IBOutlet weak var lastView: UIView!
    @IBOutlet weak var lastLineView: UIView!
    @IBOutlet weak var lastDesctiptionLabel: UILabel!
    @IBOutlet weak var lastViewWidthConstraint: NSLayoutConstraint!

    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        self.valueSlider.setThumbImage(R.image.ic_thumb_image()!, for: .normal)
        self.firstLineView.roundCorner(corners: [.topLeft, .bottomLeft], radius: 3)
        self.lastLineView.roundCorner(corners: [.topRight, .bottomRight], radius: 3)
    }
}

// MARK: Helpers
extension ScaleResultRulerChart {
    /// Setup default value
    func commonInit() {
        let nib = UINib(nibName: "ScaleResultRulerChart", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }

    func setUpView(with item: DetailsItemProtocol, bodyFat: BodyFat) {
        DispatchQueue.main.async {
            switch item {
            case is Bmi:
                self.setUpBmiView(with: item)
            case is Bmr:
                self.setUpBmrView(with: item, bodyFat: bodyFat)
            case is Muscle:
                self.setUpMuscleView(with: item, bodyFat: bodyFat)
            case is BoneMass:
                self.setUpBoneView(with: item, bodyFat: bodyFat)
            case is Water:
                self.setUpWaterView(with: item, bodyFat: bodyFat)
            case is Protein:
                self.setUpProteinView(with: item, bodyFat: bodyFat)
            case is Fat:
                self.setUpFatView(with: item, bodyFat: bodyFat)
            case is Obesity:
                self.setUpObesityView(with: item)
            case is VFat:
                self.setUpVFatView(with: item)
            case is SubcutaneousFat:
                self.setUpSubcutaneousFatView(with: item, bodyFat: bodyFat)
            case is LBW:
                print("LBW")
            case is BodyType:
                print("BodyType")
            case is BodyStandard:
                print("BodyStandard")
            default:
                print("")
            }
        }
    }

    func setUpBmiView(with item: DetailsItemProtocol) {
        self.thirdView.isHidden = true
        [self.firstViewWidthConstraint, self.secondViewWidthConstraint, self.fourthViewWidthConstraint, self.lastViewWidthConstraint].forEach { $0?.constant = self.frame.width / 4 }
        self.firstLineView.backgroundColor = R.color.thin()
        self.secondLineView.backgroundColor = R.color.standard()
        self.fourthLineView.backgroundColor = R.color.overweight()
        self.lastLineView.backgroundColor = R.color.overweight1()
        let labelValueArray = [firstValueLabel, secondValueLabel, fourthValueLabel]
        if labelValueArray.count == item.valueScale.count {
            for i in 0 ..< item.valueScale.count {
                labelValueArray[i]?.text = item.valueScale[i].toString()
            }
        }

        let labelDescriptionArray = [firstDescriptionLabel, secondDescriptionLabel, fourthDescriptionLabel, lastDesctiptionLabel]
        if labelDescriptionArray.count == item.descriptionSacle.count {
            for i in 0 ..< item.descriptionSacle.count {
                labelDescriptionArray[i]?.text = item.descriptionSacle[i]
            }
        }

        self.valueSlider.minimumValue = Float(item.minValue)
        self.valueSlider.maximumValue = Float(item.maxValue)
        self.valueSlider.value = Float(item.value)
    }

    func setUpBmrView(with item: DetailsItemProtocol, bodyFat: BodyFat) {
        guard let impedance = bodyFat.impedance.value, impedance != 0 else {
            self.isHidden = true
            return
        }
        [self.secondView, self.thirdView, self.fourthView].forEach { $0?.isHidden = true }
        [self.firstViewWidthConstraint, self.lastViewWidthConstraint].forEach { $0?.constant = self.frame.width / 2 }
        self.firstLineView.backgroundColor = R.color.thin()
        self.lastLineView.backgroundColor = R.color.standard()
        let labelArray = [firstValueLabel]

        if bodyFat.bmrRange.array.isEmpty {
            return
        }

        if labelArray.count == item.valueScale.count {
            for i in 0 ..< bodyFat.bmrRange.array.count {
                labelArray[i]?.text = bodyFat.bmrRange.array[i].toString()
            }
        }

        let labelDescriptionArray = [firstDescriptionLabel, lastDesctiptionLabel]
        if labelDescriptionArray.count == item.descriptionSacle.count {
            for i in 0 ..< item.descriptionSacle.count {
                labelDescriptionArray[i]?.text = item.descriptionSacle[i]
            }
        }

        self.valueSlider.minimumValue = Float(0)
        self.valueSlider.maximumValue = Float(bodyFat.bmrRange.array[0] * 2)
        self.valueSlider.value = Float(item.value)
    }

    func setUpMuscleView(with item: DetailsItemProtocol, bodyFat: BodyFat) {
        guard let impedance = bodyFat.impedance.value, impedance != 0 else {
            self.isHidden = true
            return
        }
        [self.secondView, self.fourthView].forEach { $0?.isHidden = true }
        [self.firstViewWidthConstraint, self.thirdViewWidthConstraint, self.lastViewWidthConstraint].forEach { $0?.constant = self.frame.width / 3 }
        self.firstLineView.backgroundColor = R.color.thin()
        self.thirdLineView.backgroundColor = R.color.standard()
        self.lastLineView.backgroundColor = R.color.good()
        let labelArray = [firstValueLabel, thirdValueLabel]

        if bodyFat.weithOfMuscleRange.array.isEmpty {
            return
        }

        if labelArray.count == bodyFat.weithOfMuscleRange.array.count {
            for i in 0 ..< bodyFat.weithOfMuscleRange.array.count {
                labelArray[i]?.text = bodyFat.weithOfMuscleRange.array[i].toString()
            }
        }

        let labelDescriptionArray = [firstDescriptionLabel, thirdDesctiptionLabel, lastDesctiptionLabel]
        if labelDescriptionArray.count == item.descriptionSacle.count {
            for i in 0 ..< item.descriptionSacle.count {
                labelDescriptionArray[i]?.text = item.descriptionSacle[i]
            }
        }

        let tempData = bodyFat.weithOfMuscleRange.array[1] - bodyFat.weithOfMuscleRange.array[0]
        self.valueSlider.minimumValue = Float(bodyFat.weithOfMuscleRange.array[0] - tempData)
        self.valueSlider.maximumValue = Float(bodyFat.weithOfMuscleRange.array[1] + tempData)
        self.valueSlider.value = Float(item.value)
    }

    func setUpBoneView(with item: DetailsItemProtocol, bodyFat: BodyFat) {
        guard let impedance = bodyFat.impedance.value, impedance != 0 else {
            self.isHidden = true
            return
        }
        [self.secondView, self.fourthView].forEach { $0?.isHidden = true }
        [self.firstViewWidthConstraint, self.thirdViewWidthConstraint, self.lastViewWidthConstraint].forEach { $0?.constant = self.frame.width / 3 }
        self.firstLineView.backgroundColor = R.color.thin()
        self.thirdLineView.backgroundColor = R.color.standard()
        self.lastLineView.backgroundColor = R.color.good()
        let labelArray = [firstValueLabel, thirdValueLabel]

        if bodyFat.weightOfBoneRange.array.isEmpty {
            return
        }

        if labelArray.count == bodyFat.weightOfBoneRange.array.count {
            for i in 0 ..< bodyFat.weightOfBoneRange.array.count {
                labelArray[i]?.text = bodyFat.weightOfBoneRange.array[i].toString()
            }
        }

        let labelDescriptionArray = [firstDescriptionLabel, thirdDesctiptionLabel, lastDesctiptionLabel]
        if labelDescriptionArray.count == item.descriptionSacle.count {
            for i in 0 ..< item.descriptionSacle.count {
                labelDescriptionArray[i]?.text = item.descriptionSacle[i]
            }
        }

        let tempData = bodyFat.weightOfBoneRange.array[1] - bodyFat.weightOfBoneRange.array[0]
        self.valueSlider.minimumValue = Float(bodyFat.weightOfBoneRange.array[0] - tempData)
        self.valueSlider.maximumValue = Float(bodyFat.weightOfBoneRange.array[1] + tempData)
        self.valueSlider.value = Float(item.value)
    }

    func setUpWaterView(with item: DetailsItemProtocol, bodyFat: BodyFat) {
        guard let impedance = bodyFat.impedance.value, impedance != 0 else {
            self.isHidden = true
            return
        }
        [self.secondView, self.fourthView].forEach { $0?.isHidden = true }
        [self.firstViewWidthConstraint, self.thirdViewWidthConstraint, self.lastViewWidthConstraint].forEach { $0?.constant = self.frame.width / 3 }
        self.firstLineView.backgroundColor = R.color.thin()
        self.thirdLineView.backgroundColor = R.color.standard()
        self.lastLineView.backgroundColor = R.color.good()
        let labelArray = [firstValueLabel, thirdValueLabel]

        if bodyFat.ratioOfWaterRange.array.isEmpty {
            return
        }

        if labelArray.count == bodyFat.ratioOfWaterRange.array.count {
            for i in 0 ..< bodyFat.ratioOfWaterRange.array.count {
                labelArray[i]?.text = "\(bodyFat.ratioOfWaterRange.array[i].toString())%"
            }
        }

        let labelDescriptionArray = [firstDescriptionLabel, thirdDesctiptionLabel, lastDesctiptionLabel]
        if labelDescriptionArray.count == item.descriptionSacle.count {
            for i in 0 ..< item.descriptionSacle.count {
                labelDescriptionArray[i]?.text = item.descriptionSacle[i]
            }
        }

        let tempData = bodyFat.ratioOfWaterRange.array[1] - bodyFat.ratioOfWaterRange.array[0]
        self.valueSlider.minimumValue = Float(bodyFat.ratioOfWaterRange.array[0] - tempData)
        self.valueSlider.maximumValue = Float(bodyFat.ratioOfWaterRange.array[1] + tempData)
        self.valueSlider.value = Float(item.value)
    }

    func setUpProteinView(with item: DetailsItemProtocol, bodyFat: BodyFat) {
        guard let impedance = bodyFat.impedance.value, impedance != 0 else {
            self.isHidden = true
            return
        }
        [self.secondView, self.fourthView].forEach { $0?.isHidden = true }
        [self.firstViewWidthConstraint, self.thirdViewWidthConstraint, self.lastViewWidthConstraint].forEach { $0?.constant = self.frame.width / 3 }
        self.firstLineView.backgroundColor = R.color.thin()
        self.thirdLineView.backgroundColor = R.color.standard()
        self.lastLineView.backgroundColor = R.color.high()
        let labelArray = [firstValueLabel, thirdValueLabel]
        if labelArray.count == bodyFat.ratioOfProteinRange.array.count {
            for i in 0 ..< bodyFat.ratioOfProteinRange.array.count {
                labelArray[i]?.text = "\(bodyFat.ratioOfProteinRange.array[i].toString())%"
            }
        }

        let labelDescriptionArray = [firstDescriptionLabel, thirdDesctiptionLabel, lastDesctiptionLabel]
        if labelDescriptionArray.count == item.descriptionSacle.count {
            for i in 0 ..< item.descriptionSacle.count {
                labelDescriptionArray[i]?.text = item.descriptionSacle[i]
            }
        }

        let tempData = bodyFat.ratioOfProteinRange.array[1] - bodyFat.ratioOfProteinRange.array[0]
        self.valueSlider.minimumValue = Float(bodyFat.ratioOfProteinRange.array[0] - tempData)
        self.valueSlider.maximumValue = Float(bodyFat.ratioOfProteinRange.array[1] + tempData)
        self.valueSlider.value = Float(item.value)
    }

    func setUpFatView(with item: DetailsItemProtocol, bodyFat: BodyFat) {
        guard let impedance = bodyFat.impedance.value, impedance != 0 else {
            self.isHidden = true
            return
        }
        [self.secondView, self.fourthView].forEach { $0?.isHidden = true }
        self.firstLineView.backgroundColor = R.color.overweight()
        self.thirdLineView.backgroundColor = R.color.standard()
        self.lastLineView.backgroundColor = R.color.overweight2()
        let labelArray = [firstValueLabel, thirdValueLabel]
        if bodyFat.ratioOfFatRange.array.isEmpty {
            return
        }

        for i in 0 ..< labelArray.count {
            labelArray[i]?.text = "\(bodyFat.ratioOfFatRange.array[i].toString())%"
        }

        let labelDescriptionArray = [firstDescriptionLabel, thirdDesctiptionLabel, lastDesctiptionLabel]
        for i in 0 ..< labelDescriptionArray.count {
            labelDescriptionArray[i]?.text = item.descriptionSacle[i]
        }

        let tempData = bodyFat.ratioOfFatRange.array[1] - bodyFat.ratioOfFatRange.array[0]
        let minData = bodyFat.ratioOfFatRange.array[0] - tempData < 0 ? 0 : bodyFat.ratioOfFatRange.array[0] - tempData
        let maxData = bodyFat.ratioOfFatRange.array[1] + tempData
        let valueRange = maxData - minData

        self.firstViewWidthConstraint.constant = (bodyFat.ratioOfFatRange.array[0] - minData) / valueRange * self.frame.width
        self.thirdViewWidthConstraint.constant = (bodyFat.ratioOfFatRange.array[1] - bodyFat.ratioOfFatRange.array[0]) / valueRange * self.frame.width
        self.lastViewWidthConstraint.constant = (maxData - bodyFat.ratioOfFatRange.array[1]) / valueRange * self.frame.width

        self.valueSlider.minimumValue = Float(minData)
        self.valueSlider.maximumValue = Float(maxData)
        self.valueSlider.value = Float(item.value)
    }

    func setUpObesityView(with item: DetailsItemProtocol) {
        let labelArray = [firstValueLabel, secondValueLabel, thirdValueLabel, fourthValueLabel]
        [self.firstViewWidthConstraint, self.secondViewWidthConstraint, self.thirdViewWidthConstraint, self.fourthViewWidthConstraint, self.lastViewWidthConstraint].forEach { $0?.constant = self.frame.width / 5 }
        if labelArray.count == item.valueScale.count {
            for i in 0 ..< item.valueScale.count {
                labelArray[i]?.text = item.valueScale[i].toString()
            }
        }

        let labelDescriptionArray = [firstDescriptionLabel, secondDescriptionLabel, thirdDesctiptionLabel, fourthDescriptionLabel, lastDesctiptionLabel]
        if labelDescriptionArray.count == item.descriptionSacle.count {
            for i in 0 ..< item.descriptionSacle.count {
                labelDescriptionArray[i]?.text = item.descriptionSacle[i]
            }
        }

        self.valueSlider.minimumValue = Float(item.minValue)
        self.valueSlider.maximumValue = Float(item.maxValue)
        self.valueSlider.value = Float(item.value)
    }

    func setUpVFatView(with item: DetailsItemProtocol) {
        [self.secondView, self.fourthView].forEach { $0?.isHidden = true }
        [self.firstViewWidthConstraint, self.thirdViewWidthConstraint, self.lastViewWidthConstraint].forEach { $0?.constant = self.frame.width / 3 }
        self.firstLineView.backgroundColor = R.color.standard()
        self.thirdLineView.backgroundColor = R.color.overweight1()
        self.lastLineView.backgroundColor = R.color.overweight2()
        let labelArray = [firstValueLabel, thirdValueLabel]
        if labelArray.count == item.valueScale.count {
            for i in 0 ..< item.valueScale.count {
                labelArray[i]?.text = "\(item.valueScale[i].toString())"
            }
        }

        let labelDescriptionArray = [firstDescriptionLabel, thirdDesctiptionLabel, lastDesctiptionLabel]
        if labelDescriptionArray.count == item.descriptionSacle.count {
            for i in 0 ..< item.descriptionSacle.count {
                labelDescriptionArray[i]?.text = item.descriptionSacle[i]
            }
        }

        self.valueSlider.minimumValue = Float(item.minValue)
        self.valueSlider.maximumValue = Float(item.maxValue)
        self.valueSlider.value = Float(item.value)
    }

    func setUpSubcutaneousFatView(with item: DetailsItemProtocol, bodyFat: BodyFat) {
        guard let impedance = bodyFat.impedance.value, impedance != 0 else {
            self.isHidden = true
            return
        }

        [self.secondView].forEach { $0?.isHidden = true }
        self.firstLineView.backgroundColor = R.color.thin()
        self.thirdLineView.backgroundColor = R.color.standard()
        self.fourthLineView.backgroundColor = R.color.overweight1()
        self.lastLineView.backgroundColor = R.color.overweight2()
        let labelArray = [firstValueLabel, thirdValueLabel, fourthValueLabel]
        if labelArray.count == bodyFat.ratioOfSubcutaneousFatRange.array.count {
            for i in 0 ..< bodyFat.ratioOfSubcutaneousFatRange.array.count {
                labelArray[i]?.text = "\(bodyFat.ratioOfSubcutaneousFatRange.array[i].toString())%"
            }
        }

        let labelDescriptionArray = [firstDescriptionLabel, thirdDesctiptionLabel, fourthDescriptionLabel, lastDesctiptionLabel]
        if labelDescriptionArray.count == item.descriptionSacle.count {
            for i in 0 ..< item.descriptionSacle.count {
                labelDescriptionArray[i]?.text = item.descriptionSacle[i]
            }
        }

        let tempData = bodyFat.ratioOfSubcutaneousFatRange.array[1] - bodyFat.ratioOfSubcutaneousFatRange.array[0]
        let minData = bodyFat.ratioOfSubcutaneousFatRange.array[0] - tempData < 0 ? 0 : bodyFat.ratioOfSubcutaneousFatRange.array[0] - tempData
        let maxData = bodyFat.ratioOfSubcutaneousFatRange.array[bodyFat.ratioOfSubcutaneousFatRange.array.count - 1] + tempData
        let valueRange = maxData - minData

        self.firstViewWidthConstraint.constant = (bodyFat.ratioOfSubcutaneousFatRange.array[0] - minData) / valueRange * self.frame.width
        self.thirdViewWidthConstraint.constant = (bodyFat.ratioOfSubcutaneousFatRange.array[1] - bodyFat.ratioOfSubcutaneousFatRange.array[0]) / valueRange * self.frame.width
        self.fourthViewWidthConstraint.constant = (bodyFat.ratioOfSubcutaneousFatRange.array[2] - bodyFat.ratioOfSubcutaneousFatRange.array[1]) / valueRange * self.frame.width
        self.lastViewWidthConstraint.constant = (maxData - bodyFat.ratioOfSubcutaneousFatRange.array[2]) / valueRange * self.frame.width

        self.valueSlider.minimumValue = Float(minData)
        self.valueSlider.maximumValue = Float(maxData)
        self.valueSlider.value = Float(item.value)
    }
}
