import UIKit
import RxSwift
import RxCocoa

// 네비게이션바 레이블의 높이 = 설정 아이콘 높이 맞추기
// 홈메뉴의 네비게이션바 색상만 블랙으로 or 나머지는 화이트로 / 세 탭바 모두 그레이로 통일

final class CardGameViewController: UIViewController {
    // MARK: - Nested Types
    private enum AnswerKind {
        case like
        case hate
        case skip
        
        var nextAnimationCoordinate: (angle: CGFloat, x: CGFloat, y: CGFloat) {
            switch self {
            case .like:
                return (-(.pi / 4), -(UIScreen.main.bounds.width), -(UIScreen.main.bounds.height / 5))
            case .hate:
                return (.pi / 4, UIScreen.main.bounds.width, -(UIScreen.main.bounds.height / 5))
            case .skip:
                return (.zero, .zero, .zero)
            }
        }
    }
    
    // MARK: - Properties
    private let previousQuestionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("이전 질문", for: .normal)
        button.setTitleColor(Design.previousQuestionButtonTitleColor, for: .normal)
        button.setImage(UIImage(systemName: "arrow.uturn.backward.circle"), for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = .pretendard(family: .regular, size: 15)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        return button
    }()
    private let pinNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.font = .pretendard(family: .regular, size: 15)
        label.textColor = .mainOrange
        label.numberOfLines = 0
        label.lineBreakStrategy = .hangulWordPriority
        return label
    }()
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 50
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: UIScreen.main.bounds.width * 0.1,
            bottom: 0,
            trailing: UIScreen.main.bounds.width * 0.1
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    private let likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Content.likeButtonTitle, for: .normal)
        button.titleLabel?.font = Design.skipButtonTitleFont
        button.backgroundColor = .mainOrange
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        return button
    }()
    private let hateButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Content.hateButtonTitle, for: .normal)
        button.titleLabel?.font = Design.skipButtonTitleFont
        button.backgroundColor = .white
        button.setTitleColor(.mainOrange, for: .normal)
        button.layer.borderColor = UIColor.mainOrange.cgColor
        button.layer.borderWidth = 2
        button.clipsToBounds = true
        return button
    }()
    private let skipAndNextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("다음 (상관 없음)", for: .normal)
        button.setTitleColor(Design.skipButtonTitleColor, for: .normal)
        button.titleLabel?.font = Design.skipButtonTitleFont
        button.backgroundColor = Design.skipButtonBackgroundColor
        button.titleEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 30, right: 0)
        return button
    }()
    
    private var viewModel: CardGameViewModel!
    private let invokedViewDidLoad = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let hangoverCard = YesOrNoCardView(image: UIImage(named: "spicy"), title: "해장이 필요하신가요?")
    private let greasyCard = YesOrNoCardView(image: UIImage(named: "cheers"), title: "장에 기름칠하고 싶으신가요?")
    private let healthCard = YesOrNoCardView(image: UIImage(named: "spicy"), title: "건강을 챙기시나요?")
    private let alcoholCard = YesOrNoCardView(image: UIImage(named: "cheers"), title: "한 잔 하시나요?")
    private let instantCard = YesOrNoCardView(image: UIImage(named: "spicy"), title: "바빠서 빨리 드셔야 하나요?")
    private let spicyCard = YesOrNoCardView(image: UIImage(named: "cheers"), title: "스트레스 받으셨나요?")
    private let richCard = YesOrNoCardView(image: UIImage(named: "spicy"), title: "오늘은 돈 걱정 없으신가요?")
    private let mainIngredientCard = MultipleChoiceCardView(title: "어떤 게 끌리세요?", subtitle: "(다중선택 가능)")
    private let nationCard = MultipleChoiceCardView(title: "어떤 게 끌리세요?", subtitle: "(다중선택 가능)")
    private lazy var cards: [CardViewProtocol] = [
        hangoverCard, greasyCard, healthCard, alcoholCard, instantCard, spicyCard, richCard, mainIngredientCard, nationCard
    ]
    
    typealias CardIndicies = (Int, Int, Int)
    
    // MARK: - Initializers
    convenience init(viewModel: CardGameViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
        invokedViewDidLoad.onNext(())
    }
    
    // MARK: - Methods
    private func configureUI() {
        view.addSubview(previousQuestionButton)
        view.addSubview(pinNumberLabel)
        view.addSubview(buttonStackView)
        view.addSubview(skipAndNextButton)
                
        buttonStackView.addArrangedSubview(likeButton)
        buttonStackView.addArrangedSubview(hateButton)
        
        likeButton.layer.cornerRadius = UIScreen.main.bounds.height * 0.1 * 0.5
        hateButton.layer.cornerRadius = UIScreen.main.bounds.height * 0.1 * 0.5
        
        NSLayoutConstraint.activate([
            previousQuestionButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            previousQuestionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            previousQuestionButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            pinNumberLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            pinNumberLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),

            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            buttonStackView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.1),
            buttonStackView.bottomAnchor.constraint(equalTo: skipAndNextButton.topAnchor, constant: -30),
            
            skipAndNextButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            skipAndNextButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            skipAndNextButton.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.09),
            skipAndNextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func cardFrame(for index: Int) -> CGRect {
        switch index {
        case 0:
            let originX = UIScreen.main.bounds.width * 0.1
            let originY = UIScreen.main.bounds.height * 0.15
            
            let width = UIScreen.main.bounds.width * 0.8
            let height = UIScreen.main.bounds.height * 0.6
            
            return CGRect(origin: CGPoint(x: originX, y: originY),
                          size: CGSize(width: width, height: height))
        case 1:
            let originX = UIScreen.main.bounds.width * 0.11
            let originY = UIScreen.main.bounds.height * 0.14
            
            let width = UIScreen.main.bounds.width * (0.8 - 0.02)
            let height = UIScreen.main.bounds.height * 0.6
            
            return CGRect(origin: CGPoint(x: originX, y: originY),
                          size: CGSize(width: width, height: height))
        case 2:
            let originX = UIScreen.main.bounds.width * 0.12
            let originY = UIScreen.main.bounds.height * 0.13
            
            let width = UIScreen.main.bounds.width * (0.8 - 0.04)
            let height = UIScreen.main.bounds.height * 0.6
            
            return CGRect(origin: CGPoint(x: originX, y: originY),
                          size: CGSize(width: width, height: height))
        default:
            return .zero
        }
    }
}

