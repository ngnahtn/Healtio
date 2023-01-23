//
//  
//  BloodPressureResultViewController.swift
//  1SKConnect
//
//  Created by admin on 19/11/2021.
//
//

import UIKit
import SnapKit

class BloodPressureResultViewController: BaseViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bloodPressureLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!

    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var bpGraphView: BloodPressureGraphView!

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var isFromHome = false
    var headerTitle = "Lỗi có thể xảy ra trong quá trình đo"
    var callBack: (() -> Void)?
    var measureDate = Date() {
        didSet {
            let hour = self.measureDate.toString(.hm)
            let day = self.measureDate.toString(.dmySlash)
            self.dateLabel.text = "\(hour),  \(day)"
        }
    }
    
    private var descriptionData: [VitalSignsDescriptionModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    var presenter: BloodPressureResultPresenterProtocol!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }

    // MARK: - Setup
    private func setupInit() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.registerNib(ofType: DescriptionTableViewCell.self)
        self.tableView.registerNib(ofType: MesureAgainTableViewCell.self)
    }
    
    private func createHeader() -> UIView{
        let header = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Constant.Screen.width, height: 32)))
        header.backgroundColor = .white
        let titileLabel = UILabel()
        titileLabel.font = R.font.robotoMedium(size: 16)
        titileLabel.text = self.headerTitle
        titileLabel.textColor = R.color.title()
        header.addSubview(titileLabel)
        titileLabel.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
        }
        return header
    }
    // MARK: - Action

    @IBAction func onShareButtonDidTap(_ sender: UIButton) {
        let image = self.resultView.takeScreenshot()
        let shareItems:Array = [image, ""] as [Any]

           let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)

            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.popoverPresentationController?.sourceRect = sender.frame
            }
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func onCloseButtonTap(_ sender: UIButton) {
        presenter.sendBackToBloodPressureVC(from: self)
    }
}

// MARK: - BloodPressureResultViewProtocol
extension BloodPressureResultViewController: BloodPressureResultViewProtocol {

    func showData(with data: BloodPressureModel?, with errorText: String) {
        if data != nil {
            guard let unwrappedData = data else {return}
            self.bloodPressureLabel.text = "\(unwrappedData.sys.value ?? 0)/\(unwrappedData.dia.value ?? 0)/\(unwrappedData.map.value ?? 0)"
            self.heartRateLabel.text = "\(unwrappedData.pr.value ?? 0)"
            self.shareButton.setImage(UIImage(named: "ic_share"), for: .normal)
            self.shareButton.isUserInteractionEnabled = true
            self.stateLabel.text = unwrappedData.state.title
            self.headerTitle = unwrappedData.state.title ?? ""
            self.stateLabel.textColor = unwrappedData.state.color
            self.resultImageView.image = unwrappedData.state.stateImage
            self.bpGraphView.view_Circle.backgroundColor = unwrappedData.state.color
            self.constraintTableViewHeight.constant =  (unwrappedData.state != .normal) ? ((self.isFromHome) ? 650 : 650 + 75)   : ((self.isFromHome) ? 450 : 450 + 75)
            self.descriptionData = unwrappedData.state.listDescriptions
            let date = unwrappedData.date.toDate()
            self.measureDate = date
            DispatchQueue.main.async {
                self.view.layoutIfNeeded()
                self.bpGraphView.setContraintForPointView(xValue: CGFloat(unwrappedData.dia.value ?? 0), yValue: CGFloat(unwrappedData.sys.value ?? 0))
            }
        } else {
            self.stateLabel.text = "Xảy ra lỗi khi đo"
            self.stateLabel.textColor = UIColor(hex: "FF0000")
            self.bpGraphView.pointView.isHidden = true
            self.shareButton.setImage(UIImage(named: "ic_share_disable"), for: .normal)
            self.shareButton.isUserInteractionEnabled = false
            self.constraintTableViewHeight.constant =  (self.isFromHome) ? 550 : 625
            self.descriptionData = [
                VitalSignsDescriptionModel(title: "Không thể xác định áp lực cao/ thấp", des: "Phương pháp: Vui lòng thắt lại bao đo trước khi đo"),
                VitalSignsDescriptionModel(title: "Bao đo bị lỏng", des: "Phương pháp: Vui lòng thắt chặt bao đo"),
                VitalSignsDescriptionModel(title: "Bị nén ép không đúng cách gây ra khi di chuyển tay hoặc cơ thể", des: "Phương pháp: Giữ tay và cơ thể tại 1 vị trí nhất định và đo lại"),
                VitalSignsDescriptionModel(title: "Áp lực lớn hơn 300mmHg", des: "Phương pháp: Vui lòng thắt lại bao đo trước khi đo"),
                VitalSignsDescriptionModel(title: "Huyết áp đo được vượt quá ngưỡng cho phép", des: "Vui lòng thắt lại bao đo và đo lại lần nữa. Nếu vấn đề vẫn còn tồn tại, vui lòng liên lạc đại lý phân phối")
            ]
            self.measureDate = Date()
        }
    }
}

//MARK: - UITableViewDelegate
extension BloodPressureResultViewController: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension BloodPressureResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.createHeader()
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isFromHome ? descriptionData.count : descriptionData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row != descriptionData.count {
            let cell = tableView.dequeueCell(ofType: DescriptionTableViewCell.self, for: indexPath)
            cell.config(with: self.descriptionData[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueCell(ofType: MesureAgainTableViewCell.self, for: indexPath)
            cell.delegate = self
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.row != descriptionData.count ? UITableView.automaticDimension : 75
    }
}

extension BloodPressureResultViewController: MesureAgainTableViewCellDelegate {
    func doAgainButtonDidTap() {
        presenter.sendMeasureAgain(from: self)
    }
}
