//
//  AVPlayerItem+Rx.swift
//  HRnew
//
//  Created by Pawel Rup on 27.03.2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVPlayerItem {

	// MARK: - Observed properties

	public var status: Observable<AVPlayerItem.Status> {
		return observe(AVPlayerItem.Status.self, #keyPath(AVPlayerItem.status))
			.map { $0 ?? .unknown }
	}

	public var error: Observable<NSError?> {
		return observe(NSError.self, #keyPath(AVPlayerItem.error))
	}

	public var duration: Observable<CMTime> {
		return observe(CMTime.self, #keyPath(AVPlayerItem.duration))
			.map { $0 ?? .zero }
	}

	/// A Boolean value that indicates whether the item will likely play through without stalling.
	public var playbackLikelyToKeepUp: Observable<Bool> {
		return observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
			.map { $0 ?? false }
	}

	public var playbackBufferFull: Observable<Bool> {
		return observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackBufferFull))
			.map { $0 ?? false }
	}

	/// A Boolean value that indicates whether playback has consumed all buffered media and that playback will stall or end.
	public var playbackBufferEmpty: Observable<Bool> {
		return observe(Bool.self, #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
			.map { $0 ?? false }
	}

	/// An array of time ranges indicating media data that is readily available.
	public var loadedTimeRanges: Observable<[CMTimeRange]> {
		return observe([NSValue].self, #keyPath(AVPlayerItem.loadedTimeRanges))
			.map { $0 ?? [] }
			.map { values in values.map { $0.timeRangeValue } }
	}

	/// An array of the most recently encountered timed metadata.
	public var timedMetadata: Observable<[AVMetadataItem]> {
		return observe([AVMetadataItem].self, #keyPath(AVPlayerItem.timedMetadata))
			.map { $0 ?? [] }
	}

	// MARK: - Notifications

	/// A notification that's posted when the item has played to its end time.
	public var didPlayToEnd: Observable<Notification> {
		let notificationCenter = NotificationCenter.default
		return notificationCenter.rx.notification(.AVPlayerItemDidPlayToEndTime, object: base)
	}

	// MARK: - Functions

	/// Sets the current playback time to the specified time and executes the specified block when the seek operation completes or is interrupted.
	/// - Parameter time: The time to which to seek.
	public func seek(to time: CMTime) -> Single<Bool> {
		return Single.create { event -> Disposable in
			self.base.seek(to: time) { finished in
				event(.success(finished))
			}
			return Disposables.create()
		}
	}

	/// Sets the current playback time within a specified time bound and invokes the specified block when the seek operation completes or is interrupted.
	/// - Parameter time: The time to which to seek.
	/// - Parameter toleranceBefore: The temporal tolerance before time.
	///		Pass zero to request sample accurate seeking (this may incur additional decoding delay).
	/// - Parameter toleranceAfter: The temporal tolerance after time.
	///		Pass zero to request sample accurate seeking (this may incur additional decoding delay).
	public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) -> Single<Bool> {
		return Single.create { event -> Disposable in
			self.base.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { finished in
				event(.success(finished))
			}
			return Disposables.create()
		}
	}

	/// Sets the current playback time to the time specified by the date object.
	/// - Parameter date: The time to which to seek.
	public func seek(to date: Date) -> Single<Bool> {
		return Single.create { event -> Disposable in
			self.base.seek(to: date) { finished in
				event(.success(finished))
			}
			return Disposables.create()
		}
	}
}
