// From: https://gist.github.com/MartinMoizard/c39e8d84b58fda5e7e845ca3eec385ac

import Foundation
import RxSwift

public protocol LoadingDataConvertible {
    /// Type of element in event
    associatedtype ElementType

    /// Event representation of this instance
    var data: Event<ElementType>? { get }
    var loading: Bool { get }
}

public struct LoadingResult<E>: LoadingDataConvertible {
    public let data: Event<E>?
    public let loading: Bool

    public init(_ loading: Bool) {
        data = nil
        self.loading = loading
    }

    public init(_ data: Event<E>) {
        self.data = data
        loading = false
    }
}

extension ObservableType {
    public func monitorLoading() -> Observable<LoadingResult<E>> {
        return materialize()
            .map(LoadingResult.init)
            .startWith(LoadingResult(true))
    }
}

extension ObservableType where E: LoadingDataConvertible {
    public func loading() -> Observable<Bool> {
        return map { $0.loading }
    }

    public func data() -> Observable<E.ElementType> {
        return events()
            .elements()
    }

    public func errors() -> Observable<Error> {
        return events()
            .errors()
    }

    // MARK: - Private

    private func events() -> Observable<Event<E.ElementType>> {
        return filter { !$0.loading }
            .map { $0.data }
            .unwrap()
    }
}
