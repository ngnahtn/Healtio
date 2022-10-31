//
//  UIImageView+Extension.swift
//
//  Created by tuyenvx.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImageWith(imageUrl: String, placeHolder: UIImage? = nil) {
        let url = URL(string: imageUrl)
        let processor = DownsamplingImageProcessor(size: bounds.size)
        kf.setImage(with: url, placeholder: placeHolder,
                    options: [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale)
        ])
    }

    func setImage(with imageURL: String, completion: ((UIImage) -> Void)?) {
        guard let url = URL(string: imageURL) else {
            return
        }
        let resource = ImageResource(downloadURL: url)
        KingfisherManager.shared.retrieveImage(with: resource) { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    self.image = result.image
                    completion?(result.image)
                }
            case .failure:
                break
            }
        }
    }

    func setImage(_ image: UIImage?, placeHolder: UIImage?) {
        let ratio = UIScreen.main.nativeScale
        self.image = image != nil ? image?.imageResized(to: CGSize(width: bounds.size.width * ratio, height: bounds.size.height * ratio)) : placeHolder
    }
}

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