// MARK: - Rx Binding Methods
extension CardGameViewController {
    private func bind() {
        let input = CardGameViewModel.Input(
            invokedViewDidLoad: invokedViewDidLoad.asObservable(),
            likeButtonDidTap: likeButton.rx.tap.asObservable(),
            hateButtonDidTap: hateButton.rx.tap.asObservable(),
            skipButtonDidTap: skipAndNextButton.rx.tap.asObservable(),
            previousQuestionButtonDidTap: previousQuestionButton.rx.tap.asObservable(),
            menuNationsCellDidSelect: mainIngredientCard.choiceCollectionView.rx.itemSelected.asObservable(),
            mainIngredientsCellDidSelect: nationCard.choiceCollectionView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        configureInitialCardIndiciesAndPinNumber(with: output.initialCardIndiciesAndPinNumber)
        configureMenuNations(with: output.menuNations)
        configureMainIngredients(with: output.mainIngredients)
        configureNextCardIndiciesWhenLike(with: output.nextCardIndiciesWhenLike)
        configureNextCardIndiciesWhenHate(with: output.nextCardIndiciesWhenHate)
        configureNextCardIndiciesWhenSkip(with: output.nextCardIndiciesWhenSkip)
        configurePreviousCardIndiciesAndResult(with: output.previousCardIndiciesAndResult)
        configureMenuNationsSelectedCellAndSkipButton(with: output.menuNationsSelectedindexPath)
        configureMainIngredientsSelectedCellAndSkipButton(with: output.mainIngredientsSelectedindexPath)
    }
    
    private func configureInitialCardIndiciesAndPinNumber(with outputObservable: Observable<(CardIndicies, String?)>) {
        outputObservable
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, initialCardIndiciesAndPinNumber) in
                let ((first, second, third), pinNumber) = initialCardIndiciesAndPinNumber
                guard
                    let firstCard = self.cards[safe: first],
                    let secondCard = self.cards[safe: second],
                    let thirdCard = self.cards[safe: third]
                else { return }
                
//                firstCard.applyGradation(
//                    width: UIScreen.main.bounds.width * 0.8,
//                    height: UIScreen.main.bounds.width * 0.6
//                )
//                secondCard.applyGradation(
//                    width: UIScreen.main.bounds.width * (0.8 - 0.02),
//                    height: UIScreen.main.bounds.width * 0.6
//                )
//                thirdCard.applyGradation(
//                    width: UIScreen.main.bounds.width * (0.8 - 0.04),
//                    height: UIScreen.main.bounds.width * 0.6
//                )
                
                self.view.addSubview(thirdCard)
                self.view.addSubview(secondCard)
                self.view.addSubview(firstCard)
                
                thirdCard.frame = self.cardFrame(for: 2)
                secondCard.frame = self.cardFrame(for: 1)
                firstCard.frame = self.cardFrame(for: 0)
                
                guard let pinNumber = pinNumber else {
                    self.pinNumberLabel.isHidden = true
                    return
                }
                self.pinNumberLabel.text = "PIN Number : \(pinNumber)"
                self.pinNumberLabel.isHidden = false
            })
            .disposed(by: disposeBag)
    }
    
    private func configureMenuNations(with outputObservable: Observable<[MenuNation]>) {
        outputObservable
            .bind(to: mainIngredientCard.choiceCollectionView.rx.items(
                cellIdentifier: String(describing: GameSelectionCell.self),
                cellType: GameSelectionCell.self
            )) { [weak self] _, item, cell in
                self?.mainIngredientCard.changeCollectionViewUI(for: .menuNation)
                cell.apply(isChecked: item.isChecked, descriptionText: item.descriptionText)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureMainIngredients(with outputObservable: Observable<[MainIngredient]>) {
        outputObservable
            .bind(to: nationCard.choiceCollectionView.rx.items(
                cellIdentifier: String(describing: GameSelectionCell.self),
                cellType: GameSelectionCell.self
            )) { [weak self] _, item, cell in
                self?.nationCard.changeCollectionViewUI(for: .mainIngredient)
                cell.apply(isChecked: item.isChecked, descriptionText: item.descriptionText)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureNextCardIndiciesWhenLike(with outputObservable: Observable<CardIndicies>) {
        outputObservable
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, cardIndicies) in
                self.showNextCard(with: cardIndicies, answerKind: .like)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureNextCardIndiciesWhenHate(with outputObservable: Observable<CardIndicies>) {
        outputObservable
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, cardIndicies) in
                self.showNextCard(with: cardIndicies, answerKind: .hate)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureNextCardIndiciesWhenSkip(with outputObservable: Observable<CardIndicies>) {
        outputObservable
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, cardIndicies) in
                self.showNextCard(with: cardIndicies, answerKind: .skip)
            })
            .disposed(by: disposeBag)
    }
    
    private func showNextCard(with cardIndicies: CardIndicies, answerKind: AnswerKind) {
        previousQuestionButton.isHidden = false
        
        let (first, second, third) = cardIndicies
        let submittedCardIndex = first - 1
        
        let firstIndexOfMultipleChoiceCard = 7
        if first >= firstIndexOfMultipleChoiceCard {
            buttonStackView.isHidden = true
        }
        
        guard
            let firstCard = cards[safe: first],
            let submittedCard = cards[safe: submittedCardIndex]
        else { return }
        
        nextCardAnimation(
            firstCard: firstCard,
            secondCard: cards[safe: second],
            thirdCard: cards[safe: third],
            submittedCard: submittedCard,
            animationCoordinate: answerKind.nextAnimationCoordinate
        )
    }
    
    private func nextCardAnimation(
        firstCard: CardViewProtocol,
        secondCard: CardViewProtocol?,
        thirdCard: CardViewProtocol?,
        submittedCard: CardViewProtocol,
        animationCoordinate: (angle: CGFloat, x: CGFloat, y: CGFloat)
    ) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) { [weak self] in
            guard let self = self else { return }
            let rotate = CGAffineTransform(rotationAngle: animationCoordinate.angle)
            let move = CGAffineTransform(
                translationX: animationCoordinate.x,
                y: animationCoordinate.y
            )
            let combine = rotate.concatenating(move)
            submittedCard.transform = combine
            submittedCard.alpha = 0

            firstCard.frame = self.cardFrame(for: 0)
            secondCard?.frame = self.cardFrame(for: 1)
//
//            firstCard.applyGradation(
//                width: UIScreen.main.bounds.width * 0.8,
//                height: UIScreen.main.bounds.width * 0.6
//            )
//            secondCard?.applyGradation(
//                width: UIScreen.main.bounds.width * (0.8 - 0.02),
//                height: UIScreen.main.bounds.width * 0.6
//            )
//            thirdCard?.applyGradation(
//                width: UIScreen.main.bounds.width * (0.8 - 0.04),
//                height: UIScreen.main.bounds.width * 0.6
//            )
        } completion: { [weak self] _ in
            guard let self = self else { return }
            submittedCard.removeFromSuperview()
            
            guard let thirdCard = thirdCard else { return }
            self.view.insertSubview(thirdCard, at: 0)
            thirdCard.frame = self.cardFrame(for: 2)
        }
    }
    
    private func configurePreviousCardIndiciesAndResult(with outputObservable: Observable<(CardIndicies, Bool?)>) {
        outputObservable
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, cardIndiciesAndResult) in
                let (previousCardIndicies, latestAnswer) = cardIndiciesAndResult
                
                var answerKind: AnswerKind?
                switch latestAnswer {
                case .some(true):
                    answerKind = .like
                case .some(false):
                    answerKind = .hate
                case .none:
                    answerKind = .skip
                }
                guard let answerKind = answerKind else { return }

                self.showPreviousCard(with: previousCardIndicies, answerKind: answerKind)
            })
            .disposed(by: disposeBag)
    }

    private func showPreviousCard(with cardIndicies: CardIndicies, answerKind: AnswerKind) {
        let (first, second, third) = cardIndicies
        
        let previousThirdCardIndex = third + 1
        guard let firstCard = self.cards[safe: first] else { return }
        
        let firstIndexOfMultipleChoiceCard = 7
        if first == 0 {
            previousQuestionButton.isHidden = true
        } else if first <= firstIndexOfMultipleChoiceCard - 1 {
            buttonStackView.isHidden = false
        }
        
        self.view.addSubview(firstCard)
        previousCardAnimation(
            firstCard: firstCard,
            secondCard: self.cards[safe: second],
            thirdCard: self.cards[safe: third],
            previousThirdCard: self.cards[safe: previousThirdCardIndex]
        )
    }
    
    private func previousCardAnimation(
        firstCard: CardViewProtocol,
        secondCard: CardViewProtocol?,
        thirdCard: CardViewProtocol?,
        previousThirdCard: CardViewProtocol?
    ) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
            guard let self = self else { return }
