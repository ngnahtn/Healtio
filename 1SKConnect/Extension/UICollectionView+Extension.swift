//
//  UICollectionView+Extension.swift
//
//  Created by tuyenvx.
//

import UIKit

extension UICollectionView {

    func registerCell<T: UICollectionViewCell>(ofType _ : T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: T.self))
    }

    func registerNib<T: UICollectionViewCell>(ofType _ : T.Type) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forCellWithReuseIdentifier: String(describing: T.self))
    }

    func registerHeaderNib<T: UIView>(ofType _: T.Type, kind: String) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: T.self))
    }

    func registerHeaderViewClass<T: UIView>(ofType _ : T.Type, kind: String) {
        register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: T.self))
    }

    func dequeuCell<T: UICollectionViewCell>(ofType _ : T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self),
                                             for: indexPath) as? T else {
            fatalError("Could not deque cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }

    func dequeueHeader<T: UIView>(ofType _ : T.Type, for indexPath: IndexPath) -> UICollectionReusableView {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                withReuseIdentifier: String(describing: T.self),
                                                for: indexPath)
    }
}
