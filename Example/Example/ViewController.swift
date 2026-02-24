import UIKit
import Combine
import FluxxKit

class ViewController: UIViewController {

  @IBOutlet var requestingView: UIView!
  @IBOutlet var failedView: UIView!
  @IBOutlet var emptyView: UIView!
  @IBOutlet weak var contentsView: UIView!
  @IBOutlet weak var searchBar: UISearchBar!

  var repositoryViewController: RepositoryViewController?
  private var cancellables = Set<AnyCancellable>()
  private let searchSubject = PassthroughSubject<String, Never>()
  var store = Store<ViewModel, ViewModel.Action>(
    reducer: ViewModel.Reducer()
  )

  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    Dispatcher.shared.register(middleware: ViewModel.SearchMiddleware())
    Dispatcher.shared.register(store: self.store)
    bindSearchBar()
    bindState(store.state)
    repositoryViewController = RepositoryViewController.make(viewModel: store.state)
  }

  deinit {
    Dispatcher.shared.unregister(middleware: ViewModel.SearchMiddleware.self)
    Dispatcher.shared.unregister(store: store)
  }

}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    let encoded = searchText.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
    searchSubject.send(encoded)
  }
}

// MARK: - Bindings
private extension ViewController {

  func bindSearchBar() {
    searchSubject
      .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
      .removeDuplicates()
      .sink { text in
        Dispatcher.shared.dispatch(
          action: ViewModel.Action.search(text: text)
        )
      }
      .store(in: &cancellables)
  }

  func bindState(_ state: ViewModel) {
    state.$viewState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] viewState in
        switch viewState {
        case .requesting:
          self?.contentsView.fill(with: self?.requestingView)

        case .failed:
          self?.contentsView.fill(with: self?.failedView)

        case .empty:
          self?.contentsView.fill(with: self?.emptyView)

        case .done:
          self?.contentsView.fill(with: self?.repositoryViewController?.tableView)
          self?.repositoryViewController?.tableView.reloadData()
        }
      }
      .store(in: &cancellables)
  }
}
