//
//  AVCapturePhotoOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS)
// TODO: How to do a delegate proxy for capturePhoto(with:delegate:) ?
@available(iOS 10.0, macOS 10.15, *)
extension Reactive where Base: AVCapturePhotoOutput {

	/// Tells the photo capture output to prepare resources for future capture requests with the specified settings.
	/// - Parameter preparedPhotoSettingsArray: An array of photo capture settings objects indicating the types of capture for which the photo output should prepare resources.
	public func setPreparedPhotoSettingsArray(_ preparedPhotoSettingsArray: [AVCapturePhotoSettings]) -> Single<Bool> {
		return Single.create { event -> Disposable in
			self.base.setPreparedPhotoSettingsArray(preparedPhotoSettingsArray) { (finished, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success(finished))
				}
			}
			return Disposables.create()
		}
	}
}
#endif
