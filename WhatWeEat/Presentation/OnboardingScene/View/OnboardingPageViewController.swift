import UIKit
import RxSwift

final class OnboardingPageViewController: UIPageViewController {
    // MARK: - Properties
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = Design.pageControlCurrentPageIndicatorTintColor
        pageControl.pageIndicatorTintColor = Design.pageControlPageIndicatorTintColor
        pageControl.currentPage = 0
        pageControl.backgroundStyle = .minimal
        pageControl.allowsContinuousInteraction = false
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "arrow")
        return imageView
    }()
    private let skipButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Design.skipAndConfirmButtonTitleFont,
            .foregroundColor: Design.skipAndConfirmButtonTitleColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedString = NSMutableAttributedString(string: Content.skipButtonTitle, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()

    private var onboardingPages = [OnboardingContentProtocol]()
    private let currentIndexForPreviousPage = PublishSubject<Int>()
    private let currentIndexForNextPageAndPageCount = PublishSubject<(Int, Int)>()
    private var viewModel: OnboardingViewModel!
    private var viewModelOutput: OnboardingViewModel.Output?
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    convenience init(viewModel: OnboardingViewModel, pages: [OnboardingContentProtocol]) {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.viewModel = viewModel
        self.onboardingPages = pages
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        configureUI()
        bind()
    }
    
    // MARK: - Methods
    private func setupPages() {
        dataSource = self
        delegate = self
        
        guard let firstPage = onboardingPages.first as? UIViewController else { return }
        setViewControllers([firstPage], direction: .forward, animated: true)
        pageControl.numberOfPages = onboardingPages.count
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(pageControl)
        view.addSubview(arrowImageView)
        view.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -UIScreen.main.bounds.height * 0.15
            ),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            arrowImageView.centerYAnchor.constraint(equalTo: skipButton.centerYAnchor),
            arrowImageView.leadingAnchor.constraint(equalTo: pageControl.leadingAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: skipButton.leadingAnchor, constant: -5),
            arrowImageView.heightAnchor.constraint(equalToConstant: 45),
            
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            skipButton.widthAnchor.constraint(equalToConstant: skipButton.intrinsicContentSize.width + 30),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
    }
}

// MARK: - Rx Binding Methods
extension OnboardingPageViewController {
    private func bind() {
        let input = OnboardingViewModel.Input(
            currentIndexForPreviousPage: currentIndexForPreviousPage.asObservable(),
            currentIndexForNextPageAndPageCount: currentIndexForNextPageAndPageCount.asObservable(),
            skipButtonDidTap: skipButton.rx.tap.asObservable()
        )
        
        viewModelOutput = viewModel.transform(input)
        guard let skipButtonDidTap = viewModelOutput?.skipButtonDidTap else { return }
        
        configureSkipButtonDidTap(with: skipButtonDidTap)
    }
    
    private func configureSkipButtonDidTap(with skipButtonDidTap: Observable<Void>) {
        skipButtonDidTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let lastPageIndex = 2
                self.hideButtonIfLastPage(lastPageIndex)
                guard let lastPage = self.onboardingPages.last as? UIViewController else { return }
                self.setViewControllers([lastPage], direction: .forward, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - PageViewController DataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        // TODO: ????????? ??????????????? ?????? ??? ????????? - ????????? CurrentIndex??? ???????????? ??? ??????. 
        guard let onboardingPages = onboardingPages as? [UIViewController],
              let currentIndex = onboardingPages.firstIndex(of: viewController) // -1 ??????????????? ??????
        else {
            return nil
        }
        var viewController: UIViewController?
        
        // ????????? ????????? ????????? ????????? ??????. VC??? weak ??????????????? ??? => ??????????????? ???????????? weak viewController ??????
        // onError??? ???????????? ????????? ????????? ????????? ????????? ?????? ??? ??????
        viewModelOutput?.previousPageIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self, weak viewController] previousIndex in  // FIXME: 1) subscribe??? ????????? ???????????? ??????, 2) ???????????? ?????? VC??? retain count??? ????????? (retain ???????????? ????????? ????????? ?????? ??????)
                print(previousIndex)
                guard let previousIndex = previousIndex else {
                    viewController = nil
                    return
                }
                
                // subscript ??????
                viewController = self?.onboardingPages[previousIndex] as? UIViewController // FIXME: ??????????????? ?????? ????????? ????????? ??? ??????
                // semaphore??? ?????? ??????
                // subscribe??? ????????? ?????? ???????????? ?????? ????????? (??????????????? ????????? ????????? ??????) ???????????? ?????????
            })
            .disposed(by: disposeBag)
        
        currentIndexForPreviousPage.onNext(currentIndex)
        
        return viewController
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let onboardingPages = onboardingPages as? [UIViewController],
              let currentIndex = onboardingPages.firstIndex(of: viewController)
        else {
            return nil
        }
        print(currentIndex)
        var viewController: UIViewController?
        
        viewModelOutput?.nextPageIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { nextIndex in
                guard let nextIndex = nextIndex else {
                    viewController = nil
                    return
                }
                viewController = onboardingPages[nextIndex]
            })
            .disposed(by: disposeBag)
        
        currentIndexForNextPageAndPageCount.onNext((currentIndex, onboardingPages.count))
        
        return viewController
    }
}

// MARK: - PageViewController Delegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard let viewController = pageViewController.viewControllers?.first,
              let onboardingPages = onboardingPages as? [UIViewController],
              let currentIndex = onboardingPages.firstIndex(of: viewController)
        else { return }
        
        presentButtonUnlessLastPage(currentIndex)
    }
    
    private func presentButtonUnlessLastPage(_ currentIndex: Int) {
        if currentIndex != onboardingPages.count - 1 {
            arrowImageView.isHidden = false
            skipButton.isHidden = false
            pageControl.isHidden = false
        }
    }
        
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        guard let onboardingPages = onboardingPages as? [UIViewController],
              let viewController = pendingViewControllers.first,
              let currentIndex = onboardingPages.firstIndex(of: viewController)
        else { return }
        pageControl.currentPage = currentIndex
        hideButtonIfLastPage(currentIndex)
    }
    
    private func hideButtonIfLastPage(_ currentIndex: Int) {
        if currentIndex == onboardingPages.count - 1 {
            arrowImageView.isHidden = true
            skipButton.isHidden = true
            pageControl.isHidden = true
        }
    }
}

// MARK: - NameSpaces
extension OnboardingPageViewController {
    private enum Design {
        static let pageControlCurrentPageIndicatorTintColor: UIColor = .mainOrange
        static let pageControlPageIndicatorTintColor: UIColor = .systemGray
        static let skipAndConfirmButtonTitleColor: UIColor = .mainOrange
        static let skipAndConfirmButtonTitleFont: UIFont = .pretendard(family: .medium, size: 25)
    }
    
    private enum Content {
        static let skipButtonTitle: String = "Skip"
    }
}
