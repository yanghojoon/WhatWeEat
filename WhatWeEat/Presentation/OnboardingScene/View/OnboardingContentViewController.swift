import UIKit

final class OnboardingContentViewController: UIViewController, OnboardingContentProtocol {
    // MARK: - Properties
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Design.containerStackViewSpacing
        return stackView
    }()
    private let descriptionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Design.imageCornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Design.titleLabelFont
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.numberOfLines = .zero
        label.lineBreakStrategy = .hangulWordPriority
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Design.descriptionLabelFont
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.numberOfLines = .zero
        label.lineBreakStrategy = .hangulWordPriority
        return label
    }()

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Initializers
    init(titleLabelText: String, descriptionLabelText: String, image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.titleLabel.text = titleLabelText
        self.descriptionLabel.text = descriptionLabelText
        
        guard let image = image else {
            self.descriptionImageView.isHidden = true
            return
        }
        self.descriptionImageView.image = image
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func configureUI () {
        view.addSubview(containerStackView)
        containerStackView.addArrangedSubview(descriptionImageView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: Constraint.containerStackViewTopAnchorConstant
            ),
            containerStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constraint.containerStackViewLeadingAnchorConstant
            ),
            containerStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Constraint.containerStackViewTrailingAnchorConstant
            ),
            descriptionImageView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Constraint.containerStackViewHeightAnchorConstant
            ),
            descriptionImageView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor),
        ])
    }
}

// MARK: - Namespaces
extension OnboardingContentViewController {
    private enum Design {
        static let titleLabelFont: UIFont = .pretendard(family: .medium, size: 30)
        static let descriptionLabelFont: UIFont = .pretendard(family: .regular, size: 20)
        static let imageCornerRadius: CGFloat = 5
        static let containerStackViewSpacing: CGFloat = 20
    }
    
    private enum Constraint {
        static let containerStackViewTopAnchorConstant: CGFloat = UIScreen.main.bounds.height * 0.15
        static let containerStackViewLeadingAnchorConstant: CGFloat = 20
        static let containerStackViewTrailingAnchorConstant: CGFloat = -20
        static let containerStackViewHeightAnchorConstant: CGFloat = UIScreen.main.bounds.height * 0.25
    }
}
