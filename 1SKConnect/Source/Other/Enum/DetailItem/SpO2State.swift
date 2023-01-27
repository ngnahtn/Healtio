//
//  SpO2State.swift
//  1SKConnect
//
//  Created by admin on 28/01/2023.
//

import Foundation

enum S5SpO2State {
    case normal
    case medium
    case low
    
    init(value: Int) {
        switch value {
        case 97...99:
            self = .normal
        case 94...96:
            self = .medium
        default:
            self = .low
        }
    }
    
    var status: String {
        switch self {
        case .normal:
            return "Ổn định"
        case .medium:
            return "Trung bình"
        case .low:
            return "Thấp"
        }
    }
    
    var listDescription: [VitalSignsDescriptionModel] {
        switch self {
        case .normal:
            return [
                VitalSignsDescriptionModel(title: "Thang đo chỉ số SpO2 tiêu chuẩn", des: "Chỉ số Oxy trong máu ổn định dao động từ 97 - 99%")
            ]
        case .medium:
            return [
                VitalSignsDescriptionModel(title: "Thang đo chỉ số SpO2 tiêu chuẩn", des: "Chỉ số Oxy trong máu trung bình dao động từ 94 - 96%, có thể cần thở thêm oxy"),
                VitalSignsDescriptionModel(title: "Triệu chứng khi chỉ số SpO2 giảm", des: "Thay đổi về màu sắc của da, suy giảm trí nhớ, khó thở, thở nhanh, thở khò khè,..."),
                VitalSignsDescriptionModel(title: "Các cách làm tăng nồng độ SpO2", des: "Xây dựng một chế độ ăn uống khoa học và lành mạnh, tập luyện thể dục - thể thao, áp dụng thở sâu đúng cách, điều trị bệnh nền, ..."),
            ]
        case .low:
            return [
                VitalSignsDescriptionModel(title: "Thang đo chỉ số SpO2 tiêu chuẩn", des: "Chỉ số Oxy trong máu thấp khi 93%, cần xin ý kiến của bác sĩ chữa trị"),
                VitalSignsDescriptionModel(title: "Là dấu hiệu của Suy hô hấp", des: "Khi chỉ số Oxy trong máu xuống dưới 92% khi không thở máy hoặc dưới 95% khi thở máy là dấu hiệu của bệnh Suy hô hấp rất nặng."),
                VitalSignsDescriptionModel(title: "Bệnh lý liên quan đến hô hấp", des: "Chỉ số SpO2 thấp là dấu hiệu của bệnh lý liên quan đến hô hấp như hen phế quản, suy hô hấp, phù phổi cấp, viêm phổi do vi khuẩn hoặc virus SARS-CoV-2 gây ra,…"),
                VitalSignsDescriptionModel(title: "Thiếu máu", des: "Khi người bệnh bị thiếu máu sẽ đồng nghĩa với việc lượng Hb có trong máu sẽ giảm đi rất nhiều so với bình thường. Điều này khiến cho chỉ số SpO2 bị thấp đi."),
                VitalSignsDescriptionModel(title: "Suy tim", des: "Người bệnh suy tim sẽ có chức năng bơm máu không được tốt như những người bình thường. Điều này dẫn đến SpO2 bị thấp đi."),
            ]
        }
    }
}
