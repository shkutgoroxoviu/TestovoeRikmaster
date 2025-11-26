//
//  StatisticsView.swift
//  TestovoeRikmaster
//
//  Created by b on 26.11.2025.
//

import UIKit
import PinLayout

final class StatisticsView: UIView {

    // MARK: - UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()

    let visitorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Посетители"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()

    let visitorsInfoCard = InfoCardView()
    lazy var visitorsSegmentControl = CustomSegmentControl(items: ["По дням", "По неделям", "По месяцам"])
    let chartContainerView = ChartContainerView()

    let topVisitorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Чаще всех посещают Ваш профиль"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()

    let topVisitorsTable: UITableView = {
        let table = UITableView()
        table.layer.cornerRadius = 8
        table.backgroundColor = .white
        return table
    }()
    var topVisitorsData: [TopVisitorViewModel] = []

    let genderSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Пол и возраст"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    lazy var ageSegmentControl = CustomSegmentControl(items: ["Сегодня", "Неделя", "Месяц", "Все время"])
    let genderAgeView = GenderAgeView()

    let observersLabel: UILabel = {
        let label = UILabel()
        label.text = "Наблюдатели"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()

    let newObserversCard = InfoCardView()
    let stoppedObserversCard = InfoCardView()

    var refreshControl: UIRefreshControl!

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupRefreshControl()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupRefreshControl()
    }

    // MARK: - Setup UI
    private func setupUI() {
        addSubview(scrollView)
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

    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        scrollView.refreshControl = refreshControl
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }

    private func layoutViews() {
        scrollView.pin.all(self.pin.safeArea)
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
