//
//  AVCaptureAudioDataOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 14/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(macOS)
extension AVCaptureAudioDataOutput: HasDelegate {

	public var delegate: Delegate? {
		get {
			sampleBufferDelegate
		}
		set(newValue) {
			setSampleBufferDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVCaptureAudioDataOutputSampleBufferDelegate
}

private class RxAVCaptureAudioDataOutputDelegateProxy: DelegateProxy<AVCaptureAudioDataOutput, AVCaptureAudioDataOutputSampleBufferDelegate>, DelegateProxyType, AVCaptureAudioDataOutputSampleBufferDelegate {

	public weak private (set) var view: AVCaptureAudioDataOutput?

	public init(view: ParentObject) {
		self.view = view
		super.init(parentObject: view, delegateProxy: RxAVCaptureAudioDataOutputDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVCaptureAudioDataOutputDelegateProxy(view: $0) }
	}
}

extension Reactive where Base: AVCaptureAudioDataOutput {

	public var delegate: DelegateProxy<AVCaptureAudioDataOutput, AVCaptureAudioDataOutputSampleBufferDelegate> {
		RxAVCaptureAudioDataOutputDelegateProxy.proxy(for: base)
	}

	/// Notifies that a sample buffer was written.
	public var didOutputFromConnection: Observable<(CMSampleBuffer, AVCaptureConnection)> {
		delegate
			.methodInvoked(#selector(AVCaptureAudioDataOutputSampleBufferDelegate.captureOutput(_:didOutput:from:)))
			.map { ($0[1] as! CMSampleBuffer, $0[2] as! AVCaptureConnection) }
	}
}
#endif
