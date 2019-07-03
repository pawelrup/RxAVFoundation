//
//  AVCaptureStillImageOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(macOS)
extension Reactive where Base: AVCaptureStillImageOutput {

	/// Initiates a still image capture and returns immediately.
	/// - Parameter connection: The connection from which to capture the image.
	public func captureStillImageAsynchronously(from connection: AVCaptureConnection) -> Single<CMSampleBuffer?> {
		return Single.create { event -> Disposable in
			self.base.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success(sampleBuffer))
				}
			}
			return Disposables.create()
		}
	}

	#if os(iOS)
	/// Allows the receiver to prepare resources in advance of capturing a still image bracket.
	/// - Parameter connection: The connection through which the still image bracket should be captured.
	/// - Parameter settings: An array of AVCaptureBracketedStillImageSettings objects. All the array items must be of the same AVCaptureBracketedStillImageSettings subclass, or an invalidArgumentException exception is thrown.
	@available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use AVCapturePhotoOutput setPreparedPhotoSettingsArray:completionHandler: instead.")
	public func prepareToCaptureStillImageBracket(from connection: AVCaptureConnection, withSettingsArray settings: [AVCaptureBracketedStillImageSettings]) -> Single<Bool> {
		return Single.create { event -> Disposable in
			self.base.prepareToCaptureStillImageBracket(from: connection, withSettingsArray: settings) { (prepared, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success(prepared))
				}
			}
			return Disposables.create()
		}
	}

	/// Captures a still image bracket.
	/// - Parameter connection: The connection through which the still image bracket should be captured.
	/// - Parameter settings: An array of AVCaptureBracketedStillImageSettings objects. All the array items must be of the same AVCaptureBracketedStillImageSettings subclass, or an invalidArgumentException exception is thrown.
	@available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use AVCapturePhotoOutput capturePhotoWithSettings:delegate: instead.")
	public func captureStillImageBracketAsynchronously(from connection: AVCaptureConnection, withSettingsArray settings: [AVCaptureBracketedStillImageSettings]) -> Single<(CMSampleBuffer?, AVCaptureBracketedStillImageSettings?)> {
		return Single.create { event -> Disposable in
			self.base.captureStillImageBracketAsynchronously(from: connection, withSettingsArray: settings) { (sampleBuffer, imageSettings, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success((sampleBuffer, imageSettings)))
				}
			}
			return Disposables.create()
		}
	}
	#endif
}
#endif
