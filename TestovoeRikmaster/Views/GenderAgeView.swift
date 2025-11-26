import UIKit
import DGCharts
import PinLayout

// MARK: - GenderAgeView

class GenderAgeView: UIView {
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let genderPieChartView: PieChartView = {
        let chart = PieChartView()
        chart.legend.enabled = false
        chart.holeColor = .clear
        chart.drawEntryLabelsEnabled = false
        chart.rotationAngle = 0
        chart.isUserInteractionEnabled = false
        chart.holeRadiusPercent = 1 - (15 / 200)
        chart.transparentCircleRadiusPercent = 0
        return chart
    }()
    
    private let maleLegendView = UIView()
    private let femaleLegendView = UIView()
    private let maleDot: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1, green: 46/255, blue: 0, alpha: 1)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    private let femaleDot: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 249/255, green: 153/255, blue: 99/255, alpha: 1)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    private let maleTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private let femaleTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private let legendSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    private(set) var ageTable: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.backgroundColor = .white
        return table
    }()
    
    private var ageRangeData: [AgeRangeViewModel] = []
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        
        containerView.addSubview(genderPieChartView)
        containerView.addSubview(maleLegendView)
        containerView.addSubview(femaleLegendView)
        containerView.addSubview(legendSeparator)
        containerView.addSubview(ageTable)
        
        maleLegendView.addSubview(maleDot)
        maleLegendView.addSubview(maleTextLabel)
        
        femaleLegendView.addSubview(femaleDot)
        femaleLegendView.addSubview(femaleTextLabel)
    }
    
    private func setupTable() {
        ageTable.delegate = self
        ageTable.dataSource = self
        ageTable.register(AgeCell.self, forCellReuseIdentifier: "AgeCell")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.pin.all()
        
        let containerWidth = bounds.width
        let pieSize: CGFloat = 200
        let legendHeight: CGFloat = 20
        let spacing: CGFloat = 16
        
        genderPieChartView.pin.top(16).hCenter().size(CGSize(width: pieSize, height: pieSize))
        
        let maleTextWidth = maleTextLabel.intrinsicContentSize.width
        let femaleTextWidth = femaleTextLabel.intrinsicContentSize.width
        let dotWidth: CGFloat = 10
        let totalWidth = dotWidth + 4 + maleTextWidth + spacing + dotWidth + 4 + femaleTextWidth
        let startX = (containerWidth - totalWidth) / 2
        let legendY = genderPieChartView.frame.maxY + 8
        
        maleLegendView.pin
            .left(startX)
            .top(legendY)
            .width(dotWidth + 4 + maleTextWidth)
            .height(legendHeight)

        femaleLegendView.pin.after(of: maleLegendView, aligned: .top).marginLeft(spacing).size(CGSize(width: dotWidth + 4 + femaleTextWidth, height: legendHeight))
        
        maleDot.pin.left().vCenter().size(CGSize(width: 10, height: 10))
        maleTextLabel.pin.after(of: maleDot).marginLeft(4).vCenter().sizeToFit()
        
        femaleDot.pin.left().vCenter().size(CGSize(width: 10, height: 10))
        femaleTextLabel.pin.after(of: femaleDot).marginLeft(4).vCenter().sizeToFit()
        
        legendSeparator.pin.below(of: maleLegendView).marginTop(12).horizontally(16).height(1)
        
        let ageTableHeight = CGFloat(ageRangeData.count * 44)
        ageTable.pin.below(of: legendSeparator).marginTop(12).horizontally().height(ageTableHeight)
    }
    
    // MARK: - Public Methods
    func configure(genderDistribution: GenderDistributionViewModel, ageRanges: [AgeRangeViewModel]) {
        self.ageRangeData = ageRanges

        updateGenderChart(with: genderDistribution)
        updateLegend(with: genderDistribution)

        ageTable.reloadData()
        setNeedsLayout()
    }

    private func updateGenderChart(with viewModel: GenderDistributionViewModel) {
        guard viewModel.hasData else {
            genderPieChartView.data = nil
            genderPieChartView.noDataText = "Нет данных"
            genderPieChartView.noDataTextColor = .darkGray
            genderPieChartView.noDataFont = .systemFont(ofSize: 16, weight: .medium)
            genderPieChartView.setNeedsDisplay()
            return
        }
        
        let maleEntry = PieChartDataEntry(value: Double(viewModel.maleCount))
        let femaleEntry = PieChartDataEntry(value: Double(viewModel.femaleCount))
        
        let dataSet = PieChartDataSet(entries: [maleEntry, femaleEntry])
        dataSet.colors = [
            UIColor(red: 1, green: 46/255, blue: 0, alpha: 1),
            UIColor(red: 249/255, green: 153/255, blue: 99/255, alpha: 1)
        ]
        dataSet.sliceSpace = 4
        dataSet.drawValuesEnabled = false
        
        genderPieChartView.data = PieChartData(dataSet: dataSet)
        genderPieChartView.notifyDataSetChanged()
    }
    
    private func updateLegend(with viewModel: GenderDistributionViewModel) {
        if !viewModel.hasData {
            maleLegendView.isHidden = true
            femaleLegendView.isHidden = true
            return
        }
        
        maleLegendView.isHidden = false
        femaleLegendView.isHidden = false
        
        maleTextLabel.text = "Мужчины \(viewModel.malePercentage)%"
        femaleTextLabel.text = "Женщины \(viewModel.femalePercentage)%"
        setNeedsLayout()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension GenderAgeView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ageRangeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgeCell", for: indexPath) as! AgeCell
        let viewModel = ageRangeData[indexPath.row]
        cell.configure(
            range: viewModel.rangeLabel,
            maleCount: viewModel.maleCount,
            femaleCount: viewModel.femaleCount,
            malePercentage: viewModel.malePercentage,
            femalePercentage: viewModel.femalePercentage
        )
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

