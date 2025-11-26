import UIKit
import DGCharts

// MARK: - ChartContainerView

class ChartContainerView: UIView {
    
    // MARK: - Properties
    private(set) var chartView: LineChartView!
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureChart()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        
        chartView = LineChartView()
        addSubview(chartView)
    }
    
    private func configureChart() {
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
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
    // MARK: - Public Methods
    func updateChart(with viewModel: ChartDataViewModel) {
        guard !viewModel.entries.isEmpty else {
            chartView.data = nil
            chartView.notifyDataSetChanged()
            return
        }
        
        var chartEntries: [ChartDataEntry] = []
        var labels: [String] = []
        
        for (index, entry) in viewModel.entries.enumerated() {
            let chartEntry = ChartDataEntry(x: Double(index), y: Double(entry.value))
            chartEntry.data = entry.label
            chartEntries.append(chartEntry)
            labels.append(entry.label)
        }
        
        let dataSet = LineChartDataSet(entries: chartEntries, label: "")
        dataSet.colors = [UIColor.red]
        dataSet.circleColors = [UIColor.red]
        dataSet.circleRadius = 4
        dataSet.lineWidth = 2
        dataSet.drawValuesEnabled = false
        
        chartView.data = LineChartData(dataSet: dataSet)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        chartView.xAxis.granularity = 1
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = max(5, Double(viewModel.maxValue) * 1.2)
        chartView.notifyDataSetChanged()
    }
}

