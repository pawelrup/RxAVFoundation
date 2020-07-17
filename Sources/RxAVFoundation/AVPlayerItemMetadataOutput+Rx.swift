//
//  AVPlayerItemMetadataOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

extension AVPlayerItemMetadataOutput: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVPlayerItemMetadataOutputPushDelegate
}

private class RxAVPlayerItemMetadataOutputDelegateProxy: DelegateProxy<AVPlayerItemMetadataOutput, AVPlayerItemMetadataOutputPushDelegate>, DelegateProxyType, AVPlayerItemMetadataOutputPushDelegate {

	public weak private (set) var view: AVPlayerItemMetadataOutput?

	public init(view: ParentObject) {
		self.view = view
		super.init(parentObject: view, delegateProxy: RxAVPlayerItemMetadataOutputDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVPlayerItemMetadataOutputDelegateProxy(view: $0) }
	}
}

extension Reactive where Base: AVPlayerItemMetadataOutput {

	public var delegate: DelegateProxy<AVPlayerItemMetadataOutput, AVPlayerItemMetadataOutputPushDelegate> {
		RxAVPlayerItemMetadataOutputDelegateProxy.proxy(for: base)
	}

	public var outputMediaDataWillChange: Observable<([AVTimedMetadataGroup], AVPlayerItemTrack?)> {
		delegate
			.methodInvoked(#selector(AVPlayerItemMetadataOutputPushDelegate.metadataOutput(_:didOutputTimedMetadataGroups:from:)))
			.map { ($0[1] as! [AVTimedMetadataGroup], $0[2] as? AVPlayerItemTrack) }
	}
}
