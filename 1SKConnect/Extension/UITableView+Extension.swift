//
//  UITableView+Extension.swift
//
//  Created by tuyenvx.
//

import UIKit

extension UITableView {

    func registerCell<T: UITableViewCell>(ofType _ : T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: T.self))
    }

    func registerNib<T: UITableViewCell>(ofType _ : T.Type) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forCellReuseIdentifier: String(describing: T.self))
    }

    func registerHeaderClass<T: UITableViewHeaderFooterView>(ofType _ : T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
    }

    func dequeueCell<T: UITableViewCell>(ofType _ : T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }

    func dequeueHeaderView<T: UITableViewHeaderFooterView>(ofType: T.Type) -> T {
        guard let headerView = dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T else {
            fatalError("Could not dequeue Header view with identifier: \(String(describing: T.self))")
        }
        return headerView
    }
}
