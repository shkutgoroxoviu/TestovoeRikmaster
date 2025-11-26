import Foundation
import RxSwift
import RxCocoa
import RealmSwift

// MARK: - StatisticsViewModel

class StatisticsViewModel {
    
    // MARK: - Inputs
    let periodFilterRelay = BehaviorRelay<PeriodFilter>(value: .daily)
    let timeRangeFilterRelay = BehaviorRelay<TimeRangeFilter>(value: .allTime)
    let refreshTrigger = PublishSubject<Bool>()
    
    // MARK: - Outputs
    lazy var visitorsInfo: Observable<VisitorsInfoViewModel> = {
        statisticsRelay
            .compactMap { $0 }
            .map { [weak self] stats in
                self?.calculateVisitorsInfo(from: stats) ?? VisitorsInfoViewModel(count: 0, description: "", isIncreasing: false)
            }
    }()

    lazy var observersInfo: Observable<ObserversInfoViewModel> = {
        statisticsRelay
            .compactMap { $0 }
            .map { [weak self] stats in
                self?.calculateObserversInfo(from: stats) ?? ObserversInfoViewModel(newCount: 0, stoppedCount: 0)
            }
    }()

    lazy var chartData: Observable<ChartDataViewModel> = {
        Observable.combineLatest(statisticsRelay.compactMap { $0 }, periodFilterRelay)
            .map { [weak self] stats, filter in
                self?.prepareChartData(from: stats, filter: filter) ?? ChartDataViewModel(entries: [], maxValue: 0)
            }
    }()

    lazy var topVisitors: Observable<[TopVisitorViewModel]> = {
        usersRelay
            .map { [weak self] users in
                self?.getTopVisitors(from: users) ?? []
            }
    }()

    lazy var genderDistribution: Observable<GenderDistributionViewModel> = {
        Observable.combineLatest(usersRelay, statisticsRelay, timeRangeFilterRelay)
            .map { [weak self] users, stats, filter in
                let filtered = self?.filterUsers(users, by: filter, statistics: stats) ?? []
                return self?.calculateGenderDistribution(from: filtered) ?? GenderDistributionViewModel(maleCount: 0, femaleCount: 0, malePercentage: 0, femalePercentage: 0)
            }
    }()

    lazy var ageRanges: Observable<[AgeRangeViewModel]> = {
        Observable.combineLatest(usersRelay, statisticsRelay, timeRangeFilterRelay)
            .map { [weak self] users, stats, filter in
                let filtered = self?.filterUsers(users, by: filter, statistics: stats) ?? []
                return self?.calculateAgeRanges(from: filtered) ?? []
            }
    }()

    let isLoading: Observable<Bool>
    let error: Observable<Error>
    
    // MARK: - Private Properties
    private let disposeBag = DisposeBag()
    private let statisticsRelay = BehaviorRelay<RealmStatistics?>(value: nil)
    let usersRelay = BehaviorRelay<[RealmUser]>(value: [])
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishSubject<Error>()
    
    private let ageRangeDefinitions: [(String, ClosedRange<Int>)] = [
        ("18–21", 18...21),
        ("22–25", 22...25),
        ("26–30", 26...30),
        ("31–35", 31...35),
        ("36–40", 36...40),
        ("40–50", 40...50),
        (">50", 51...200)
    ]
    
