//
//  AVCaptureVideoDataOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(macOS)
extension AVCaptureVideoDataOutput: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setSampleBufferDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVCaptureVideoDataOutputSampleBufferDelegate
}

private class RxAVCaptureVideoDataOutputDelegateProxy: DelegateProxy<AVCaptureVideoDataOutput, AVCaptureVideoDataOutputSampleBufferDelegate>, DelegateProxyType, AVCaptureVideoDataOutputSampleBufferDelegate {

	public weak private (set) var view: AVCaptureVideoDataOutput?

	public init(view: ParentObject) {
		self.view = view
		super.init(parentObject: view, delegateProxy: RxAVCaptureVideoDataOutputDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVCaptureVideoDataOutputDelegateProxy(view: $0) }
	}
}

extension Reactive where Base: AVCaptureVideoDataOutput {

	public var delegate: DelegateProxy<AVCaptureVideoDataOutput, AVCaptureVideoDataOutputSampleBufferDelegate> {
		RxAVCaptureVideoDataOutputDelegateProxy.proxy(for: base)
	}

	/// Notifies the delegate that a new video frame was written.
	public var didOutputSampleBuffer: Observable<(CMSampleBuffer, AVCaptureConnection)> {
		delegate
			.methodInvoked(#selector(AVCaptureVideoDataOutputSampleBufferDelegate.captureOutput(_:didOutput:from:)))
			.map { ($0[1] as! CMSampleBuffer, $0[2] as! AVCaptureConnection) }
	}

	/// Notifies the delegate that a video frame was discarded.
	public var didDropSampleBuffer: Observable<(CMSampleBuffer, AVCaptureConnection)> {
		delegate
			.methodInvoked(#selector(AVCaptureVideoDataOutputSampleBufferDelegate.captureOutput(_:didDrop:from:)))
			.map { ($0[1] as! CMSampleBuffer, $0[2] as! AVCaptureConnection) }
	}
}
#endif
