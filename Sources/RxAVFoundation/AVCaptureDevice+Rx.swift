//
//  AVCaptureDevice+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(macOS)
extension Reactive where Base: AVCaptureDevice {

	#if os(iOS)
	/// Locks the exposure duration and ISO at the specified values.
	/// - Parameter duration: The exposure duration.
	/// - Parameter ISO: The exposure ISO value.
	public func setExposureModeCustom(duration: CMTime, iso ISO: Float) -> Single<CMTime> {
		return Single.create { event -> Disposable in
			self.base.setExposureModeCustom(duration: duration, iso: ISO) { (timestamp) in
				event(.success(timestamp))
			}
			return Disposables.create()
		}
	}

	/// Sets the bias to be applied to the target exposure value.
	/// - Parameter bias: The bias to be applied to the exposure target value.
	public func setExposureTargetBias(_ bias: Float) -> Single<CMTime> {
		return Single.create { event -> Disposable in
			self.base.setExposureTargetBias(bias) { (timestamp) in
				event(.success(timestamp))
			}
			return Disposables.create()
		}
	}

	/// Sets white balance to locked mode with the specified deviceWhiteBalanceGains values.
	/// - Parameter whiteBalanceGains: The white balance gains to set.
	public func setWhiteBalanceModeLocked(with whiteBalanceGains: AVCaptureDevice.WhiteBalanceGains) -> Single<CMTime> {
		return Single.create { event -> Disposable in
			self.base.setWhiteBalanceModeLocked(with: whiteBalanceGains) { (timestamp) in
				event(.success(timestamp))
			}
			return Disposables.create()
		}
	}
	#endif

	/// Requests the user’s permission, if needed, for recording a specified media type.
	/// - Parameter mediaType: A media type constant, either video or audio.
	@available(macOS 10.14, *)
	public static func requestAccess(for mediaType: AVMediaType) -> Single<Bool> {
		return Single.create { event -> Disposable in
			AVCaptureDevice.requestAccess(for: mediaType) { (granted) in
				event(.success(granted))
			}
			return Disposables.create()
		}
	}
}
#endif
