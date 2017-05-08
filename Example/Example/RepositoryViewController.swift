import UIKit

final class RepositoryViewController: UITableViewController {

  weak var viewModel: ViewModel?

  static func make(viewModel: ViewModel) -> RepositoryViewController? {
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
      withIdentifier: "RepositoryViewController"
    ) as? RepositoryViewController
    vc?.viewModel = viewModel
    return vc
  }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RepositoryViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel?.repositories.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let repository = viewModel?.repositories[indexPath.row]
    cell.textLabel?.text = repository?.name
    return cell
  }
}
