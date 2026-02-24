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
  private nonisolated(unsafe) var storeIdentifier: String = ""
  var store = Store<ViewModel, ViewModel.Action>(
    reducer: ViewModel.Reducer()
  )

  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    Dispatcher.shared.register(middleware: ViewModel.SearchMiddleware())
    Dispatcher.shared.register(store: self.store)
    storeIdentifier = store.identifier
    bindSearchBar()
    bindState(store.state)
    repositoryViewController = RepositoryViewController.make(viewModel: store.state)
  }

  deinit {
    let id = storeIdentifier
    Task { @MainActor in
      Dispatcher.shared.unregister(middleware: ViewModel.SearchMiddleware.self)
      Dispatcher.shared.unregister(store: id)
    }
  }

}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchSubject.send(searchText)
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
