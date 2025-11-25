import Foundation
import RealmSwift

// MARK: - JSON Models

public struct StatisticsResponse: Codable {
    let statistics: [StatisticItem]
}

public struct StatisticItem: Codable {
    let userId: Int
    let type: String
    let dates: [Int]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case type
        case dates
    }
}

// MARK: - JSON Models
public struct UsersResponse: Codable {
    let users: [User]
}

public struct User: Codable {
    let id: Int
    let username: String
    let sex: String
    let isOnline: Bool
    let age: Int
    let files: [UserFile]?
}

public struct UserFile: Codable {
    let id: Int
    let url: String
    let type: String
}

public class RealmInt: Object {
    @Persisted public var value: Int = 0
}

public class RealmStatisticItem: Object {
    @Persisted public var userId: Int = 0
    @Persisted public var type: String = ""
    @Persisted public var dates: List<RealmInt>
}

public class RealmStatistics: Object {
    @Persisted(primaryKey: true) public var id: String = "statistics"
    @Persisted public var items: List<RealmStatisticItem>
    @Persisted public var lastUpdated: Date = Date()
    
    public convenience init(from response: StatisticsResponse) {
        self.init()
        self.items.removeAll()
        
        response.statistics.forEach { item in
            let realmItem = RealmStatisticItem()
            realmItem.userId = item.userId
            realmItem.type = item.type
            realmItem.dates.removeAll()
            item.dates.forEach { val in
                let d = RealmInt()
                d.value = val
                realmItem.dates.append(d)
            }
            self.items.append(realmItem)
        }
        
        self.lastUpdated = Date()
    }
}

// MARK: - Realm Models
public class RealmUser: Object {
    @Persisted(primaryKey: true) public var id: Int = 0
    @Persisted public var name: String = ""
    @Persisted public var avatar: String?
    @Persisted public var sex: String = ""
    @Persisted public var age: Int = 0
    
    public convenience init(from user: User) {
        self.init()
        self.id = user.id
        self.name = user.username
        self.sex = user.sex
        self.age = user.age
        self.avatar = user.files?.first(where: { $0.type == "avatar" })?.url
    }
}