    // MARK: - Initialization
    init() {
        isLoading = loadingRelay.asObservable()
        error = errorRelay.asObservable()
        refreshTrigger
            .do(onNext: { [weak self] _ in self?.loadingRelay.accept(true) })
            .flatMapLatest { [weak self] forceRefresh -> Observable<(RealmStatistics?, [RealmUser])> in
                guard let self = self else { return .empty() }
                return self.loadData(forceRefresh: forceRefresh)
            }
            .subscribe(onNext: { [weak self] statistics, users in
                self?.statisticsRelay.accept(statistics)
                self?.usersRelay.accept(users)
                self?.loadingRelay.accept(false)
            }, onError: { [weak self] error in
                self?.errorRelay.onNext(error)
                self?.loadingRelay.accept(false)
            })
            .disposed(by: disposeBag)
        
        visitorsInfo = statisticsRelay
            .compactMap { $0 }
            .map { [weak self] stats in
                self?.calculateVisitorsInfo(from: stats) ?? VisitorsInfoViewModel(count: 0, description: "", isIncreasing: false)
            }
        
        observersInfo = statisticsRelay
            .compactMap { $0 }
            .map { [weak self] stats in
                self?.calculateObserversInfo(from: stats) ?? ObserversInfoViewModel(newCount: 0, stoppedCount: 0)
            }
        
        chartData = Observable.combineLatest(
            statisticsRelay.compactMap { $0 },
            periodFilterRelay
        ).map { [weak self] stats, filter in
            self?.prepareChartData(from: stats, filter: filter) ?? ChartDataViewModel(entries: [], maxValue: 0)
        }
        
        topVisitors = usersRelay
            .map { [weak self] users in
                self?.getTopVisitors(from: users) ?? []
            }
        
        let filteredUsers = Observable.combineLatest(
            usersRelay,
            statisticsRelay,
            timeRangeFilterRelay
        ).map { [weak self] users, stats, filter in
            self?.filterUsers(users, by: filter, statistics: stats) ?? []
        }
        
        genderDistribution = filteredUsers
            .map { [weak self] users in
                self?.calculateGenderDistribution(from: users) ?? GenderDistributionViewModel(maleCount: 0, femaleCount: 0, malePercentage: 0, femalePercentage: 0)
            }
        
        ageRanges = filteredUsers
            .map { [weak self] users in
                self?.calculateAgeRanges(from: users) ?? []
            }
    }
    
    // MARK: - Data Loading
    private func loadData(forceRefresh: Bool) -> Observable<(RealmStatistics?, [RealmUser])> {
        let statsObs: Observable<RealmStatistics?>
        if RealmManager.shared.hasStatistics(), !forceRefresh {
            statsObs = RealmManager.shared.getStatistics()
        } else {
            statsObs = APIService.shared.fetchStatistics()
                .flatMap { stats in
                    RealmManager.shared.saveStatistics(stats).map { _ in stats }
                }
                .map { RealmStatistics(from: $0) }
        }
        
        let usersObs: Observable<[RealmUser]>
        if RealmManager.shared.hasUsers(), !forceRefresh {
            usersObs = RealmManager.shared.getUsers()
        } else {
            usersObs = APIService.shared.fetchUsers()
                .flatMap { stats in
                    RealmManager.shared.saveUsers(stats.users).map { _ in
                        stats.users.map { RealmUser(from: $0) }
                    }
                }
        }
        
        return Observable.zip(statsObs, usersObs)
    }
    
    // MARK: - Business Logic
    
    private func calculateVisitorsInfo(from stats: RealmStatistics) -> VisitorsInfoViewModel {
        let subscriptionsCount = stats.items.filter { $0.type == "subscription" }.count
        return VisitorsInfoViewModel(
            count: subscriptionsCount,
            description: "Количество посетителей в этом месяце выросло",
            isIncreasing: true
        )
    }
    
    private func calculateObserversInfo(from stats: RealmStatistics) -> ObserversInfoViewModel {
        let viewsCount = stats.items.filter { $0.type == "view" }.count
        let unsubscriptionsCount = stats.items.filter { $0.type == "unsubscription" }.count
        return ObserversInfoViewModel(newCount: viewsCount, stoppedCount: unsubscriptionsCount)
    }
    
