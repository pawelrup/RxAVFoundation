//
//  AVSampleBufferDisplayLayer+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(tvOS) || os(macOS)
@available(iOS 11.0, tvOS 11.0, macOS 10.13, *)
extension Reactive where Base: AVSampleBufferDisplayLayer {

	/// Removes a renderer from the synchronizer.
	/// - Parameter queue: The time on the timebase's timeline at which the renderer should be removed. If the time is in the past, the renderer is immediately removed..
	public func requestMediaDataWhenReady(on queue: DispatchQueue) -> Single<Void> {
		Single.create { event in
			base.requestMediaDataWhenReady(on: queue) {
				event(.success(()))
			}
			return Disposables.create()
		}
	}
}
#endif
