import UIKit
import Foundation

extension Array {
    mutating func remove<T: Equatable>(obj: T) -> Array {
        self = self.filter({$0 as? T != obj})
        return self;
    }
}