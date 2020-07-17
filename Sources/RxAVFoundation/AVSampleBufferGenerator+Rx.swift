//
//  AVSampleBufferGenerator+Rx.swift
//  
//
//  Created by Pawel Rup on 17/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(macOS)
extension Reactive where Base: AVSampleBufferGenerator {

	/// Notifies the sample buffer generator when data is ready for the sample buffer reference or an error has occurred.
	/// - Parameter sbuf: The CMSampleBufferRef.
	public static func notifyOfDataReady(for sbuf: CMSampleBuffer) -> Single<Void> {
		Single.create { event in
			AVSampleBufferGenerator.notifyOfDataReady(for: sbuf) { dataReady, error in
				if dataReady {
					event(.success(()))
				} else {
					event(.error(error))
				}
			}
			return Disposables.create()
		}
	}
}
#endif
