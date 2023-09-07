import SwiftUI

/// For use in dependency declarations that return a normal SwiftUI View
protocol ViewProviding {
    associatedtype SomeView: View
    var view: SomeView { get }
}

struct MockViewProvider<SomeView: View>: ViewProviding {
    var view: SomeView
}

extension ViewProviding {
    typealias Mock = MockViewProvider
}
