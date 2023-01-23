//
//  BloodPressureState.swift
//  1SKConnect
//
//  Created by admin on 22/11/2021.
//

import Foundation
import UIKit

enum BloodPressureState: DetailsItemProtocol {
    case low
    case normal
    case pre_hypertension
    case high_1
    case high_2

    var title: String? {
        switch self {
        case .low:
            return R.string.localizable.biolight_detail_blood_pressure_low()
        case .normal:
            return R.string.localizable.biolight_detail_blood_pressure_normal()
        case .pre_hypertension:
            return R.string.localizable.biolight_detail_blood_pressure_pre_hypertension()
        case .high_1:
            return R.string.localizable.biolight_detail_blood_pressure_high_1()
        case .high_2:
            return R.string.localizable.biolight_detail_blood_pressure_high_2()
        }
    }

    init(sys: Int, dia: Int) {
        if dia == 0 {
            self = .normal
        }
        switch dia {
        case 0...60:
            switch sys {
            case 0...90:
                self = .low
            case 91...120:
                self = .normal
            case 121...140:
                self = .pre_hypertension
            case 141...160:
                self = .high_1
            default:
                self = .high_2
            }
        case 61...80:
            switch sys {
            case 40...120:
                self = .normal
            case 121...140:
                self = .pre_hypertension
            case 141...160:
                self = .high_1
            default:
                self = .high_2
            }
        case 81...90:
            switch sys {
            case 40...140:
                self = .pre_hypertension
            case 141...160:
                self = .high_1
            default:
                self = .high_2
            }
        case 91...100:
            switch sys {
            case 40...160:
                self = .high_1
            default:
                self = .high_2
            }
        default:
            self = .high_2
        }
    }

    var navigationTitle: String { return "" }
    var description: String {
        switch self {
        case .low:
            return R.string.localizable.biolight_description_blood_pressure_low()
        case .normal:
            return R.string.localizable.biolight_description_blood_pressure_normal()
        case .pre_hypertension:
            return R.string.localizable.biolight_description_blood_pressure_pre_hypertension()
        case .high_1:
            return R.string.localizable.biolight_description_blood_pressure_high_1()
        case .high_2:
            return R.string.localizable.biolight_description_blood_pressure_high_2()
        }
    }
    
