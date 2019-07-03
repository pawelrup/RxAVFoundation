//
//  AVCaptureDepthDataOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS)
@available(iOS 11.0, *)
extension AVCaptureDepthDataOutput: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, callbackQueue: .main)
		}
	}

	public typealias Delegate = AVCaptureDepthDataOutputDelegate
}

@available(iOS 11.0, *)
private class RxAVCaptureDataOutputSynchronizerDelegateProxy: DelegateProxy<AVCaptureDepthDataOutput, AVCaptureDepthDataOutputDelegate>, DelegateProxyType, AVCaptureDepthDataOutputDelegate {

	public weak private (set) var view: AVCaptureDepthDataOutput?

	public init(view: ParentObject) {
		self.view = view
		super.init(parentObject: view, delegateProxy: RxAVCaptureDataOutputSynchronizerDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVCaptureDataOutputSynchronizerDelegateProxy(view: $0) }
	}
}

@available(iOS 11.0, *)
extension Reactive where Base: AVCaptureDepthDataOutput {

	public var delegate: DelegateProxy<AVCaptureDepthDataOutput, AVCaptureDepthDataOutputDelegate> {
		return RxAVCaptureDataOutputSynchronizerDelegateProxy.proxy(for: base)
	}

	/// Called whenever an AVCaptureDepthDataOutput instance outputs a new depth data object.
	public var didOutputDepthData: Observable<(AVDepthData, CMTime, AVCaptureConnection)> {
		return delegate.methodInvoked(#selector(AVCaptureDepthDataOutputDelegate.depthDataOutput(_:didOutput:timestamp:connection:)))
			.map { ($0[1] as! AVDepthData, $0[2] as! CMTime, $0[3] as! AVCaptureConnection) }
	}

	/// Called once for each depth data that is discarded.
	public var didDropDepthData: Observable<(AVDepthData, CMTime, AVCaptureConnection, AVCaptureOutput.DataDroppedReason)> {
		return delegate.methodInvoked(#selector(AVCaptureDepthDataOutputDelegate.depthDataOutput(_:didOutput:timestamp:connection:)))
			.map { ($0[1] as! AVDepthData, $0[2] as! CMTime, $0[3] as! AVCaptureConnection, $0[4] as! AVCaptureOutput.DataDroppedReason) }
	}
}
#endif
