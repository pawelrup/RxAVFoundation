//
//  AVCaptureMetadataOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS)
extension AVCaptureMetadataOutput: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setMetadataObjectsDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVCaptureMetadataOutputObjectsDelegate
}

private class RxAVCaptureMetadataOutputDelegateProxy: DelegateProxy<AVCaptureMetadataOutput, AVCaptureMetadataOutputObjectsDelegate>, DelegateProxyType, AVCaptureMetadataOutputObjectsDelegate {

	public weak private (set) var view: AVCaptureMetadataOutput?

	public init(view: ParentObject) {
		self.view = view
		super.init(parentObject: view, delegateProxy: RxAVCaptureMetadataOutputDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVCaptureMetadataOutputDelegateProxy(view: $0) }
	}
}

extension Reactive where Base: AVCaptureMetadataOutput {

	public var delegate: DelegateProxy<AVCaptureMetadataOutput, AVCaptureMetadataOutputObjectsDelegate> {
		return RxAVCaptureMetadataOutputDelegateProxy.proxy(for: base)
	}

	/// Informs the delegate that the capture output object emitted new metadata objects.
	public var didOutputMetadataObjects: Observable<([AVMetadataObject], AVCaptureConnection)> {
		return delegate.methodInvoked(#selector(AVCaptureMetadataOutputObjectsDelegate.metadataOutput(_:didOutput:from:)))
			.map { ($0[1] as! [AVMetadataObject], $0[2] as! AVCaptureConnection) }
	}
}
#endif
