import Foundation
import RxSwift

public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case unknown(Error)
}

public class APIService {
    public static let shared = APIService()
    
    private let baseURL = "http://test-case.rikmasters.ru/api/episode"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Statistics
    public func fetchStatistics() -> Observable<StatisticsResponse> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NetworkError.unknown(NSError(domain: "APIService", code: -1)))
                return Disposables.create()
            }
            
            guard let url = URL(string: "\(self.baseURL)/statistics/") else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }

            let task = self.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(NetworkError.unknown(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    observer.onError(NetworkError.serverError(statusCode: httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkError.noData)
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let statistics = try decoder.decode(StatisticsResponse.self, from: data)
                    observer.onNext(statistics)
                    observer.onCompleted()
                } catch {
                    observer.onError(NetworkError.decodingError)
                }
            }
            
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
    // MARK: - Users
    public func fetchUsers() -> Observable<UsersResponse> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NetworkError.unknown(NSError(domain: "APIService", code: -1)))
                return Disposables.create()
            }
            
            guard let url = URL(string: "\(self.baseURL)/users/") else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            let task = self.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(NetworkError.unknown(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    observer.onError(NetworkError.serverError(statusCode: httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkError.noData)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let users = try decoder.decode(UsersResponse.self, from: data)
                    observer.onNext(users)
                    observer.onCompleted()
                } catch {
                    observer.onError(NetworkError.decodingError)
                }
            }
            
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}


