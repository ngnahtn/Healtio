//
//  
//  IntroduceViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/04/2021.
//
//

import UIKit
import WebKit

class IntroduceViewController: BaseViewController {
    @IBOutlet weak var webview: WKWebView!

    var presenter: IntroducePresenterProtocol!
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
    }
    // MARK: - Setup
    private func setupDefaults() {
        navigationItem.title = L.introduce.localized
        webview.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        webview.scrollView.showsHorizontalScrollIndicator = false
        webview.scrollView.showsVerticalScrollIndicator = false
        webview.scrollView.minimumZoomScale = 1
        webview.scrollView.maximumZoomScale = 1
        let text = """
            <p>1SK.Connect là ứng dụng quản lý dữ liệu sức khỏe dành cho cá nhân &amp; gia đình. Người dùng có thể sử dụng ứng dụng để:</p>
                                <ul>
                                <li>Tạo và quản lý hồ sơ sức khỏe của cá nhân, người thân.</li>
                                <li>Kết nối với các thiết bị chăm sóc sức khỏe như cân sức khỏe, máy đo huyết áp, nhịp tim, máy đo SpO2, nhiệt độ… qua bluetooth.</li>
                                <li>Lưu lại các kết quả đo từ thiết bị theo từng hồ sơ sức khỏe. Các lịch sử đo được tổng hợp thể hiện dưới dạng biểu đồ trực quan và rõ ràng, giúp người dùng có thể xem xu hướng sức khỏe của mình.</li>
                                <li>Nhận đánh giá, cảnh báo tự động từ hệ thống về các kết quả đo.</li>
                                <li>Đồng bộ dữ liệu sức khỏe lên hệ thống của 1SK, từ đó người dùng có thể dễ dàng chia sẻ dữ liệu này tới các bác sĩ, giúp rút ngắn thời gian chẩn đoán và hỗ trợ điều trị bệnh.</li>
                                </ul>
                                <p>Lưu ý:</p>
                                <p>Người dùng không cần sử dụng mạng internet khi sử dụng ứng dụng. 1SK.Connect không lưu trữ bất cứ thông tin sức khỏe nào của người dùng cho tới khi người dùng đồng ý đồng bộ các dữ liệu này lên hệ thống của 1SK.</p>
                                <p>Các đánh giá, cảnh báo tự động từ hệ thống chỉ mang tính chất tham khảo. Để có được những đánh giá chuẩn xác nhất người dùng nên chia sẻ dữ liệu sức khỏe &amp; tham khảo ý kiến từ các bác sĩ.</p>
            """
        webview.loadHTMLString(text.fullHTMLString!, baseURL: nil)
    }
    // MARK: - Action
}

// MARK: - IntroduceViewProtocol
extension IntroduceViewController: IntroduceViewProtocol {

}
