//
//  AVAssetResourceLoader+Rx.swift
//  
//
//  Created by Pawel Rup on 14/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(tvOS) || os(macOS)
extension AVAssetResourceLoader: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVAssetResourceLoaderDelegate
}

private class RxAVAssetResourceLoaderDelegateProxy: DelegateProxy<AVAssetResourceLoader, AVAssetResourceLoaderDelegate>, DelegateProxyType, AVAssetResourceLoaderDelegate {

	private var didCancelLoadingRequestSubject = PublishSubject<AVAssetResourceLoadingRequest>()
	private var didCancelAuthenticationChallengeSubject = PublishSubject<URLAuthenticationChallenge>()

	var didCancelLoadingRequest: Observable<AVAssetResourceLoadingRequest>
	var didCancelAuthenticationChallenge: Observable<URLAuthenticationChallenge>

	public weak private (set) var view: AVAssetResourceLoader?

	public init(view: ParentObject) {
		self.view = view
		didCancelLoadingRequest = didCancelLoadingRequestSubject.asObservable()
		didCancelAuthenticationChallenge = didCancelAuthenticationChallengeSubject.asObservable()
		super.init(parentObject: view, delegateProxy: RxAVAssetResourceLoaderDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVAssetResourceLoaderDelegateProxy(view: $0) }
	}

	func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
		didCancelLoadingRequestSubject.onNext(loadingRequest)
	}

	func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel authenticationChallenge: URLAuthenticationChallenge) {
		didCancelAuthenticationChallengeSubject.onNext(authenticationChallenge)
	}
}

extension Reactive where Base: AVAssetResourceLoader {

	public var delegate: DelegateProxy<AVAssetResourceLoader, AVAssetResourceLoaderDelegate> {
		return RxAVAssetResourceLoaderDelegateProxy.proxy(for: base)
	}

	/// Informs that a prior loading request has been cancelled.
	var didCancelLoadingRequest: Observable<AVAssetResourceLoadingRequest> {
		return (delegate as! RxAVAssetResourceLoaderDelegateProxy).didCancelLoadingRequest
	}

	/// Tells that assistance is required of the application to respond to an authentication challenge.
	@available(iOS 9.0, *)
	public var shouldWaitForResponseToAuthenticationChallenge: Observable<URLAuthenticationChallenge> {
		return delegate.methodInvoked(#selector(AVAssetResourceLoaderDelegate.resourceLoader(_:shouldWaitForResponseTo:)))
			.map { $0[1] as! URLAuthenticationChallenge }
	}

	/// Informs that a prior authentication challenge has been cancelled.
	var didCancelAuthenticationChallenge: Observable<URLAuthenticationChallenge> {
		return (delegate as! RxAVAssetResourceLoaderDelegateProxy).didCancelAuthenticationChallenge
	}
}
#endif
