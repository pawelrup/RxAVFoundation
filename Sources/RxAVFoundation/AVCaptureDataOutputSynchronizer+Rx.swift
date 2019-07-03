//
//  AVCaptureDataOutputSynchronizer+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS)
@available(iOS 11.0, *)
extension AVCaptureDataOutputSynchronizer: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVCaptureDataOutputSynchronizerDelegate
}

@available(iOS 11.0, *)
private class RxAVCaptureDataOutputSynchronizerDelegateProxy: DelegateProxy<AVCaptureDataOutputSynchronizer, AVCaptureDataOutputSynchronizerDelegate>, DelegateProxyType, AVCaptureDataOutputSynchronizerDelegate {

	private var shouldWaitForResponseToAuthenticationChallengeSubject = PublishSubject<AVCaptureSynchronizedDataCollection>()

	var shouldWaitForResponseToAuthenticationChallenge: Observable<AVCaptureSynchronizedDataCollection>

	public weak private (set) var view: AVCaptureDataOutputSynchronizer?

	public init(view: ParentObject) {
		self.view = view
		shouldWaitForResponseToAuthenticationChallenge = shouldWaitForResponseToAuthenticationChallengeSubject.asObservable()
		super.init(parentObject: view, delegateProxy: RxAVCaptureDataOutputSynchronizerDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVCaptureDataOutputSynchronizerDelegateProxy(view: $0) }
	}

	func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
		shouldWaitForResponseToAuthenticationChallengeSubject.onNext(synchronizedDataCollection)
	}
}

@available(iOS 11.0, *)
extension Reactive where Base: AVCaptureDataOutputSynchronizer {

	public var delegate: DelegateProxy<AVCaptureDataOutputSynchronizer, AVCaptureDataOutputSynchronizerDelegate> {
		return RxAVCaptureDataOutputSynchronizerDelegateProxy.proxy(for: base)
	}

	public var shouldWaitForResponseToAuthenticationChallenge: Observable<AVCaptureSynchronizedDataCollection> {
		return (delegate as! RxAVCaptureDataOutputSynchronizerDelegateProxy).shouldWaitForResponseToAuthenticationChallenge
	}
}
#endif
