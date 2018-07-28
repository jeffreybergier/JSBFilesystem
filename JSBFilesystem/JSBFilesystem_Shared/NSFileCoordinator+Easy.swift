import Foundation
import IGListKit

internal class FileURLDiffer: NSObject, ListDiffable {
    internal let fileURL: NSURL
    internal let modificationDate: NSDate
    internal init(fileURL: NSURL, modificationDate: NSDate) {
        self.fileURL = fileURL
        self.modificationDate = modificationDate
        super.init()
    }
    internal func diffIdentifier() -> NSObjectProtocol {
        return self.fileURL
    }
    internal func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        // test #1 - bail if not the right object type
        guard let rhs = object as? FileURLDiffer else { return false }
        // test #2 - bail if the modification dates are different
        guard self.modificationDate.isEqual(rhs.modificationDate) else { return false }
        // test #3 - everything has passed so far, just return the final test
        return self.fileURL.isEqual(rhs.fileURL)
    }
}
