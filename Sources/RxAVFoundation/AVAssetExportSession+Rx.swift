//
//  AVAssetExportSession+Rx.swift
//  
//
//  Created by Pawel Rup on 14/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(macOS)
extension Reactive where Base: AVAssetExportSession {

	/// Starts the asynchronous execution of an export session.
	func exportAsynchronously() -> Single<Void> {
		return Single.create { event -> Disposable in
			self.base.exportAsynchronously {
				event(.success(()))
			}
			return Disposables.create()
		}
	}


	/// Reports the compatibility of an export present, asset, and output file type to the specified block.
	/// - Parameter presetName: The name of the preset template for the export operation.
	/// - Parameter asset: The asset object that you are planning to export.
	/// - Parameter outputFileType: The UTI string corresponding to the file type. For example, to specify a QuickTime movie file format, you could specify the constant mov. For a list of constants specifying UTIs for standard file types, see AVFoundation Constants.
	static func determineCompatibility(ofExportPreset presetName: String, with asset: AVAsset, outputFileType: AVFileType?) -> Single<Bool> {
		return Single.create { event -> Disposable in
			AVAssetExportSession.determineCompatibility(ofExportPreset: presetName, with: asset, outputFileType: outputFileType) { (isCompatible) in
				event(.success(isCompatible))
			}
			return Disposables.create()
		}
	}

	/// Reports the compatible file types for the current export session to the specified block.
	func determineCompatibleFileTypes() -> Single<[AVFileType]> {
		return Single.create { event -> Disposable in
			self.base.determineCompatibleFileTypes { (fileTypes) in
				event(.success(fileTypes))
			}
			return Disposables.create()
		}
	}

	/// Starts the asynchronous execution of estimating the maximum duration of the export based on the asset, preset, and fileLengthLimit associated with the export session.
	@available(iOS 13.0, macOS 10.15, *)
	func estimateMaximumDuration() -> Single<CMTime> {
		return Single.create { event -> Disposable in
			self.base.estimateMaximumDuration { (time, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success(time))
				}
			}
			return Disposables.create()
		}
	}

	/// Starts the asynchronous execution of estimating the output file length of the export based on the asset, preset, and timeRange associated with the export session.
	@available(iOS 13.0, macOS 10.15, *)
	func estimateOutputFileLength() -> Single<Int64> {
		return Single.create { event -> Disposable in
			self.base.estimateOutputFileLength { (length, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success(length))
				}
			}
			return Disposables.create()
		}
	}
}
#endif
