import UIKit
import RxSwift
import DGCharts
import PinLayout
import RealmSwift

class StatisticsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let genderAgeContainer = UIView()
    private var selectedVisitorsIndex: Int {
        return visitorsButtons.firstIndex(where: { $0.isSelected }) ?? 0
    }
    private let maleLegendView = UIView()
    private let femaleLegendView = UIView()
    private let maleDot = UIView()
    private let femaleDot = UIView()
    private let maleTextLabel = UILabel()
    private let femaleTextLabel = UILabel()
    private let legendSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        return view
    }()

    private let visitorsInfoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private let observersLabel: UILabel = {
        let label = UILabel()
        label.text = "Наблюдатели"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let newObserversContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private let stoppedObserversContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private let newObserversImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .up
        iv.tintColor = .systemGreen
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let newObserversCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let newObserversArrow: UIImageView = {
        let iv = UIImageView()
        iv.image = .upArrow
        iv.tintColor = .systemGreen
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let newObserversDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.text = "Новых наблюдателей в этом месяце"
        return label
    }()

    private let stoppedObserversImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .down
        iv.tintColor = .systemRed
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let stoppedObserversCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let stoppedObserversArrow: UIImageView = {
        let iv = UIImageView()
        iv.image = .downArrow
        iv.tintColor = .systemRed
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let stoppedObserversDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.text = "Пользователи перестали за Вами наблюдать"
        return label
    }()

    private let visitorsImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .up
        iv.tintColor = .systemGreen
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let visitorsCountLabelInContainer: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let upArrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .upArrow
        iv.tintColor = .systemGreen
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let visitorsDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.text = "Количество посетителей в этом месяце выросло"
        label.numberOfLines = 0
        return label
    }()

    private let visitorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Посетители"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let visitorsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    // MARK: - Custom Segments
    private var visitorsButtons: [UIButton] = []
    private let visitorsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private var ageButtons: [UIButton] = []
    private let ageStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let chartContainer = UIView()
    private var chartView: LineChartView!
    
    private let topVisitorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Чаще всех посещают Ваш профиль"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let topVisitorsTable = UITableView()
    
    private let genderSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Пол и возраст"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let genderPieChartView = PieChartView()
    private let ageTable = UITableView()
    
    private let disposeBag = DisposeBag()
    private var refreshControl: UIRefreshControl!
    
    private var statistics: RealmStatistics?
    private var users: [RealmUser] = []
    private var filteredUsers: [RealmUser] = []

    private let ageRanges: [(String, ClosedRange<Int>)] = [
        ("18–21", 18...21),
        ("22–25", 22...25),
        ("26–30", 26...30),
        ("31–35", 31...35),
        ("36–40", 36...40),
        ("40–50", 40...50),
        (">50", 51...200)
    ]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Статистика"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        setupUI()
        setupCustomSegments()
        setupCharts()
        setupTables()
        setupRefreshControl()
        loadData(forceRefresh: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
        chartView.frame = chartContainer.bounds
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(visitorsLabel)
        contentView.addSubview(visitorsStackView)
        contentView.addSubview(chartContainer)
        contentView.addSubview(topVisitorsLabel)
        contentView.addSubview(topVisitorsTable)
        contentView.addSubview(genderSectionLabel)
        contentView.addSubview(ageStackView)
        contentView.addSubview(genderAgeContainer)
        contentView.addSubview(visitorsInfoContainer)
        
        visitorsInfoContainer.addSubview(visitorsImageView)
        visitorsInfoContainer.addSubview(visitorsCountLabelInContainer)
        visitorsInfoContainer.addSubview(upArrowImageView)
        visitorsInfoContainer.addSubview(visitorsDescriptionLabel)

        contentView.addSubview(observersLabel)
        contentView.addSubview(newObserversContainer)
        contentView.addSubview(stoppedObserversContainer)

        newObserversContainer.addSubview(newObserversImageView)
        newObserversContainer.addSubview(newObserversCountLabel)
        newObserversContainer.addSubview(newObserversArrow)
        newObserversContainer.addSubview(newObserversDescriptionLabel)

        stoppedObserversContainer.addSubview(stoppedObserversImageView)
        stoppedObserversContainer.addSubview(stoppedObserversCountLabel)
        stoppedObserversContainer.addSubview(stoppedObserversArrow)
        stoppedObserversContainer.addSubview(stoppedObserversDescriptionLabel)
        
        genderAgeContainer.addSubview(legendSeparator)
        genderAgeContainer.addSubview(genderPieChartView)
        genderAgeContainer.addSubview(ageTable)
        genderAgeContainer.addSubview(maleLegendView)
        genderAgeContainer.addSubview(femaleLegendView)
        
        maleDot.backgroundColor = UIColor(red: 1, green: 46/255, blue: 0, alpha: 1)
        maleDot.layer.cornerRadius = 5
        maleDot.clipsToBounds = true
        maleTextLabel.font = .systemFont(ofSize: 14)
        maleTextLabel.textColor = .black
        maleLegendView.addSubview(maleDot)
        maleLegendView.addSubview(maleTextLabel)
        
        femaleDot.backgroundColor = UIColor(red: 249/255, green: 153/255, blue: 99/255, alpha: 1)
        femaleDot.layer.cornerRadius = 5
        femaleDot.clipsToBounds = true
        femaleTextLabel.font = .systemFont(ofSize: 14)
        femaleTextLabel.textColor = .black
        femaleLegendView.addSubview(femaleDot)
        femaleLegendView.addSubview(femaleTextLabel)
        
        genderAgeContainer.backgroundColor = .white
        genderAgeContainer.layer.cornerRadius = 16
        genderAgeContainer.clipsToBounds = true
        
        genderPieChartView.legend.enabled = false
        genderPieChartView.holeColor = .clear
        genderPieChartView.drawEntryLabelsEnabled = false
        genderPieChartView.rotationAngle = 0
        genderPieChartView.isUserInteractionEnabled = false
        
        ageTable.separatorStyle = .none
        ageTable.isScrollEnabled = false
        ageTable.backgroundColor = .white
    }
    
    private func updateVisitorsInfo(with stats: RealmStatistics) {
        var subsCount = 0
        for item in stats.items {
            if item.type == "subscription" {
                subsCount += 1
            }
        }
        
        visitorsCountLabelInContainer.text = "\(subsCount)"
    }
    
    private func updateObserveUpInfo(with stats: RealmStatistics) {
        var subsCount = 0
        for item in stats.items {
            if item.type == "view" {
                subsCount += 1
            }
        }
        
        newObserversCountLabel.text = "\(subsCount)"
    }
    
    private func updateObserveDownInfo(with stats: RealmStatistics) {
        var subsCount = 0
        for item in stats.items {
            if item.type == "unsubscription" {
                subsCount += 1
            }
        }
        
        stoppedObserversCountLabel.text = "\(subsCount)"
    }
    
    private func setupCustomSegments() {
        let visitorsItems = ["По дням", "По неделям", "По месяцам"]
        for (index, title) in visitorsItems.enumerated() {
            let button = createSegmentButton(title: title)
            button.tag = index
            button.addTarget(self, action: #selector(visitorsButtonTapped(_:)), for: .touchUpInside)
            visitorsStackView.addArrangedSubview(button)
            visitorsButtons.append(button)
        }
        selectVisitorsButton(index: 0)
        
        let ageItems = ["Сегодня", "Неделя", "Месяц", "Все время"]
        for (index, title) in ageItems.enumerated() {
            let button = createSegmentButton(title: title)
            button.tag = index
            button.addTarget(self, action: #selector(ageButtonTapped(_:)), for: .touchUpInside)
            ageStackView.addArrangedSubview(button)
            ageButtons.append(button)
        }
        selectAgeButton(index: 3)
    }
    
    private func createSegmentButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .clear
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.clipsToBounds = true
        return button
    }

    private func selectVisitorsButton(index: Int) {
        for (i, button) in visitorsButtons.enumerated() {
            if i == index {
                button.isSelected = true
                button.backgroundColor = UIColor(red: 1, green: 46/255, blue: 0, alpha: 1)
                button.setTitleColor(.white, for: .normal)
            } else {
                button.isSelected = false
                button.backgroundColor = .clear
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    private func selectAgeButton(index: Int) {
        for (i, button) in ageButtons.enumerated() {
            button.isSelected = i == index
            if i == index {
                button.backgroundColor = UIColor(red: 1, green: 46/255, blue: 0, alpha: 1)
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    @objc private func visitorsButtonTapped(_ sender: UIButton) {
        selectVisitorsButton(index: sender.tag)
        updateChart()
    }
    
    @objc private func ageButtonTapped(_ sender: UIButton) {
        selectAgeButton(index: sender.tag)
        filterUsersForAgeTable(selectedIndex: sender.tag)
        updateGenderPieChart()
        updateGenderLegend()
        ageTable.reloadData()
    }
    
    private func filterUsersForAgeTable(selectedIndex: Int) {
        guard let stats = statistics else {
            filteredUsers = users
            return
        }

        let calendar = Calendar.current
        let today = Date()

        filteredUsers = users.filter { user in
            let userViewDates = stats.items
                .filter { $0.userId == user.id && $0.type == "view" }
                .flatMap { $0.dates.map { $0.value } }

            guard !userViewDates.isEmpty else { return selectedIndex == 3 }

            let userDates: [Date] = userViewDates.compactMap { raw in
                let day = raw / 1000000
                let month = (raw / 10000) % 100
                let year = raw % 10000
                var components = DateComponents()
                components.day = day
                components.month = month
                components.year = year
                return calendar.date(from: components)
            }

            guard let firstVisit = userDates.min() else { return false }

            switch selectedIndex {
            case 0: return calendar.isDate(firstVisit, inSameDayAs: today)
            case 1: return calendar.isDate(firstVisit, equalTo: today, toGranularity: .weekOfYear)
            case 2: return calendar.isDate(firstVisit, equalTo: today, toGranularity: .month)
            case 3: return true
            default: return true
            }
        }
    }

    private func layoutViews() {
        scrollView.pin.all(view.pin.safeArea)
        contentView.pin.top().left().right()
        
        visitorsLabel.pin.top(16).left(16).sizeToFit()
        
        let visitorsInfoHeight: CGFloat = 110
        visitorsInfoContainer.pin.below(of: visitorsLabel).marginTop(8).left(16).right(16).height(visitorsInfoHeight)
        
        let padding: CGFloat = 12
        visitorsImageView.pin.left(padding).vCenter().size(CGSize(width: 95, height: 50))
        
        visitorsCountLabelInContainer.pin.top(padding).after(of: visitorsImageView, aligned: .top).marginLeft(8).sizeToFit()
        upArrowImageView.pin.after(of: visitorsCountLabelInContainer, aligned: .center).marginLeft(4).size(CGSize(width: 16, height: 16))
        
        visitorsDescriptionLabel.pin.below(of: visitorsCountLabelInContainer).marginTop(4).left(visitorsCountLabelInContainer.frame.minX).right(padding).height(40)
        visitorsDescriptionLabel.numberOfLines = 2
        visitorsDescriptionLabel.lineBreakMode = .byWordWrapping
        
        visitorsStackView.pin.below(of: visitorsInfoContainer).marginTop(12).left(16).right(16).height(36)
        chartContainer.pin.below(of: visitorsStackView).marginTop(12).left(16).right(16).height(200)
        
        topVisitorsLabel.pin.below(of: chartContainer).marginTop(16).left(16).sizeToFit()
        topVisitorsTable.pin.below(of: topVisitorsLabel).marginTop(8).left(16).right(16).height(180)
        
        genderSectionLabel.pin.below(of: topVisitorsTable).marginTop(24).left(16).sizeToFit()
        ageStackView.pin.below(of: genderSectionLabel).marginTop(12).left(16).right(16).height(36)
        
        observersLabel.pin.below(of: genderAgeContainer).marginTop(24).left(16).sizeToFit()

        let observerContainerHeight: CGFloat = 110
        newObserversContainer.pin.below(of: observersLabel).marginTop(8).left(16).right(16).height(observerContainerHeight)
        stoppedObserversContainer.pin.below(of: newObserversContainer).marginTop(12).left(16).right(16).height(observerContainerHeight)

        newObserversImageView.pin.left(padding).vCenter().size(CGSize(width: 95, height: 50))
        newObserversCountLabel.pin.top(padding).after(of: newObserversImageView, aligned: .top).marginLeft(8).sizeToFit()
        newObserversArrow.pin.after(of: newObserversCountLabel, aligned: .center).marginLeft(4).size(CGSize(width: 16, height: 16))
        newObserversDescriptionLabel.pin.below(of: newObserversCountLabel).marginTop(4).left(newObserversCountLabel.frame.minX).right(padding).height(40)

        stoppedObserversImageView.pin.left(padding).vCenter().size(CGSize(width: 95, height: 50))
        stoppedObserversCountLabel.pin.top(padding).after(of: stoppedObserversImageView, aligned: .top).marginLeft(8).sizeToFit()
        stoppedObserversArrow.pin.after(of: stoppedObserversCountLabel, aligned: .center).marginLeft(4).size(CGSize(width: 16, height: 16))
        stoppedObserversDescriptionLabel.pin.below(of: stoppedObserversCountLabel).marginTop(4).left(stoppedObserversCountLabel.frame.minX).right(padding).height(40)
        
        let containerTop = ageStackView.frame.maxY + 12
        let containerWidth = view.bounds.width - 32
        let pieSize: CGFloat = 200
        let legendHeight: CGFloat = 20
        let spacing: CGFloat = 16
        let ageTableHeight = CGFloat(ageRanges.count * 44)
        let genderContainerHeight = pieSize + spacing + legendHeight + 12 + ageTableHeight + 16
        
        genderAgeContainer.frame = CGRect(x: 16, y: containerTop, width: containerWidth, height: genderContainerHeight)
        
        genderPieChartView.frame = CGRect(x: (containerWidth - pieSize)/2, y: 16, width: pieSize, height: pieSize)
        
        let maleTextWidth = maleTextLabel.intrinsicContentSize.width
        let femaleTextWidth = femaleTextLabel.intrinsicContentSize.width
        let dotWidth: CGFloat = 10
        let totalWidth = dotWidth + 4 + maleTextWidth + spacing + dotWidth + 4 + femaleTextWidth
        let startX = (containerWidth - totalWidth)/2
        let legendY = genderPieChartView.frame.maxY + 8
        
        maleLegendView.frame = CGRect(x: startX, y: legendY, width: dotWidth + 4 + maleTextWidth, height: legendHeight)
        femaleLegendView.frame = CGRect(x: startX + dotWidth + 4 + maleTextWidth + spacing, y: legendY, width: dotWidth + 4 + femaleTextWidth, height: legendHeight)
        
        maleDot.frame = CGRect(x: 0, y: (legendHeight - 10)/2, width: 10, height: 10)
        maleTextLabel.frame = CGRect(x: 14, y: 0, width: maleLegendView.frame.width - 14, height: legendHeight)
        
        femaleDot.frame = CGRect(x: 0, y: (legendHeight - 10)/2, width: 10, height: 10)
        femaleTextLabel.frame = CGRect(x: 14, y: 0, width: femaleLegendView.frame.width - 14, height: legendHeight)
        
        legendSeparator.frame = CGRect(x: 16, y: legendY + legendHeight + 12, width: containerWidth - 32, height: 1)
        ageTable.frame = CGRect(x: 0, y: legendSeparator.frame.maxY + 12, width: containerWidth, height: ageTableHeight)
        
        contentView.pin.wrapContent(.vertically, padding: 16)
        scrollView.contentSize = contentView.frame.size
    }
    
    // MARK: - Legend & Charts
    private func updateGenderLegend() {
        let maleCount = filteredUsers.filter { $0.sex == "M" }.count
        let femaleCount = filteredUsers.filter { $0.sex == "W" }.count
        
        if maleCount + femaleCount == 0 {
            maleLegendView.isHidden = true
            femaleLegendView.isHidden = true
            return
        } else {
            maleLegendView.isHidden = false
            femaleLegendView.isHidden = false
        }
        
        let total = max(1, maleCount + femaleCount)
        maleTextLabel.text = "Мужчины \(Int(Double(maleCount)/Double(total)*100))%"
        femaleTextLabel.text = "Женщины \(Int(Double(femaleCount)/Double(total)*100))%"
    }
    
    // MARK: - Charts
    private func setupCharts() {
        chartContainer.backgroundColor = .white
        chartContainer.layer.cornerRadius = 16
        chartContainer.clipsToBounds = true
        
        chartView = LineChartView()
        chartContainer.addSubview(chartView)
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.3)
        chartView.leftAxis.gridLineDashLengths = [4, 4]
        chartView.leftAxis.gridLineWidth = 0.5
        chartView.leftAxis.axisMinimum = 0
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelTextColor = .black
        
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBordersEnabled = false
        
        chartView.extraTopOffset = 20
        chartView.extraBottomOffset = 20
        chartView.extraLeftOffset = 16
        chartView.extraRightOffset = 16
        
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        
        let marker = VisitorsMarkerView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        marker.chartView = chartView
        chartView.marker = marker
    }
    
    // MARK: - Tables
    private func setupTables() {
        ageTable.delegate = self
        ageTable.dataSource = self
        ageTable.register(AgeCell.self, forCellReuseIdentifier: "AgeCell")
        ageTable.layer.cornerRadius = 8
        ageTable.backgroundColor = .systemGray6
        
        topVisitorsTable.delegate = self
        topVisitorsTable.dataSource = self
        topVisitorsTable.register(TopVisitorCell.self, forCellReuseIdentifier: "TopVisitorCell")
        topVisitorsTable.layer.cornerRadius = 8
        topVisitorsTable.backgroundColor = .white
    }

    // MARK: - Refresh
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() { loadData(forceRefresh: true) }
    
    private func handleError(_ error: Error) { refreshControl.endRefreshing() }
    
    // MARK: - Load & Update
    private func loadData(forceRefresh: Bool) {
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
        
        Observable.zip(statsObs, usersObs)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] stats, users in
                guard let self = self else { return }
                self.statistics = stats
                self.users = users
                self.filteredUsers = users
                self.updateUI()
            }, onError: { [weak self] error in
                self?.handleError(error)
            }, onCompleted: { [weak self] in
                self?.refreshControl.endRefreshing()
            }).disposed(by: disposeBag)
    }
    
    private func updateUI() {
        guard let stats = statistics else { return }
    
        updateObserveUpInfo(with: stats)
        updateObserveDownInfo(with: stats)
        updateVisitorsInfo(with: stats)
        updateChart()
        updateGenderPieChart()
        updateGenderLegend()
        ageTable.reloadData()
        topVisitorsTable.reloadData()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func updateGenderPieChart() {
        let maleCount = filteredUsers.filter { $0.sex == "M" }.count
        let femaleCount = filteredUsers.filter { $0.sex == "W" }.count
        
        if maleCount + femaleCount == 0 {
            genderPieChartView.data = nil
            genderPieChartView.noDataText = "Нет данных"
            genderPieChartView.noDataTextColor = .darkGray
            genderPieChartView.noDataFont = .systemFont(ofSize: 16, weight: .medium)
            genderPieChartView.setNeedsDisplay()
            return
        }

        let maleEntry = PieChartDataEntry(value: Double(maleCount))
        let femaleEntry = PieChartDataEntry(value: Double(femaleCount))
        
        let dataSet = PieChartDataSet(entries: [maleEntry, femaleEntry])
        dataSet.colors = [
            UIColor(red: 1, green: 46/255, blue: 0, alpha: 1),
            UIColor(red: 249/255, green: 153/255, blue: 99/255, alpha: 1)
        ]
        dataSet.sliceSpace = 4
        dataSet.drawValuesEnabled = false
        
        genderPieChartView.holeRadiusPercent = 1 - (15 / 200)
        genderPieChartView.transparentCircleRadiusPercent = 0
        genderPieChartView.data = PieChartData(dataSet: dataSet)
        genderPieChartView.notifyDataSetChanged()
    }
    
    private func updateChart() {
        guard let stats = statistics else { return }

        var allDates: [Date] = []
        let calendar = Calendar.current

        for item in stats.items {
            for dateValue in item.dates {
                let raw = dateValue.value
                let day = raw / 1000000
                let month = (raw / 10000) % 100
                let year = raw % 10000

                var components = DateComponents()
                components.day = day
                components.month = month
                components.year = year

                if let date = calendar.date(from: components) {
                    allDates.append(date)
                }
            }
        }

        var visitsByPeriod: [String: Int] = [:]
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd.MM"
        let weekFormatter = DateFormatter()
        weekFormatter.dateFormat = "'Неделя' w yyyy"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM.yyyy"

        for date in allDates {
            let key: String
            switch selectedVisitorsIndex {
            case 0: key = dayFormatter.string(from: date)
            case 1: key = weekFormatter.string(from: date)
            case 2: key = monthFormatter.string(from: date)
            default: key = dayFormatter.string(from: date)
            }
            visitsByPeriod[key, default: 0] += 1
        }

        let sortedKeys = visitsByPeriod.keys.sorted { k1, k2 in
            let df: DateFormatter
            switch selectedVisitorsIndex {
            case 0: df = dayFormatter
            case 1: df = weekFormatter
            case 2: df = monthFormatter
            default: df = dayFormatter
            }
            guard let d1 = df.date(from: k1), let d2 = df.date(from: k2) else { return true }
            return d1 < d2
        }

        var entries: [ChartDataEntry] = []
        for (index, key) in sortedKeys.enumerated() {
            let yValue = Double(visitsByPeriod[key]! )
            let entry = ChartDataEntry(x: Double(index), y: yValue)
            entry.data = key
            entries.append(entry)
        }

        if entries.isEmpty {
            chartView.data = nil
            chartView.notifyDataSetChanged()
            return
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")
        dataSet.colors = [UIColor.red]
        dataSet.circleColors = [UIColor.red]
        dataSet.circleRadius = 4
        dataSet.lineWidth = 2
        dataSet.drawValuesEnabled = false

        chartView.data = LineChartData(dataSet: dataSet)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: sortedKeys)
        chartView.xAxis.labelTextColor = .black
        chartView.xAxis.granularity = 1
        chartView.leftAxis.axisMinimum = 0
        if let maxVisits = visitsByPeriod.values.max() {
            chartView.leftAxis.axisMaximum = max(5, Double(maxVisits) * 1.2)
        }
        chartView.notifyDataSetChanged()
    }
}

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == topVisitorsTable { return min(3, users.count) }
        return ageRanges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == topVisitorsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopVisitorCell", for: indexPath) as! TopVisitorCell
            let user = users[indexPath.row]
            cell.configure(with: user.name, age: user.age, avatarURL: user.avatar)
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AgeCell", for: indexPath) as! AgeCell
            let range = ageRanges[indexPath.row].1
            let maleCount = filteredUsers.filter { $0.sex == "M" && range.contains($0.age) }.count
            let femaleCount = filteredUsers.filter { $0.sex == "W" && range.contains($0.age) }.count
            let totalUsers = filteredUsers.count
            cell.configure(range: ageRanges[indexPath.row].0,
                           maleCount: maleCount,
                           femaleCount: femaleCount,
                           totalUsers: totalUsers)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == topVisitorsTable ? 60 : 44
    }
}
