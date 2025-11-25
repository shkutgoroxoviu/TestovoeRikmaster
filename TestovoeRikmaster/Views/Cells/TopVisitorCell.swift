//
//  TopVisitorCell.swift
//  TestovoeRikmaster
//
//  Created by b on 25.11.2025.
//
import UIKit
import PinLayout
import SDWebImage

// MARK: - TopVisitorCell
class TopVisitorCell: UITableViewCell {
    private let avatar = UIImageView()
    private let usernameLabel = UILabel()
    private let ageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatar)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(ageLabel)
        
        avatar.layer.cornerRadius = 20
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFill
        usernameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        usernameLabel.textColor = .black
        ageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        ageLabel.textColor = .black
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatar.pin.left(16).vCenter().size(40)
        usernameLabel.pin.after(of: avatar).marginLeft(12).vCenter(to: avatar.edge.vCenter).sizeToFit()
        ageLabel.pin.after(of: usernameLabel).vCenter(to: usernameLabel.edge.vCenter).sizeToFit()
    }
    
    func configure(with username: String, age: Int, avatarURL: String?) {
        usernameLabel.text = username
        ageLabel.text = ", \(age)"
        if let urlString = avatarURL, let url = URL(string: urlString) {
            avatar.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.crop.circle.fill"))
        } else {
            avatar.image = UIImage(systemName: "person.crop.circle.fill")
        }
    }
}

