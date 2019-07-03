//
//  AVAssetImageGenerator+Rx.swift
//  
//
//  Created by Pawel Rup on 14/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(tvOS) || os(macOS)
extension Reactive where Base: AVAssetImageGenerator {

	/// Creates a series of image objects for an asset at or near specified times.
	/// - Parameter requestedTimes: An array of NSValue objects, each containing a CMTime, specifying the asset times at which an image is requested.
	func generateCGImagesAsynchronously(forTimes requestedTimes: [NSValue]) -> Single<(CMTime, CGImage?, CMTime, AVAssetImageGenerator.Result)> {
		return Single.create { event -> Disposable in
			self.base.generateCGImagesAsynchronously(forTimes: requestedTimes) { (requestedTime, image, actualTime, result, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success((requestedTime, image, actualTime, result)))
				}
			}
			return Disposables.create()
		}
	}
}
#endif
