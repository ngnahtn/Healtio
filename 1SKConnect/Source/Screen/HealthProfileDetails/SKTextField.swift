//
//  ScrollDownLabel.swift
//  1SK
//
//  Created by tuyenvx on 08/02/2021.
//

import UIKit

protocol SKSelectedLabelDelegate: AnyObject {
    func didSelect(_ scrollDownLabel: SKTextField)
}
class SKTextField: UIView {
    private lazy var typeLabel = UILabel()
    lazy var titleTextField = UITextField()
    private lazy var scrollDownButton = UIButton()
    private lazy var scrollDownImageView = UIImageView(image: R.image.ic_down())
    weak var delegate: SKSelectedLabelDelegate?

    @IBInspectable var isRequire: Bool = true
    @IBInspectable var attributedPlaceHolder: String?
    @IBInspectable var typeTitle: String?
    @IBInspectable var isSelectable: Bool = true
    @IBInspectable var hasScrollDown: Bool = true

    override func awakeFromNib() {
        super.awakeFromNib()
        setupDefaults()
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return false
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    private func setupDefaults() {
        backgroundColor = .white
        // Type View
        let typeView = createTypeView()
        addSubview(typeView)
        typeView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(14)
        }
        // bg view
        let bgView = UIView()
        insertSubview(bgView, belowSubview: typeView)
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(typeView.snp.centerY)
            make.height.equalTo(44)
            make.leading.trailing.bottom.equalToSuperview()
        }
        bgView.cornerRadius = 5
        bgView.borderWidth = 1
        bgView.borderColor = UIColor(hex: "D3DBE3")
        let hasScrollDownImage = isSelectable && hasScrollDown
        if hasScrollDownImage {
            bgView.addSubview(scrollDownImageView)
            scrollDownImageView.snp.makeConstraints { (make) in
                make.width.equalTo(11)
                make.height.equalTo(6)
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-17)
            }
        }

        if isSelectable {
            bgView.addSubview(scrollDownButton)
            scrollDownButton.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            scrollDownButton.addTarget(self, action: #selector(buttonScrollDownDidTapped), for: .touchUpInside)
        }
        bgView.addSubview(titleTextField)

        titleTextField.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(14)
            make.trailing
                .equalTo(hasScrollDownImage ? scrollDownImageView.snp.leading : bgView.snp.trailing)
                .offset(hasScrollDownImage ? 5 : 16)
        }
        titleTextField.isEnabled = false
        titleTextField.font = R.font.robotoRegular(size: 14)
        titleTextField.textColor = R.color.title()

        updateAttributedPlaceHolder()
        updateTypeLabelHiddenState(false)
    }

    private func createTypeView() -> UIView {
        let typeView = UIView()
        typeView.isUserInteractionEnabled = false
        typeView.backgroundColor = .white
        typeView.clipsToBounds = true
        typeView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(14)
            make.top.centerX.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(4)
        }
        typeLabel.font = R.font.robotoRegular(size: 12)
        typeLabel.textColor = R.color.title()
        typeLabel.text = typeTitle?.localized
        typeLabel.clipsToBounds = true
        typeLabel.adjustsFontSizeToFitWidth = true
        typeLabel.minimumScaleFactor = 0.5
        return typeView
    }

    // MARK: - Action
    func setValue(with text: String?) {
        titleTextField.text = text
        updateTypeLabelHiddenState()
    }

    func getValue() -> String {
        return titleTextField.text ?? ""
    }

    func setPlaceHolder(_ placeHolder: String) {
        titleTextField.placeholder = placeHolder
    }

    func setPlaceHolderAtributedString(_ placeHolder: NSAttributedString) {
        titleTextField.attributedPlaceholder = placeHolder
    }

    func setEnable(isEnable: Bool) {
        if isSelectable {
            scrollDownButton.isEnabled = isEnable
        } else {
            titleTextField.isEnabled = isEnable
        }
    }

    @objc func buttonScrollDownDidTapped() {
        delegate?.didSelect(self)
    }

    func setExpandButtonHidden(_ isHidden: Bool) {
        scrollDownImageView.isHidden = isHidden
    }

    func setDelegate(_ delegate: UITextFieldDelegate?) {
        titleTextField.delegate = delegate
    }

    func setTypeLabel(_ value: String) {
        typeLabel.text = value
    }

    func setKeyboardType(_ type: UIKeyboardType) {
        titleTextField.keyboardType = type
    }

    func setContentType(_ type: UITextContentType) {
        titleTextField.textContentType = type
    }

    func updateTypeLabelHiddenState(_ isAnimate: Bool = true) {
        let isEmpty = titleTextField.text?.isEmpty ?? true
        let isShow = !isEmpty || titleTextField.isFirstResponder
        if isShow {
            titleTextField.attributedPlaceholder = nil
        } else {
            updateAttributedPlaceHolder()
        }
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: -2, y: 21)
        let scale: CGFloat = 16.0 / 14.0
        transform = transform.scaledBy(x: scale, y: scale)
        typeLabel.attributedText = isShow ? NSAttributedString(string: typeTitle?.localized ?? "", attributes: [.foregroundColor: R.color.title()!]) : getAttributedPlaceHolder()
        if isAnimate {
            UIView.animate(withDuration: Constant.Number.animationTime) {
                self.typeLabel.superview?.transform = isShow ? .identity : transform
            }
        } else {
            typeLabel.superview?.transform = isShow ? .identity : transform
        }

    }

    @objc func textFieldTextDidChanged() {
        updateTypeLabelHiddenState()
    }

    private func updateAttributedPlaceHolder() {
        guard let placeHolder = attributedPlaceHolder?.localized else {
            return
        }
        let redColorAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(hex: "F94D4D")]
        let contentAttributedString = NSMutableAttributedString(string: placeHolder, attributes: [.foregroundColor: R.color.subTitle()!])
        let range = (contentAttributedString.string as NSString).range(of: "*")
        if isRequire {
            if range.location == NSNotFound {
                let asteriskAttributedString = NSAttributedString(string: "*", attributes: redColorAttribute)
                contentAttributedString.append(asteriskAttributedString)
            } else {
                contentAttributedString.addAttributes(redColorAttribute, range: range)
            }
        }
//        titleTextField.attributedPlaceholder = contentAttributedString
        titleTextField.placeholder = ""
    }

    func getAttributedPlaceHolder() -> NSAttributedString? {
        guard let placeHolder = attributedPlaceHolder?.localized else {
            return nil
        }
        let redColorAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(hex: "F94D4D")]
        let contentAttributedString = NSMutableAttributedString(string: placeHolder, attributes: [.foregroundColor: R.color.subTitle()!])
        let range = (contentAttributedString.string as NSString).range(of: "*")
        if isRequire {
            if range.location == NSNotFound {
                let asteriskAttributedString = NSAttributedString(string: "*", attributes: redColorAttribute)
                contentAttributedString.append(asteriskAttributedString)
            } else {
                contentAttributedString.addAttributes(redColorAttribute, range: range)
            }
        }
        return contentAttributedString
    }
}
