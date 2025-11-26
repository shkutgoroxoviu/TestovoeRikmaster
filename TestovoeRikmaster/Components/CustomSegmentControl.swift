import UIKit
import RxSwift
import RxCocoa

// MARK: - CustomSegmentControl 

class CustomSegmentControl: UIView {
    
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private var buttons: [UIButton] = []
    private let selectedIndexRelay = BehaviorRelay<Int>(value: 0)
    
    var selectedIndex: Observable<Int> {
        return selectedIndexRelay.asObservable()
    }
    
    // MARK: - Initialization
    init(items: [String]) {
        super.init(frame: .zero)
        setupButtons(with: items)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupButtons(with items: [String]) {
        for (index, title) in items.enumerated() {
            let button = createButton(title: title, tag: index)
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        selectButton(at: 0)
    }
    
    private func createButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.backgroundColor = .clear
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.clipsToBounds = true
        button.tag = tag
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    @objc private func buttonTapped(_ sender: UIButton) {
        selectButton(at: sender.tag)
        selectedIndexRelay.accept(sender.tag)
    }
    
    func selectButton(at index: Int) {
        for (i, button) in buttons.enumerated() {
            if i == index {
                button.isSelected = true
                button.backgroundColor = UIColor(red: 1, green: 46/255, blue: 0, alpha: 1)
                button.setTitleColor(.white, for: .normal)
            } else {
                button.isSelected = false
                button.backgroundColor = .clear
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
}

