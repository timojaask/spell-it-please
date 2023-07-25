import UIKit

extension UITableView {
    func scrollToBottom(at scrollPosition: UITableView.ScrollPosition = .bottom, animated: Bool = true) {
        guard let indexPath = lastRowIndexPath() else {
            return
        }
        
        self.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    
    func lastRowIndexPath() -> IndexPath? {
        guard numberOfSections > 0 else { return nil }
        let lastSectionIndex = numberOfSections - 1
        
        guard numberOfRows(inSection: lastSectionIndex) > 0 else { return nil }
        let lastRowIndex = numberOfRows(inSection: lastSectionIndex) - 1
        
        return IndexPath(row: lastRowIndex, section: lastSectionIndex)
    }
}
