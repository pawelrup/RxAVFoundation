//
//  AVPlayerItemLegibleOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(tvOS) || os(macOS)
extension AVPlayerItemLegibleOutput: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVPlayerItemLegibleOutputPushDelegate
}

private class RxAVPlayerItemLegibleOutputDelegateProxy: DelegateProxy<AVPlayerItemLegibleOutput, AVPlayerItemLegibleOutputPushDelegate>, DelegateProxyType, AVPlayerItemLegibleOutputPushDelegate {

	public weak private (set) var view: AVPlayerItemLegibleOutput?

	public init(view: ParentObject) {
		self.view = view
		super.init(parentObject: view, delegateProxy: RxAVPlayerItemLegibleOutputDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVPlayerItemLegibleOutputDelegateProxy(view: $0) }
	}
}

extension Reactive where Base: AVPlayerItemLegibleOutput {

	public var delegate: DelegateProxy<AVPlayerItemLegibleOutput, AVPlayerItemLegibleOutputPushDelegate> {
		RxAVPlayerItemLegibleOutputDelegateProxy.proxy(for: base)
	}

	public var didOutput: Observable<([NSAttributedString], [Any], CMTime)> {
		delegate
			.methodInvoked(#selector(AVPlayerItemLegibleOutputPushDelegate.legibleOutput(_:didOutputAttributedStrings:nativeSampleBuffers:forItemTime:)))
			.map { ($0[1] as! [NSAttributedString], $0[2] as! [Any], $0[3] as! CMTime) }
	}
}
#endif
