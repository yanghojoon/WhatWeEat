import UIKit
import RealmSwift

final class DislikedFoodCell: UICollectionViewCell {
    // MARK: - Nested Types
    struct DislikedFood: Hashable {
        var isChecked: Bool = false
        let descriptionImage: UIImage
        let descriptionText: String
    }
    
    // MARK: - Properties
    private let checkBoxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = Content.uncheckedImage
        imageView.tintColor = .black
        return imageView
    }()
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 15, bottom: 15, trailing: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    private let descriptionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = Design.descriptionLabelFont
        label.numberOfLines = 0
        label.lineBreakStrategy = .hangulWordPriority
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
        checkBoxImageView.image = nil
        descriptionImageView.image = nil
        descriptionLabel.text = nil
    }
    
    // MARK: - Methods
    func apply(descriptionImage: UIImage, descriptionText: String) {
        descriptionImageView.image = descriptionImage
        descriptionLabel.text = descriptionText
    }
    
    func toggleSelectedCellUI() {
        if checkBoxImageView.image == Content.uncheckedImage {
            checkBoxImageView.image = Content.checkedImage
            self.backgroundColor = ColorPalette.mainYellow
        } else {
            checkBoxImageView.image = Content.uncheckedImage
            self.backgroundColor = ColorPalette.subYellow
        }
    }
    
    private func configureUI() {
        self.backgroundColor = ColorPalette.subYellow
        
        addSubview(checkBoxImageView)
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(descriptionImageView)
        containerStackView.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            checkBoxImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            checkBoxImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            checkBoxImageView.heightAnchor.constraint(equalTo: checkBoxImageView.widthAnchor),
            checkBoxImageView.heightAnchor.constraint(equalToConstant: 30),
            descriptionImageView.heightAnchor.constraint(equalTo: descriptionImageView.widthAnchor),
            descriptionImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
        ])
    }
}

// MARK: - NameSpaces
extension DislikedFoodCell {
    private enum Design {
        static let descriptionLabelFont: UIFont = .preferredFont(forTextStyle: .title3)
    }
    
    private enum Content {
        static let checkedImage = UIImage(systemName: "checkmark.square")
        static let uncheckedImage = UIImage(systemName: "square")
    }
}
