//
//  MarkerView.swift
//  1SKConnect
//
//  Created by TrungDN on 19/11/2021.
//

import UIKit
import Charts

class SpO2MarkerView: MarkerView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }

    private func initUI() {
        Bundle.main.loadNibNamed("SpO2MarkerView", owner: self, options: nil)
        addSubview(contentView)
    }
}
