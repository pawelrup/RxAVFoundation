//
//  AVPlayer+Rx.swift
//  HRnew
//
//  Created by Pawel Rup on 27.03.2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVPlayer {

	// MARK: - Observed properties

	public var rate: Observable<Float> {
		observe(Float.self, #keyPath(AVPlayer.rate))
			.map { $0 ?? 0 }
	}

	public var currentItem: Observable<AVPlayerItem?> {
		observe(AVPlayerItem.self, #keyPath(AVPlayer.currentItem))
	}

	public var status: Observable<AVPlayer.Status> {
		observe(AVPlayer.Status.self, #keyPath(AVPlayer.status))
			.map { $0 ?? .unknown }
	}

	public var error: Observable<NSError?> {
		observe(NSError.self, #keyPath(AVPlayer.error))
	}

	@available(iOS 10.0, tvOS 10.0, *)
	public var reasonForWaitingToPlay: Observable<AVPlayer.WaitingReason?> {
		observe(AVPlayer.WaitingReason.self, #keyPath(AVPlayer.reasonForWaitingToPlay))
	}

	@available(iOS 10.0, tvOS 10.0, macOS 10.12, *)
	public var timeControlStatus: Observable<AVPlayer.TimeControlStatus> {
		observe(AVPlayer.TimeControlStatus.self, #keyPath(AVPlayer.timeControlStatus))
			.map { $0 ?? .waitingToPlayAtSpecifiedRate }
	}

	// MARK: - Functions

	/// Sets the current playback time to the specified time and executes the specified block when the seek operation completes or is interrupted.
	/// - Parameter date: The time to which to seek.
	public func seek(to date: Date) -> Single<Bool> {
		Single.create { event in
			base.seek(to: date) { finished in
				event(.success(finished))
			}
			return Disposables.create()
		}
	}

	/// Sets the current playback time to the specified time and executes the specified block when the seek operation completes or is interrupted.
	/// - Parameter time: The time to which to seek.
	public func seek(to time: CMTime) -> Single<Bool> {
		Single.create { event in
			base.seek(to: time) { finished in
				event(.success(finished))
			}
			return Disposables.create()
		}
	}

	/// Sets the current playback time to the specified time and executes the specified block when the seek operation completes or is interrupted.
	/// - Parameter time: The time to which to seek.
	/// - Parameter toleranceBefore: The temporal tolerance before time.
	///		Pass zero to request sample accurate seeking (this may incur additional decoding delay).
	/// - Parameter toleranceAfter: The temporal tolerance after time.
	///		Pass zero to request sample accurate seeking (this may incur additional decoding delay).
	public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) -> Single<Bool> {
		Single.create { event in
			base.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { finished in
				event(.success(finished))
			}
			return Disposables.create()
		}
	}

	/// Begins loading media data to prime the media pipelines for playback.
	/// - Parameter rate: The playback rate to use when determining how much data to load.
	public func preroll(atRate rate: Float) -> Single<Bool> {
		Single.create { event in
			base.preroll(atRate: rate) { finished in
				event(.success(finished))
			}
			return Disposables.create()
		}
	}

	/// Requests the periodic invocation of a given block during playback to report changing time.
	/// - Parameter interval: The time interval at which the block should be invoked during normal playback, according to progress of the player’s current time.
	/// - Parameter queue: A serial dispatch queue onto which block should be enqueued. Passing a concurrent queue is not supported and will result in undefined behavior.
	public func periodicTimeObserver(interval: CMTime, queue: DispatchQueue? = nil) -> Observable<CMTime> {
		Observable.create { observer in
			let timeObserver = base.addPeriodicTimeObserver(forInterval: interval, queue: queue) { time in
				observer.onNext(time)
			}

			return Disposables.create { base.removeTimeObserver(timeObserver) }
		}
	}

	/// Requests the invocation of a block when specified times are traversed during normal playback.
	/// - Parameter times: An array of NSValue objects containing CMTime values representing the times at which to invoke block.
	/// - Parameter queue: A serial queue onto which block should be enqueued. Passing a concurrent queue is not supported and will result in undefined behavior.
	public func boundaryTimeObserver(times: [CMTime], queue: DispatchQueue? = nil) -> Observable<Void> {
		Observable.create { observer in
			let timeValues = times.map { NSValue(time: $0) }
			let timeObserver = base.addBoundaryTimeObserver(forTimes: timeValues, queue: queue) {
				observer.onNext(())
			}

			return Disposables.create { base.removeTimeObserver(timeObserver) }
		}
	}
}
