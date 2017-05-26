import UIKit
import FluxxKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

  @IBOutlet var requestingView: UIView!
  @IBOutlet var failedView: UIView!
  @IBOutlet var emptyView: UIView!
  @IBOutlet weak var contentsView: UIView!
  @IBOutlet weak var searchBar: UISearchBar!

  var repositoryViewController: RepositoryViewController?
  var disposeBag = DisposeBag()
  var store = Store<ViewModel, ViewModel.Action>(
    reducer: ViewModel.Reducer()
  )

  override func viewDidLoad() {
    super.viewDidLoad()
    Dispatcher.shared.register(middleware: ViewModel.SearchMiddleware())
    Dispatcher.shared.register(store: self.store)
    bind(state: store.state)
    bind(searchBar: searchBar)
    repositoryViewController = RepositoryViewController.make(viewModel: store.state)
  }

  deinit {
    Dispatcher.shared.unregister(middleware: ViewModel.SearchMiddleware.self)
    Dispatcher.shared.unregister(store: store)
  }

}

// MARK: - Bindings
private extension ViewController {

  func bind(searchBar: UISearchBar) {
    searchBar
      .rx
      .text
      .orEmpty
      .map {
        $0.addingPercentEncoding(
          withAllowedCharacters: .alphanumerics
        ) ?? ""
      }
      .debounce(0.3, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { text in
          Dispatcher.shared.dispatch(
            action: ViewModel.Action.search(text: text)
          )
        }
      ).addDisposableTo(self.disposeBag)
  }

  func bind(state: ViewModel) {
    state
      .viewState
      .asObservable()
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { [weak self] viewState in
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
      ).addDisposableTo(self.disposeBag)
  }
}
