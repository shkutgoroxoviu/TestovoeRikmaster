//
//  VisitorMarker.swift
//  TestovoeRikmaster
//
//  Created by b on 25.11.2025.
//
import UIKit
import DGCharts

class VisitorsMarkerView: MarkerView {
    private let visitsLabel = UILabel()
    private let dateLabel = UILabel()
    private let container = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowRadius = 4
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(container)

        visitsLabel.font = .systemFont(ofSize: 12, weight: .bold)
        visitsLabel.textColor = UIColor(red: 1, green: 46/255, blue: 0, alpha: 1)
        visitsLabel.textAlignment = .center
        container.addSubview(visitsLabel)

        dateLabel.font = .systemFont(ofSize: 10)
        dateLabel.textColor = .black
        dateLabel.textAlignment = .center
        container.addSubview(dateLabel)
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let count = Int(entry.y)
        visitsLabel.text = "\(count) посетителей"
        dateLabel.text = entry.data as? String ?? ""
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 8
        let width: CGFloat = 120
        let height: CGFloat = 50
        container.frame = CGRect(x: 0, y: 0, width: width, height: height)
        visitsLabel.frame = CGRect(x: padding, y: padding, width: width - 2*padding, height: 20)
        dateLabel.frame = CGRect(x: padding, y: visitsLabel.frame.maxY + 4, width: width - 2*padding, height: 18)
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        return CGPoint(x: -60, y: -70)
    }
}
