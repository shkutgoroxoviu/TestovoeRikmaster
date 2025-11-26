//
//  StatisticsView.swift
//  TestovoeRikmaster
//
//  Created by b on 26.11.2025.
//

import UIKit
import RxSwift
internal import RxRelay

final class StatisticsViewBinder {

    private let disposeBag = DisposeBag()

    // MARK: - Properties
    private weak var viewController: StatisticsViewController?
    private let viewModel: StatisticsViewModel

    init(viewController: StatisticsViewController, viewModel: StatisticsViewModel) {
        self.viewController = viewController
        self.viewModel = viewModel
    }

    func bindUI() {
        guard let vc = viewController else { return }

        vc.statisticsView.visitorsSegmentControl.selectedIndex
            .map { PeriodFilter(rawValue: $0) ?? .daily }
            .bind(to: viewModel.periodFilterRelay)
            .disposed(by: disposeBag)

        vc.statisticsView.ageSegmentControl.selectedIndex
            .map { TimeRangeFilter(rawValue: $0) ?? .allTime }
            .bind(to: viewModel.timeRangeFilterRelay)
            .disposed(by: disposeBag)

        vc.statisticsView.ageSegmentControl.selectButton(at: 3)
        viewModel.timeRangeFilterRelay.accept(.allTime)

        viewModel.visitorsInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak vc] info in
                vc?.updateVisitorsCard(with: info)
            })
            .disposed(by: disposeBag)

        viewModel.observersInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak vc] info in
                vc?.updateObserversCards(with: info)
            })
            .disposed(by: disposeBag)

        viewModel.chartData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak vc] chartData in
                vc?.statisticsView.chartContainerView.updateChart(with: chartData)
            })
            .disposed(by: disposeBag)

        viewModel.topVisitors
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak vc] visitors in
                vc?.statisticsView.topVisitorsData = visitors
                vc?.statisticsView.topVisitorsTable.reloadData()
                vc?.statisticsView.setNeedsLayout()
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.genderDistribution,
            viewModel.ageRanges
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak vc] genderDistribution, ageRanges in
            vc?.statisticsView.genderAgeView.configure(
                genderDistribution: genderDistribution,
                ageRanges: ageRanges
            )
            vc?.statisticsView.setNeedsLayout()
        })
        .disposed(by: disposeBag)

        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak vc] isLoading in
                if !isLoading { vc?.statisticsView.refreshControl.endRefreshing() }
            })
            .disposed(by: disposeBag)

        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak vc] error in
                vc?.showError(error)
            })
            .disposed(by: disposeBag)
    }
}
