//
//  
//  S5WatchFaceSettingViewController.swift
//  1SKConnect
//
//  Created by admin on 10/02/2022.
//
//

import UIKit

class S5WatchFaceSettingViewController: BaseViewController {

    @IBOutlet weak var watchFaceCollectionView: UICollectionView!
    var presenter: S5WatchFaceSettingPresenterProtocol!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title = R.string.localizable.s5_setting_type_watch_face()
        setUpCollectionView()
    }
    
    private func setUpCollectionView() {
        self.watchFaceCollectionView.registerNib(ofType: S5WatchFaceCLVCell.self)
        self.watchFaceCollectionView.delegate = self
        self.watchFaceCollectionView.dataSource = self
        self.watchFaceCollectionView.prefetchDataSource = self
    }
    
    // MARK: - Action
    @IBAction func handleApplyButton(_ sender: UIButton) {
        self.presenter.sendDialToS5()
    }
    
}

// MARK: - S5WatchFaceSettingViewProtocol
extension S5WatchFaceSettingViewController: S5WatchFaceSettingViewProtocol {
}

// MARK: - UICollectionViewDelegate
extension S5WatchFaceSettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.presenter.onWatchFaceDidSelected()
    }
}
// MARK: - UICollectionViewDataSource
extension S5WatchFaceSettingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.numberOfCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.watchFaceCollectionView.dequeuCell(ofType: S5WatchFaceCLVCell.self, for: indexPath)
        return cell
    }
    
}
// MARK: - UICollectionViewDataSourcePrefetching
extension S5WatchFaceSettingViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension S5WatchFaceSettingViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (UIScreen.main.bounds.size.width - 16 * 2) / 3 - 16
        return CGSize(width: cellWidth, height: cellWidth * 1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
