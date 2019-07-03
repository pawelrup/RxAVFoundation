//
//  AVQueuedSampleBufferRendering+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

@available(iOS 11.0, tvOS 11.0, macOS 10.13, *)
extension Reactive where Base: AVQueuedSampleBufferRendering {

	/// Tells the target to invoke a client-supplied block in order to gather sample buffers for playback.
	/// - Parameter queue: The dispatch queue.
	public func requestMediaDataWhenReady(on queue: DispatchQueue) -> Single<Void> {
		return Single.create { event -> Disposable in
			self.base.requestMediaDataWhenReady(on: queue) {
				event(.success(()))
			}
			return Disposables.create()
		}
	}
}
