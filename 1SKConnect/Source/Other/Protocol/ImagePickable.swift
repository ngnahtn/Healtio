//
//  ImagePickable.swift
//
//  Created by tuyenvx
//  Copyright @ Vuong Xuan Tuyen. All rights reserved.
//

import AVKit
import Photos

protocol CameraUsage {
    func checkAbilityForUsageCamera(grantedHandler: @escaping () -> Void,
                                    notGrantedHandler: @escaping () -> Void)
}

extension CameraUsage {
    func checkAbilityForUsageCamera(grantedHandler: @escaping () -> Void,
                                    notGrantedHandler: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        grantedHandler()
                    } else {
                        //notGrantedHandler()
                    }
                }
            }
        case .restricted:
            notGrantedHandler()
        case .denied:
            notGrantedHandler()
        case .authorized:
            grantedHandler()
        @unknown default:
            notGrantedHandler()
        }
    }
}

protocol PhotoUsage {
    func checkAbilityForPhotoUsage(grantedHandler: @escaping () -> Void,
                                   notGrantedHandler: @escaping () -> Void)
}

extension PhotoUsage {
    func checkAbilityForPhotoUsage(grantedHandler: @escaping () -> Void,
                                   notGrantedHandler: @escaping () -> Void) {
        var status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        switch status {
        case .notDetermined:
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { (authorizationStatus) in
                    DispatchQueue.main.async {
                        if authorizationStatus == .authorized {
                            grantedHandler()
                        } else {
                            notGrantedHandler()
                        }
                    }
                })
            } else {
                PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
                    DispatchQueue.main.async {
                        if authorizationStatus == .authorized {
                            grantedHandler()
                        } else {
                            notGrantedHandler()
                        }
                    }
                }
            }
        case .authorized, .limited:
            grantedHandler()
        case .denied, .restricted:
            notGrantedHandler()
        @unknown default:
            break
        }
    }
}

protocol ImagePickable: CameraUsage, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func checkAbilityForUsageCamera(grantedHandler: @escaping () -> Void)
    func showRequireAuthorizationForUsageCameraAlert()
    func showImagePicker(sourceType: UIImagePickerController.SourceType, allowsEditing: Bool)
    func showSelectedImageSourceAlert(with title: String,
                                      popoverRect: CGRect,
                                      popoverView: UIView,
                                      allowsEditing: Bool)
}

extension ImagePickable where Self: UIViewController {
    func checkAbilityForUsageCamera(grantedHandler: @escaping () -> Void) {
        self.checkAbilityForUsageCamera(grantedHandler: grantedHandler) { [weak self] in
            self?.showRequireAuthorizationForUsageCameraAlert()
        }
    }

    func showRequireAuthorizationForUsageCameraAlert() {
        let requireAuthorizationForUsageCameraAlert =
            UIAlertController(title: "1SK-Connect muốn truy cập camera của bạn",
                              message: "Vui lòng cấp quyền truy cập camera để tiếp tục",
                              preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Cho phép", style: .default, handler: { (_) in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(settingURL) else {
                return
            }
            UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
        })
        let noAction = UIAlertAction(title: "Không", style: .cancel, handler: nil)
        requireAuthorizationForUsageCameraAlert.addAction(okAction)
        requireAuthorizationForUsageCameraAlert.addAction(noAction)
        requireAuthorizationForUsageCameraAlert.popoverPresentationController?.sourceRect = view.bounds
        requireAuthorizationForUsageCameraAlert.popoverPresentationController?.sourceView = view
        present(requireAuthorizationForUsageCameraAlert, animated: true, completion: nil)
    }

    func showSelectedImageSourceAlert(with title: String,
                                      popoverRect: CGRect,
                                      popoverView: UIView,
                                      allowsEditing: Bool) {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (_) in
                self?.checkAbilityForUsageCamera(grantedHandler: { [weak self] in
                    self?.showImagePicker(sourceType: .camera, allowsEditing: allowsEditing)
                })
            })
            alertController.addAction(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Image", style: .default, handler: { [weak self] _ in
                self?.showImagePicker(sourceType: .photoLibrary, allowsEditing: allowsEditing)
            })
            alertController.addAction(photoLibraryAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let savedPhotosAlbumAction = UIAlertAction(title: "Saved Album", style: .default, handler: { [weak self] _ in
                self?.showImagePicker(sourceType: .savedPhotosAlbum, allowsEditing: allowsEditing)
            })
            alertController.addAction(savedPhotosAlbumAction)
        }
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancleAction)
        alertController.popoverPresentationController?.sourceRect = popoverRect
        alertController.popoverPresentationController?.sourceView = popoverView
        present(alertController, animated: true, completion: nil)
    }

    func showImagePicker(sourceType: UIImagePickerController.SourceType, allowsEditing: Bool) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = allowsEditing
        pickerController.sourceType = sourceType
        present(pickerController, animated: true, completion: nil)
    }
}
