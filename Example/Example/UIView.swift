import UIKit

extension UIView {
  func fill(with subView: UIView?) {
    guard let subView = subView else { return }

    subView.translatesAutoresizingMaskIntoConstraints = false
    self.subviews.forEach { subView in
      subView.removeFromSuperview()
    }
    self.addSubview(subView)
    subView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    subView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    subView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    subView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  }
}