    var listDescriptions: [VitalSignsDescriptionModel] {
        switch self {
        case .low:
            return [
                VitalSignsDescriptionModel(title: "Chỉ số nhận biết", des: "Huyết áp thấp khi chỉ số huyết áp tâm thu < 90 mmHg và huyết áp tâm trương < 60 mmHg"),
                VitalSignsDescriptionModel(title: "Dấu hiệu nhận biết", des: "Xuất hiện Cảm giác hoa mắt hoặc chóng mặt, đau đầu dữ dội, Nhịp tim nhanh, thở nhanh, mệt mỏi, giảm tập trung, ..."),
                VitalSignsDescriptionModel(title: "Các đối tượng nguy cơ", des: "Người có vấn đề về tim, phụ nữa có thai, Người bị mất máu, thiếu chất dinh dưỡng trong quá trình ăn uống, Người phải sử dụng thuốc điều trị gây ra huyết áp thấp, ..."),
                VitalSignsDescriptionModel(title: "Các cách phòng ngừa", des: "Bổ sung chất đạm như thịt, cá trong mỗi bữa ăn, Không nên sử dụng những loại thức ăn lợi tiểu ví dụ như: râu ngô, rau cải, dưa hấu, bí ngô,..., Sinh hoạt điều độ, ngủ đủ giấc khoảng 7 – 8 tiếng mỗi ngày."),
                VitalSignsDescriptionModel(title: "Lưu ý", des: "Để đảm bảo kết quả đo huyết áp được chính xác, người dùng cần ngồi đúng tư thế, không hút thuốc lá, không uống cà phê trước khi tiến hành đo từ 15-30 phút, giữ tinh thần thoải mái, tránh căng thẳng, hồi hộp")
            ]
        case .normal:
            return [
                VitalSignsDescriptionModel(title: "Chỉ số nhận biết", des: "Huyết áp bình thường khi chỉ số huyết áp tâm thu từ 90 mmHg đến 119 mmHg và huyết áp tâm trương từ 60 mmHg đến 79 mmHg"),
                VitalSignsDescriptionModel(title: "Lưu ý", des: "Để đảm bảo kết quả đo huyết áp được chính xác, người dùng cần ngồi đúng tư thế, không hút thuốc lá, không uống cà phê trước khi tiến hành đo từ 15-30 phút, giữ tinh thần thoải mái, tránh căng thẳng, hồi hộp")
            ]
        case .pre_hypertension:
            return [
                VitalSignsDescriptionModel(title: "Chỉ số nhận biết", des: "Tiền tăng huyết áp khi chỉ số huyết áp tâm thu từ 120 mmHg đến 139 mmHg và huyết áp tâm trương từ 80 mmHg đến 89 mmHg"),
                VitalSignsDescriptionModel(title: "Dấu hiệu nhận biết", des: "Tiền tăng huyết áp thường không để lại triệu chứng. Cách duy nhất giúp bạn sớm phát hiện bệnh là kiểm tra huyết áp thường xuyên"),
                VitalSignsDescriptionModel(title: "Các đối tượng nguy cơ", des: "Người có tiền sử gia đình bị cao huyết áp, thừa cân hoặc béo phì, không vận động cơ thể, lạm dụng thuốc lá và rượu bia,... "),
                VitalSignsDescriptionModel(title: "Các cách phòng ngừa", des: "Bổ sung thực phẩm lành mạnh, hạn chế rượi bia và thuốc lá, rèn luyện hoạt động thể chất, quản lý căng thẳng,... "),
                VitalSignsDescriptionModel(title: "Lưu ý", des: "Để đảm bảo kết quả đo huyết áp được chính xác, người dùng cần ngồi đúng tư thế, không hút thuốc lá, không uống cà phê trước khi tiến hành đo từ 15-30 phút, giữ tinh thần thoải mái, tránh căng thẳng, hồi hộp")
            ]
        case .high_1:
            return [
                VitalSignsDescriptionModel(title: "Chỉ số nhận biết", des: "Tăng huyết áp độ 1 khi chỉ số huyết áp tâm thu từ 140 mmHg đến 159 mmHg và huyết áp tâm trương từ 90 mmHg đến 99 mmHg"),
                VitalSignsDescriptionModel(title: "Bệnh lý liên quan", des: "Cao huyết áp - Sử dụng thuốc điều trị cao huyết áp đúng theo hướng dẫn của bác sĩ"),
                VitalSignsDescriptionModel(title: "Các đối tượng nguy cơ", des: "Người có tiền sử gia đình bị cao huyết áp, thừa cân hoặc béo phì, không vận động cơ thể, lạm dụng thuốc lá và rượu bia,... "),
                VitalSignsDescriptionModel(title: "Các cách phòng ngừa", des: "Bổ sung thực phẩm lành mạnh, hạn chế rượi bia và thuốc lá, rèn luyện hoạt động thể chất, quản lý căng thẳng,... "),
                VitalSignsDescriptionModel(title: "Lưu ý", des: "Để đảm bảo kết quả đo huyết áp được chính xác, người dùng cần ngồi đúng tư thế, không hút thuốc lá, không uống cà phê trước khi tiến hành đo từ 15-30 phút, giữ tinh thần thoải mái, tránh căng thẳng, hồi hộp")
            ]
        case .high_2:
            return [
                VitalSignsDescriptionModel(title: "Chỉ số nhận biết", des: "Tăng huyết áp độ 2 khi chỉ số huyết áp tâm thu từ 160 mmHg đến 179 mmHg và huyết áp tâm trương từ 100 mmHg đến 119 mmHg"),
                VitalSignsDescriptionModel(title: "Bệnh lý liên quan", des: "Cao huyết áp - Sử dụng thuốc điều trị cao huyết áp đúng theo hướng dẫn của bác sĩ"),
                VitalSignsDescriptionModel(title: "Các đối tượng nguy cơ", des: "Người có tiền sử gia đình bị cao huyết áp, thừa cân hoặc béo phì, không vận động cơ thể, lạm dụng thuốc lá và rượu bia,... "),
                VitalSignsDescriptionModel(title: "Các cách phòng ngừa", des: "Bổ sung thực phẩm lành mạnh, hạn chế rượi bia và thuốc lá, rèn luyện hoạt động thể chất, quản lý căng thẳng,... "),
                VitalSignsDescriptionModel(title: "Lưu ý", des: "Để đảm bảo kết quả đo huyết áp được chính xác, người dùng cần ngồi đúng tư thế, không hút thuốc lá, không uống cà phê trước khi tiến hành đo từ 15-30 phút, giữ tinh thần thoải mái, tránh căng thẳng, hồi hộp")
            ]
        }
    }

    var unit: String { return "" }
    var status: String? { return "" }
    var statusCode: String? { return "" }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.biolightLow()
        case .normal:
            return R.color.biolightNormal()
        case .pre_hypertension:
            return R.color.biolightPre()
        case .high_1:
            return R.color.biolightHigh1()
        case .high_2:
            return R.color.biolightHigh2()
        }
    }
    
    var stateImage: UIImage? {
        switch self {
        case .low:
            return R.image.ic_bloodpressure_state_low()
        case .normal:
            return R.image.ic_bloodpressure_state_normal()
        case .pre_hypertension:
            return R.image.ic_bloodpressure_state_prehypre()
        case .high_1:
            return R.image.ic_bloodpressure_state_high1()
        case .high_2:
            return R.image.ic_bloodpressure_state_high2()
        }
    }

    var value: Double { return 0 }
    var maxValue: Double { return 0 }
    var minValue: Double { return 0 }
    var valueScale: [Double] { return [] }
    var descriptionSacle: [String] { return [] }
}