    private func prepareChartData(from stats: RealmStatistics, filter: PeriodFilter) -> ChartDataViewModel {
        var allDates: [Date] = []
        let calendar = Calendar.current
        
        for item in stats.items {
            for dateValue in item.dates {
                if let date = parseDate(from: dateValue.value, calendar: calendar) {
                    allDates.append(date)
                }
            }
        }
        
        let formatter = dateFormatter(for: filter)
        var visitsByPeriod: [String: Int] = [:]
        
        for date in allDates {
            let key = formatter.string(from: date)
            visitsByPeriod[key, default: 0] += 1
        }
        
        let sortedKeys = visitsByPeriod.keys.sorted { k1, k2 in
            guard let d1 = formatter.date(from: k1), let d2 = formatter.date(from: k2) else {
                return true
            }
            return d1 < d2
        }
        
        let entries = sortedKeys.map { (label: $0, value: visitsByPeriod[$0]!) }
        let maxValue = visitsByPeriod.values.max() ?? 0
        
        return ChartDataViewModel(entries: entries, maxValue: maxValue)
    }
    
    private func getTopVisitors(from users: [RealmUser]) -> [TopVisitorViewModel] {
        return users.prefix(3).map { user in
            TopVisitorViewModel(name: user.name, age: user.age, avatarURL: user.avatar)
        }
    }
    
    private func filterUsers(_ users: [RealmUser], by filter: TimeRangeFilter, statistics: RealmStatistics?) -> [RealmUser] {
        guard let stats = statistics else { return users }
        
        if filter == .allTime {
            return users
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        return users.filter { user in
            let userViewDates = stats.items
                .filter { $0.userId == user.id && $0.type == "view" }
                .flatMap { $0.dates.map { $0.value } }
            
            guard !userViewDates.isEmpty else { return false }
            
            let userDates: [Date] = userViewDates.compactMap { raw in
                parseDate(from: raw, calendar: calendar)
            }
            
            guard let firstVisit = userDates.min() else { return false }
            
            switch filter {
            case .today:
                return calendar.isDate(firstVisit, inSameDayAs: today)
            case .week:
                return calendar.isDate(firstVisit, equalTo: today, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(firstVisit, equalTo: today, toGranularity: .month)
            case .allTime:
                return true
            }
        }
    }
    
    private func calculateGenderDistribution(from users: [RealmUser]) -> GenderDistributionViewModel {
        let maleCount = users.filter { $0.sex == "M" }.count
        let femaleCount = users.filter { $0.sex == "W" }.count
        let total = max(1, maleCount + femaleCount)
        
        let malePercentage = Int(Double(maleCount) / Double(total) * 100)
        let femalePercentage = Int(Double(femaleCount) / Double(total) * 100)
        
        return GenderDistributionViewModel(
            maleCount: maleCount,
            femaleCount: femaleCount,
            malePercentage: malePercentage,
            femalePercentage: femalePercentage
        )
    }
    
    func calculateAgeRanges(from users: [RealmUser]) -> [AgeRangeViewModel] {
        let totalUsers = max(1, users.count) 

        return ageRangeDefinitions.map { rangeLabel, range in
            let usersInRange = users.filter { range.contains($0.age) }

            let maleCount = usersInRange.filter { $0.sex == "M" }.count
            let femaleCount = usersInRange.filter { $0.sex == "W" }.count

            let malePercentage = Int(Double(maleCount) / Double(totalUsers) * 100)
            let femalePercentage = Int(Double(femaleCount) / Double(totalUsers) * 100)

            return AgeRangeViewModel(
                rangeLabel: rangeLabel,
                maleCount: maleCount,
                femaleCount: femaleCount,
                malePercentage: malePercentage,
                femalePercentage: femalePercentage
            )
        }
    }

    // MARK: - Helper Methods
    
    private func parseDate(from raw: Int, calendar: Calendar) -> Date? {
        let day = raw / 1000000
        let month = (raw / 10000) % 100
        let year = raw % 10000
        
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        
        return calendar.date(from: components)
    }
    
    private func dateFormatter(for filter: PeriodFilter) -> DateFormatter {
        let formatter = DateFormatter()
        switch filter {
        case .daily:
            formatter.dateFormat = "dd.MM"
        case .weekly:
            formatter.dateFormat = "'Неделя' w yyyy"
        case .monthly:
            formatter.dateFormat = "MM.yyyy"
        }
        return formatter
    }
}

