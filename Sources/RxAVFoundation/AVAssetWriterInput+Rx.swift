//
//  AVAssetWriterInput+Rx.swift
//  
//
//  Created by Pawel Rup on 14/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(tvOS) || os(macOS)
extension Reactive where Base: AVAssetWriterInput {

	/// Instructs the receiver to invoke a block repeatedly, at its convenience, to gather media data for writing to the output.
	/// - Parameter queue: The queue on which block should be invoked.
	public func requestMediaDataWhenReady(on queue: DispatchQueue) -> Single<Void> {
		Single.create { event in
			base.requestMediaDataWhenReady(on: queue) {
				event(.success(()))
			}
			return Disposables.create()
		}
	}

	/// Instructs the receiver to invoke a client-supplied block whenever a new pass has begun.
	/// - Parameter queue: The queue on which the block should be invoked.
	public func respondToEachPassDescription(on queue: DispatchQueue) -> Single<Void> {
		return Single.create { event -> Disposable in
			base.respondToEachPassDescription(on: queue) {
				event(.success(()))
			}
			return Disposables.create()
		}
	}
}
#endif
