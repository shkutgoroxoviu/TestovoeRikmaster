import UIKit
import RxSwift
import PinLayout
internal import RxRelay

// MARK: - StatisticsViewController 

class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = StatisticsViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let visitorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Посетители"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let visitorsInfoCard = InfoCardView()
    private lazy var visitorsSegmentControl = CustomSegmentControl(items: ["По дням", "По неделям", "По месяцам"])
    private let chartContainerView = ChartContainerView()
    
    private let topVisitorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Чаще всех посещают Ваш профиль"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let topVisitorsTable: UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = 8
        table.backgroundColor = .white
        return table
    }()
    
    private var topVisitorsData: [TopVisitorViewModel] = []
    
    private let genderSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Пол и возраст"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var ageSegmentControl = CustomSegmentControl(items: ["Сегодня", "Неделя", "Месяц", "Все время"])
    private let genderAgeView = GenderAgeView()
    
    private let observersLabel: UILabel = {
        let label = UILabel()
        label.text = "Наблюдатели"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let newObserversCard = InfoCardView()
    private let stoppedObserversCard = InfoCardView()
    
    private var refreshControl: UIRefreshControl!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupUI()
        setupTables()
        setupRefreshControl()
        bindViewModel()
        
        viewModel.refreshTrigger.onNext(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    // MARK: - Setup
    private func setupViewController() {
        title = "Статистика"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(visitorsLabel)
        contentView.addSubview(visitorsInfoCard)
        contentView.addSubview(visitorsSegmentControl)
        contentView.addSubview(chartContainerView)
        
        contentView.addSubview(topVisitorsLabel)
        contentView.addSubview(topVisitorsTable)
        
        contentView.addSubview(genderSectionLabel)
        contentView.addSubview(ageSegmentControl)
        contentView.addSubview(genderAgeView)
        
        contentView.addSubview(observersLabel)
        contentView.addSubview(newObserversCard)
        contentView.addSubview(stoppedObserversCard)
        
        ageSegmentControl.selectButton(at: 3)
    }
    
    private func setupTables() {
        topVisitorsTable.delegate = self
        topVisitorsTable.dataSource = self
        topVisitorsTable.register(TopVisitorCell.self, forCellReuseIdentifier: "TopVisitorCell")
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        visitorsSegmentControl.selectedIndex
            .map { PeriodFilter(rawValue: $0) ?? .daily }
            .bind(to: viewModel.periodFilterRelay)
            .disposed(by: disposeBag)
        
        ageSegmentControl.selectedIndex
            .map { TimeRangeFilter(rawValue: $0) ?? .allTime }
            .bind(to: viewModel.timeRangeFilterRelay)
            .disposed(by: disposeBag)
        
        viewModel.visitorsInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] info in
                self?.updateVisitorsCard(with: info)
            })
            .disposed(by: disposeBag)
        
        viewModel.observersInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] info in
                self?.updateObserversCards(with: info)
            })
            .disposed(by: disposeBag)
        
        viewModel.chartData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] chartData in
                self?.chartContainerView.updateChart(with: chartData)
            })
            .disposed(by: disposeBag)
        
        viewModel.topVisitors
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] visitors in
                self?.topVisitorsData = visitors
                self?.topVisitorsTable.reloadData()
                self?.view.setNeedsLayout()
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.genderDistribution,
            viewModel.ageRanges
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] genderDistribution, ageRanges in
            self?.genderAgeView.configure(genderDistribution: genderDistribution, ageRanges: ageRanges)
            self?.view.setNeedsLayout()
        })
        .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        viewModel.timeRangeFilterRelay.accept(.allTime)
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        viewModel.refreshTrigger.onNext(true)
    }
    
    // MARK: - Update UI
    private func updateVisitorsCard(with info: VisitorsInfoViewModel) {
        visitorsInfoCard.configure(
            icon: .up,
            iconColor: .systemGreen,
            count: "\(info.count)",
            arrow: .upArrow,
            arrowColor: .systemGreen,
            description: info.description
        )
        view.setNeedsLayout()
    }
    
    private func updateObserversCards(with info: ObserversInfoViewModel) {
        newObserversCard.configure(
            icon: .up,
            iconColor: .systemGreen,
            count: "\(info.newCount)",
            arrow: .upArrow,
            arrowColor: .systemGreen,
            description: "Новых наблюдателей в этом месяце"
        )
        
        stoppedObserversCard.configure(
            icon: .down,
            iconColor: .systemRed,
            count: "\(info.stoppedCount)",
            arrow: .downArrow,
            arrowColor: .systemRed,
            description: "Пользователи перестали за Вами наблюдать"
        )
        view.setNeedsLayout()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Layout
    private func layoutViews() {
        scrollView.pin.all(view.pin.safeArea)
        contentView.pin.top().left().right()
        
        var currentY: CGFloat = 16
        
        visitorsLabel.pin.top(currentY).left(16).sizeToFit()
        currentY = visitorsLabel.frame.maxY + 8
        
        visitorsInfoCard.pin.top(currentY).left(16).right(16).height(110)
        currentY = visitorsInfoCard.frame.maxY + 12
        
        visitorsSegmentControl.pin.top(currentY).left(16).right(16).height(36)
        currentY = visitorsSegmentControl.frame.maxY + 12
        
        chartContainerView.pin.top(currentY).left(16).right(16).height(200)
        currentY = chartContainerView.frame.maxY + 16
        
        topVisitorsLabel.pin.top(currentY).left(16).sizeToFit()
        currentY = topVisitorsLabel.frame.maxY + 8
        
        let topVisitorsHeight = CGFloat(topVisitorsData.count * 60)
        topVisitorsTable.pin.top(currentY).left(16).right(16).height(topVisitorsHeight)
        currentY = topVisitorsTable.frame.maxY + 24
        
        genderSectionLabel.pin.top(currentY).left(16).sizeToFit()
        currentY = genderSectionLabel.frame.maxY + 12
        
        ageSegmentControl.pin.top(currentY).left(16).right(16).height(36)
        currentY = ageSegmentControl.frame.maxY + 12
        
        let pieSize: CGFloat = 200
        let legendHeight: CGFloat = 20
        let ageTableHeight: CGFloat = 7 * 44
        let genderAgeHeight = 16 + pieSize + 8 + legendHeight + 12 + 1 + 12 + ageTableHeight + 16
        
        genderAgeView.pin.top(currentY).left(16).right(16).height(genderAgeHeight)
        currentY = genderAgeView.frame.maxY + 24
        
        observersLabel.pin.top(currentY).left(16).sizeToFit()
        currentY = observersLabel.frame.maxY + 8
        
        newObserversCard.pin.top(currentY).left(16).right(16).height(110)
        currentY = newObserversCard.frame.maxY + 12
        
        stoppedObserversCard.pin.top(currentY).left(16).right(16).height(110)
        currentY = stoppedObserversCard.frame.maxY + 16
        
        contentView.pin.wrapContent(.vertically)
        scrollView.contentSize = contentView.frame.size
    }
}

// MARK: - UITableViewDelegate & DataSource
extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topVisitorsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopVisitorCell", for: indexPath) as! TopVisitorCell
        let visitor = topVisitorsData[indexPath.row]
        cell.configure(with: visitor.name, age: visitor.age, avatarURL: visitor.avatarURL)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

