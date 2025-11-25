import Foundation
import RealmSwift
import RxSwift

public class RealmManager {
    public static let shared = RealmManager()
    
    private var realm: Realm {
        get throws { try Realm() }
    }
    
    private init() {
        configureRealm()
    }
    
    private func configureRealm() {
        let config = Realm.Configuration(schemaVersion: 1)
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: - Statistics
    public func saveStatistics(_ statistics: StatisticsResponse) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                guard let self = self else {
                    observer.onError(NetworkError.unknown(NSError(domain: "RealmManager", code: -1)))
                    return Disposables.create()
                }
                
                let realm = try self.realm
                let realmStats = RealmStatistics(from: statistics)
                
                try realm.write {
                    realm.add(realmStats, update: .modified)
                }
                
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    public func getStatistics() -> Observable<RealmStatistics?> {
        return Observable.create { [weak self] observer in
            do {
                guard let self = self else {
                    observer.onError(NetworkError.unknown(NSError(domain: "RealmManager", code: -1)))
                    return Disposables.create()
                }
                
                let realm = try self.realm
                let stats = realm.object(ofType: RealmStatistics.self, forPrimaryKey: "statistics")
                observer.onNext(stats)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    public func hasStatistics() -> Bool {
        do {
            let realm = try self.realm
            return realm.object(ofType: RealmStatistics.self, forPrimaryKey: "statistics") != nil
        } catch {
            return false
        }
    }
    
    // MARK: - Users
    public func saveUsers(_ users: [User]) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                guard let self = self else {
                    observer.onError(NetworkError.unknown(NSError(domain: "RealmManager", code: -1)))
                    return Disposables.create()
                }
                
                let realm = try self.realm
                let realmUsers = users.map { RealmUser(from: $0) }
                
                try realm.write {
                    realm.add(realmUsers, update: .modified)
                }
                
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    public func getUsers() -> Observable<[RealmUser]> {
        return Observable.create { [weak self] observer in
            do {
                guard let self = self else {
                    observer.onError(NetworkError.unknown(NSError(domain: "RealmManager", code: -1)))
                    return Disposables.create()
                }
                
                let realm = try self.realm
                let users = realm.objects(RealmUser.self)
                observer.onNext(Array(users))
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    public func hasUsers() -> Bool {
        do {
            let realm = try self.realm
            return !realm.objects(RealmUser.self).isEmpty
        } catch {
            return false
        }
    }
}


