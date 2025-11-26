//
//  Untitled.swift
//  TestovoeRikmaster
//
//  Created by b on 25.11.2025.
//
import UIKit
import PinLayout

class AgeCell: UITableViewCell {
    
    private let rangeLabel = UILabel()
    
    private let maleProgress = UIView()
    private let femaleProgress = UIView()
    
    private let malePercentLabel = UILabel()
    private let femalePercentLabel = UILabel()
    
    private let minProgressWidth: CGFloat = 4
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(rangeLabel)
        contentView.addSubview(maleProgress)
        contentView.addSubview(femaleProgress)
        contentView.addSubview(malePercentLabel)
        contentView.addSubview(femalePercentLabel)
        
        rangeLabel.font = .systemFont(ofSize: 14)
        rangeLabel.textColor = .black
        
        maleProgress.backgroundColor = UIColor(red: 1, green: 46/255, blue: 0, alpha: 1)
        maleProgress.layer.cornerRadius = 3
        maleProgress.clipsToBounds = true
        
        femaleProgress.backgroundColor = UIColor(red: 249/255, green: 153/255, blue: 99/255, alpha: 1)
        femaleProgress.layer.cornerRadius = 3
        femaleProgress.clipsToBounds = true
        
        malePercentLabel.font = .systemFont(ofSize: 12, weight: .medium)
        femalePercentLabel.font = .systemFont(ofSize: 12, weight: .medium)
        malePercentLabel.textColor = .black
        femalePercentLabel.textColor = .black
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rangeLabel.pin.left(16).top(4).sizeToFit()
        
        maleProgress.pin.left(80).top(6).height(6)
        malePercentLabel.pin.left(to: maleProgress.edge.right).marginLeft(4).vCenter(to: maleProgress.edge.vCenter).sizeToFit()
        
        femaleProgress.pin.left(80).top(20).height(6)
        femalePercentLabel.pin.left(to: femaleProgress.edge.right).marginLeft(4).vCenter(to: femaleProgress.edge.vCenter).sizeToFit()
    }
    
    func configure(
        range: String,
        maleCount: Int,
        femaleCount: Int,
        malePercentage: Int,
        femalePercentage: Int
    ) {
        rangeLabel.text = range

        let totalUsers = maleCount + femaleCount
        guard totalUsers > 0 else {
            maleProgress.frame.size.width = 5
            femaleProgress.frame.size.width = 5
            malePercentLabel.text = "0%"
            femalePercentLabel.text = "0%"
            return
        }

        let maxWidth = contentView.bounds.width - 100
        
        let maleWidth: CGFloat = malePercentage == 0 ? 5 : max(CGFloat(malePercentage) / 100 * maxWidth, minProgressWidth)
        let femaleWidth: CGFloat = femalePercentage == 0 ? 5 : max(CGFloat(femalePercentage) / 100 * maxWidth, minProgressWidth)
        
        maleProgress.frame.size.width = maleWidth
        femaleProgress.frame.size.width = femaleWidth
        
        malePercentLabel.text = "\(malePercentage)%"
        femalePercentLabel.text = "\(femalePercentage)%"
    }
}
