//
//  AVPlayerItemVideoOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(tvOS) || os(macOS)
extension AVPlayerItemVideoOutput: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVPlayerItemOutputPullDelegate
}

private class RxAVPlayerItemVideoOutputDelegateProxy: DelegateProxy<AVPlayerItemVideoOutput, AVPlayerItemOutputPullDelegate>, DelegateProxyType, AVPlayerItemOutputPullDelegate {

	public weak private (set) var view: AVPlayerItemVideoOutput?

	public init(view: ParentObject) {
		self.view = view
		super.init(parentObject: view, delegateProxy: RxAVPlayerItemVideoOutputDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVPlayerItemVideoOutputDelegateProxy(view: $0) }
	}
}

extension Reactive where Base: AVPlayerItemVideoOutput {

	public var delegate: DelegateProxy<AVPlayerItemVideoOutput, AVPlayerItemOutputPullDelegate> {
		RxAVPlayerItemVideoOutputDelegateProxy.proxy(for: base)
	}

	public var outputMediaDataWillChange: Observable<Void> {
		delegate
			.methodInvoked(#selector(AVPlayerItemOutputPullDelegate.outputMediaDataWillChange(_:)))
			.map { _ in () }
	}

	public var outputSequenceWasFlushed: Observable<Void> {
		delegate
			.methodInvoked(#selector(AVPlayerItemOutputPullDelegate.outputSequenceWasFlushed(_:)))
			.map { _ in () }
	}
}
#endif
