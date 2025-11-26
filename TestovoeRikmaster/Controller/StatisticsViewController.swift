import UIKit
import RxSwift

final class StatisticsViewController: UIViewController {

    // MARK: - Properties
    private let viewModel = StatisticsViewModel()
    private var binder: StatisticsViewBinder!
    private let disposeBag = DisposeBag()

    let statisticsView = StatisticsView()

    // MARK: - Lifecycle
    override func loadView() {
        view = statisticsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Статистика"
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)

        // Таблицы
        statisticsView.topVisitorsTable.delegate = self
        statisticsView.topVisitorsTable.dataSource = self
        statisticsView.topVisitorsTable.register(TopVisitorCell.self, forCellReuseIdentifier: "TopVisitorCell")

        // Инициализация биндинга
        binder = StatisticsViewBinder(viewController: self, viewModel: viewModel)
        binder.bindUI()

        viewModel.refreshTrigger.onNext(false)

        // Обработка pull to refresh
        statisticsView.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    @objc private func refreshData() {
        viewModel.refreshTrigger.onNext(true)
    }

    // MARK: - UI Updates
    func updateVisitorsCard(with info: VisitorsInfoViewModel) {
        statisticsView.visitorsInfoCard.configure(
            icon: .up,
            iconColor: .systemGreen,
            count: "\(info.count)",
            arrow: .upArrow,
            arrowColor: .systemGreen,
            description: info.description
        )
        view.setNeedsLayout()
    }

    func updateObserversCards(with info: ObserversInfoViewModel) {
        statisticsView.newObserversCard.configure(
            icon: .up,
            iconColor: .systemGreen,
            count: "\(info.newCount)",
            arrow: .upArrow,
            arrowColor: .systemGreen,
            description: "Новых наблюдателей в этом месяце"
        )

        statisticsView.stoppedObserversCard.configure(
            icon: .down,
            iconColor: .systemRed,
            count: "\(info.stoppedCount)",
            arrow: .downArrow,
            arrowColor: .systemRed,
            description: "Пользователи перестали за Вами наблюдать"
        )
        view.setNeedsLayout()
    }

    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statisticsView.topVisitorsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopVisitorCell", for: indexPath) as! TopVisitorCell
        let visitor = statisticsView.topVisitorsData[indexPath.row]
        cell.configure(with: visitor.name, age: visitor.age, avatarURL: visitor.avatarURL)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
