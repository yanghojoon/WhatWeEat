import UIKit
import RealmSwift

final class DislikedFoodCell: UICollectionViewCell {
    // MARK: - Properties
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 20,
            leading: 10,
            bottom: 20,
            trailing: 10
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 10
        return stackView
    }()
    private let descriptionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Design.descriptionLabelFont
        label.numberOfLines = 0
        label.lineBreakStrategy = .hangulWordPriority
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
//        checkBoxImageView.image = nil
        descriptionImageView.image = nil
        descriptionLabel.text = nil
    }
    
    // MARK: - Methods
    func apply(isChecked: Bool, descriptionImage: UIImage, descriptionText: String) {
        if isChecked {
            toggleSelectedCellUI()
        }
        descriptionImageView.image = descriptionImage
        descriptionLabel.text = descriptionText
    }
    
    func toggleSelectedCellUI() {
        if self.backgroundColor == .subYellow {
            self.backgroundColor = .mainYellow
        } else {
            self.backgroundColor = .subYellow
        }
    }
    
    private func configureUI() {
        self.backgroundColor = .subYellow
        self.applyShadow(direction: .bottom)
        
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(descriptionImageView)
        containerStackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([  // TODO: ?????? Namespaces ??????
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            descriptionImageView.heightAnchor.constraint(greaterThanOrEqualTo: self.heightAnchor, multiplier: 0.4),
            descriptionImageView.heightAnchor.constraint(equalTo: descriptionImageView.widthAnchor),
        ])
    }
}

// MARK: - NameSpaces
extension DislikedFoodCell {
    private enum Design {
        static let descriptionLabelFont: UIFont = .pretendard(family: .medium, size: 18)
    }
    
    private enum Content {
        static let checkedImage = UIImage(systemName: "checkmark.square")
        static let uncheckedImage = UIImage(systemName: "square")
    }
}
