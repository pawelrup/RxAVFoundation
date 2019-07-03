//
//  AVSampleBufferAudioRenderer+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

@available(iOS 11.0, tvOS 11.0, macOS 10.13, *)
extension Reactive where Base: AVSampleBufferAudioRenderer {

	/// Flushes queued sample buffers with presentation time stamps later than or equal to the specified time.
	/// - Parameter time: The time used to flush all later sample buffers.
	public func flush(fromSourceTime time: CMTime) -> Single<Bool> {
		return Single.create { event -> Disposable in
			self.base.flush(fromSourceTime: time) { (flushSucceeded) in
				event(.success(flushSucceeded))
			}
			return Disposables.create()
		}
	}
}
