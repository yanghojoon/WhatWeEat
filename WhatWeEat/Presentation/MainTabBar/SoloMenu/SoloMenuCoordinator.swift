import UIKit

protocol MenuCoordinatorDelegate: AnyObject {
    func hideNavigationBarAndTabBar()
    func showTabBar()
    func removeFromChildCoordinatorsAndRestart(coordinator: CoordinatorProtocol)
}

final class SoloMenuCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController?
    var type: CoordinatorType = .home
    weak var delegate: MenuCoordinatorDelegate!
    
    func start() {
    }
    
    func createSoloMenuViewcontroller() -> UINavigationController {
        let soloMenuViewModel = SoloMenuViewModel(coordinator: self)
        let soloMenuViewController = SoloMenuViewController(viewModel: soloMenuViewModel)
        navigationController = UINavigationController(rootViewController: soloMenuViewController)
        navigationController?.navigationBar.isHidden = true
        
        guard let navigationController = navigationController else {
            return UINavigationController()
        }

        return navigationController
    }
    
    func showGamePage(with pinNumber: String? = nil) {
        hideNavigationBarAndTabBar()
        
        guard let navigationController = navigationController else { return }
        let gameCoordinator = GameCoordinator(navigationController: navigationController, pinNumber: pinNumber)
        gameCoordinator.delegate = self
        childCoordinators.append(gameCoordinator)
        gameCoordinator.start()
    }
}

extension SoloMenuCoordinator: GameCoordinatorDelegate {
    func hideNavigationBarAndTabBar() {
        delegate.hideNavigationBarAndTabBar()
    }
    
    func showTabBar() {
        delegate.showTabBar()
    }
    
    func removeFromChildCoordinators(coordinator: CoordinatorProtocol) {
        let updatedChildCoordinators = childCoordinators.filter { $0 !== coordinator }
        childCoordinators = updatedChildCoordinators
    }
    
    func showTogetherPage() {
        guard let mainTabBarController = navigationController?.viewControllers.first as? MainTabBarController else {
            return
        }
        mainTabBarController.selectedIndex = 1
        navigationController?.viewControllers = [mainTabBarController]
    }
}
