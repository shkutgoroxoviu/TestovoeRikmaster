import UIKit
import PinLayout

// MARK: - InfoCardView - переиспользуемая карточка с информацией

class InfoCardView: UIView {
    
    // MARK: - UI Elements
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(iconImageView)
        addSubview(countLabel)
        addSubview(arrowImageView)
        addSubview(descriptionLabel)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 12
        iconImageView.pin.left(padding).vCenter().size(CGSize(width: 95, height: 50))
        countLabel.pin.top(padding).after(of: iconImageView, aligned: .top).marginLeft(8).sizeToFit()
        arrowImageView.pin.after(of: countLabel, aligned: .center).marginLeft(4).size(CGSize(width: 16, height: 16))
        descriptionLabel.pin.below(of: countLabel).marginTop(4).left(countLabel.frame.minX).right(padding).height(40)
    }
    
    // MARK: - Configuration
    func configure(icon: UIImage?, iconColor: UIColor, count: String, arrow: UIImage?, arrowColor: UIColor, description: String) {
        iconImageView.image = icon
        iconImageView.tintColor = iconColor
        countLabel.text = count
        arrowImageView.image = arrow
        arrowImageView.tintColor = arrowColor
        descriptionLabel.text = description
        setNeedsLayout()
    }
}

