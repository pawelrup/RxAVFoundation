//
//  AVAssetWriter+Rx.swift
//  
//
//  Created by Pawel Rup on 14/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(tvOS) || os(macOS)
extension Reactive where Base: AVAssetWriter {

	/// Marks all unfinished inputs as finished and completes the writing of the output file.
	public func finishWriting() -> Single<Void> {
		Single.create { event in
			base.finishWriting {
				event(.success(()))
			}
			return Disposables.create()
		}
	}
}
#endif
