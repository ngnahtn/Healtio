//
//  ProfileModel.swift
//  1SKConnect
//
//  Created by tuyenvx on 30/03/2021.
//

import RealmSwift

class ProfileModel: Object, Codable {
    @objc dynamic var imageData: Data?
    @objc dynamic var id: String = ""
    @objc dynamic var avatar: String = ""
    @objc dynamic var name: String? = ""
    let gender = RealmOptional<Gender>()
    @objc dynamic var birthday: String?
    @objc dynamic var phone: String?
    let height = RealmOptional<Double>()
    let weight = RealmOptional<Double>()
    let blood = RealmOptional<BloodGroup>()
    @objc dynamic var email: String?
    let bmi = RealmOptional<Double>()
    let bmr = RealmOptional<Double>()
    let calo = RealmOptional<Double>()
    let intensityActivity = RealmOptional<Double>()
    let relation = RealmOptional<Relationship>()
    @objc dynamic var linkAccount: LinkModel?
    @objc dynamic var linkAccountId: String = ""
    @objc dynamic var enableAutomaticSync: Bool = false
    @objc dynamic var needDowloadData: Bool = false
    let scaleDowloadMonths = RealmOptional<Int>()
    let spO2DowloadMonths = RealmOptional<Int>()
    @objc dynamic var lastSyncDate: String = ""
    @objc dynamic var createdAt: String = ""

    let deleteSyncId = List<String>()
    let bpDeleteSyncId = List<String>()

    var image: UIImage? {
        guard let `imageData` = imageData else {
            return nil
        }
        return UIImage(data: imageData)
    }

    required override init() {
        super.init()
    }

    private enum CodingKeys: String, CodingKey {
        case id, avatar, name, gender, birthday, phone, height, weight, blood, email, bmi, bmr, calo, intensityActivity
        case relation, createdAt
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        avatar = try container.decode(String.self, forKey: .avatar)
        name = try? container.decode(String.self, forKey: .name)
        gender.value = try? container.decode(Gender.self, forKey: .gender)
        birthday = try? container.decode(String.self, forKey: .birthday)
        phone = try? container.decode(String.self, forKey: .phone)
        height.value = try? container.decode(Double.self, forKey: .height)
        weight.value = try? container.decode(Double.self, forKey: .weight)
        blood.value = try? container.decode(BloodGroup.self, forKey: .blood)
        email = try? container.decode(String.self, forKey: .email)
        bmi.value = try? container.decode(Double.self, forKey: .bmi)
        bmr.value = try? container.decode(Double.self, forKey: .bmr)
        calo.value = try? container.decode(Double.self, forKey: .calo)
        intensityActivity.value = try? container.decode(Double.self, forKey: .intensityActivity)
        relation.value = try? container.decode(Relationship.self, forKey: .relation)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }

    func getUpdatedParam() -> [String: Any] {
        var param: [String: Any] = [:]
        param[SKKey.avatar] = avatar
        if let `name` = name {
            param[SKKey.name] = name
        }
        if let `birthday` = birthday {
            param[SKKey.birthday] = birthday
        }
        if let `gender` = gender.value {
            param[SKKey.gender] = gender.rawValue
        }
        if let `phone` = phone {
            param[SKKey.phone] = phone
        }
        if let `height` = height.value {
            param[SKKey.height] = height
        }
        if let `weight` = weight.value {
            param[SKKey.weight] = weight
        }
        if let `blood` = blood.value {
            param[SKKey.blood] = blood.rawValue
        }
        if let `relation` = relation.value {
            param[SKKey.relation] = relation.rawValue
        }
        if let `intensityActivity` = intensityActivity.value {
            param[SKKey.intensityActivity] = intensityActivity
        }
        if let `email` = email {
            param[SKKey.email] = email
        }
        return param
    }

    func isDiffirent(with profile: ProfileModel) -> Bool {
        let isDiffirent = avatar != profile.avatar ||
            name != profile.name ||
            birthday != profile.birthday ||
            gender != profile.gender ||
            blood != profile.blood ||
            height.value != profile.height.value ||
            weight.value != profile.weight.value ||
            relation != profile.relation ||
            intensityActivity.value != profile.intensityActivity.value
        return isDiffirent
    }

    func isFullRequireInfo() -> (Bool, String) {
        if name == nil || name!.isEmpty {
            return (false, L.nameFieldRequire.localized)
        }

        if name?.count ?? 0 < 2 {
            return (false, L.minNameLengthMessage.localized)
        }
        if birthday == nil {
            return (false, L.birthDayFieldRequire.localized)
        }
//        if blood.value == nil {
//            return (false, "Vui lòng nhập nhóm máu")
//        }

        if height.value ?? 0 < 50 {
            return (false, L.minHeightMessage.localized)
        }

        if height.value ?? 0 > 300 {
            return (false, L.maxHeightMessage.localized)
        }

        if let weigthValue = weight.value, weigthValue < 2 {
            return(false, L.minWeightMessage.localized)
        }

        if let weigthValue = weight.value, weigthValue > 200 {
            return(false, L.maxWeightMessage.localized)
        }
//        if weight.value == nil {
//            return (false, "Vui lòng nhập cân nặng")
//        }
        if relation.value == nil {
            return (false, L.relationshipFieldRequire.localized)
        }
        return (true, "")
    }

    func getHeightStringValue() -> String {
        if let height = height.value {
            return "\(height) cm"
        } else {
            return ""
        }
    }

    func getWeightStringValue() -> String {
        if let weight = weight.value {
            return "\(weight) kg"
        } else {
            return ""
        }
    }

    func isFullWeightInfo() -> Bool {
        return height.value ?? 0 > 0 && weight.value ?? 0 > 0 && calo.value ?? 0 > 0
    }

    static func genNewID() -> String {
        let profileDAO = GenericDAO<ProfileModel>()
        var newID = String.random(length: 10)
        while profileDAO.getObject(with: newID) != nil {
            newID = String.random(length: 10)
        }
        return newID
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}

class ProfileListModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var selectedID: String = ""
    let profiles = List<ProfileModel>()

    convenience init(profiles: [ProfileModel]) {
        self.init()
        self.profiles.append(objectsIn: profiles)
        self.selectedID = profiles.first?.id ?? ""
    }

    var currentProfile: ProfileModel? {
        return profiles.first(where: {$0.id == selectedID})
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