//            firstCard.applyGradation(
//                width: UIScreen.main.bounds.width * 0.8,
//                height: UIScreen.main.bounds.width * 0.6
//            )
//            secondCard?.applyGradation(
//                width: UIScreen.main.bounds.width * (0.8 - 0.02),
//                height: UIScreen.main.bounds.width * 0.6
//            )
//            thirdCard?.applyGradation(
//                width: UIScreen.main.bounds.width * (0.8 - 0.04),
//                height: UIScreen.main.bounds.width * 0.6
//            )
//            
            let rotate = CGAffineTransform(rotationAngle: .zero)
            firstCard.transform = rotate
            firstCard.alpha = 1

            firstCard.frame = self.cardFrame(for: 0)
            secondCard?.frame = self.cardFrame(for: 1)
            thirdCard?.frame = self.cardFrame(for: 2)
            
            previousThirdCard?.removeFromSuperview()
        }
    }
    
    private func configureMenuNationsSelectedCellAndSkipButton(with indexPath: Observable<IndexPath>) {
        indexPath
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                guard
                    let selectedCell = self.mainIngredientCard.choiceCollectionView.cellForItem(at: indexPath) as? GameSelectionCell
                else { return }
                selectedCell.toggleSelectedCellUI()
            })
            .disposed(by: disposeBag)
    }
    
    private func configureMainIngredientsSelectedCellAndSkipButton(with indexPath: Observable<IndexPath>) {
        indexPath
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                guard
                    let selectedCell = self.nationCard.choiceCollectionView.cellForItem(at: indexPath) as? GameSelectionCell
                else { return }
                selectedCell.toggleSelectedCellUI()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - NameSpaces
extension CardGameViewController {
    private enum Design {
        static let previousQuestionButtonTitleColor: UIColor = .label
        static let skipButtonBackgroundColor: UIColor = .mainYellow
        static let skipButtonTitleColor: UIColor = .label
        static let skipButtonTitleFont: UIFont = .pretendard(family: .regular, size: 20)
    }
    
    private enum Content {
        static let skipButtonTitle: String = "Skip"
        static let likeButtonTitle: String = "좋아요"
        static let hateButtonTitle: String = "싫어요"
    }
}
