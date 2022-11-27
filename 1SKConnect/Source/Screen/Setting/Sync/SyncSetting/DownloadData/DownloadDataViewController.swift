//
//  DownloadDataViewController.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import UIKit
import GoogleSignIn

protocol DownloadDataViewControllerDelegate: AnyObject {
    func handleDownloadData(needDownload: Bool)
}

class DownloadDataViewController: BaseViewController {
    @IBOutlet weak var linkView: UIView!
    private var index: IndexPath?
    @IBOutlet weak var scaleView: UIView!
    @IBOutlet weak var spO2View: UIView!
    private var viewType = 0
    @IBOutlet weak var scaleTimeLabel: UILabel!
    @IBOutlet weak var spO2TimeLabel: UILabel!

    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    let viewDefaultHeigh: CGFloat = 435

    private var needDownloadData: Bool = true
    var delegate: DownloadDataViewControllerDelegate?
    
    private var scaleMonths = 6
    private var significanceMonths = 1

    init(with index: IndexPath) {
        super.init(nibName: "DownloadDataViewController", bundle: nil)
        self.index = index
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scaleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectMonth(_:))))
        self.spO2View.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectMonth(_:))))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentView()
    }

    @objc private func handleSelectMonth(_ sender: UITapGestureRecognizer) {
        if sender.view == self.scaleView {
            self.viewType = 0
        } else {
            self.viewType = 1
        }
        self.showPicker(with: .month)
    }

    @IBAction func handleConfirmDowload(_ sender: UIButton) {
        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let index = index, let currentProfile = profileListDAO.getFirstObject()?.profiles[index.row] else {
            return
        }
        profileListDAO.update {
            currentProfile.scaleDowloadMonths.value = self.scaleMonths
            currentProfile.spO2DowloadMonths.value = self.significanceMonths
            currentProfile.needDowloadData = true
        }
        self.needDownloadData = true
        self.dismissView()
    }

    @IBAction func handleClose(_ sender: UIButton) {
        self.needDownloadData = false
        self.dismissView()
    }
}

// MARK: - Helpers
extension DownloadDataViewController {
    private func showPicker(with type: SelectionType) {
        let pickerViewController = PickerViewController.loadFromNib()
        pickerViewController.modalPresentationStyle = .overFullScreen
        pickerViewController.type = type
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: false, completion: nil)
    }

    private func presentView() {
        UIView.animate(withDuration: 0.1) {
            self.viewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    private func dismissView() {
        UIView.animate(withDuration: 0.1) {
            self.viewBottomConstraint.constant = -self.viewDefaultHeigh
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.delegate?.handleDownloadData(needDownload: self.needDownloadData)
            self.dismiss(animated: false, completion: nil)
        }
    }
}

// MARK: - PickerViewControllerDelegate
extension DownloadDataViewController: PickerViewControllerDelegate {
    func pickerDidPickValue(of type: SelectionType, at index: Int) {
        if self.viewType == 0 {
            self.scaleMonths = Int(MonthGroup.allCases[index].value) ?? 6
            self.scaleTimeLabel.text = MonthGroup.allCases[index].rawValue
        } else {
            self.significanceMonths = Int(MonthGroup.allCases[index].value) ?? 1
            self.spO2TimeLabel.text = MonthGroup.allCases[index].rawValue
        }
    }

    func didPickDate(_ date: Date) {
    }
}
