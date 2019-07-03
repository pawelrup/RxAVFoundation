//
//  AVSampleBufferRenderSynchronizer+Rx.swift
//  
//
//  Created by Pawel Rup on 17/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

@available(iOS 11.0, tvOS 11.0, macOS 10.13, *)
extension Reactive where Base: AVSampleBufferRenderSynchronizer {

	/// Removes a renderer from the synchronizer.
	/// - Parameter renderer: Renderer
	/// - Parameter time: The time on the timebase's timeline at which the renderer should be removed. If the time is in the past, the renderer is immediately removed.
	public func removeRenderer(_ renderer: AVQueuedSampleBufferRendering, at time: CMTime) -> Single<Bool> {
		return Single.create { event -> Disposable in
			self.base.removeRenderer(renderer, at: time) { (didRemoveRenderer) in
				event(.success(didRemoveRenderer))
			}
			return Disposables.create()
		}
	}

	/// Requests invocation of a block during rendering at specified time intervals.
	/// - Parameter interval: The specified time interval requesting block invocation during rendering.
	/// - Parameter queue: The serial queue the block should be unqueued on. If you pass NULL, the main queue is used. Passing a concurrent queue results in undefined behavior.
	public func periodicTimeObserver(interval: CMTime, queue: DispatchQueue? = nil) -> Observable<CMTime> {
		return Observable.create { observer in
			let timeObserver = self.base.addPeriodicTimeObserver(forInterval: interval, queue: queue) { time in
				observer.onNext(time)
			}

			return Disposables.create { self.base.removeTimeObserver(timeObserver)
			}
		}
	}

	/// Requests invocation of a block when specified times are traversed during normal rendering.
	/// - Parameter times: An array containing the times for which the observer requests notification.
	/// - Parameter queue: The serial queue the block should be unqueued on. If you pass NULL, the main queue is used. Passing a concurrent queue results in undefined behavior.
	public func addBoundaryTimeObserver(forTimes times: [NSValue], queue: DispatchQueue? = nil) -> Observable<Void> {
		return Observable.create { observer in
			let timeObserver = self.base.addBoundaryTimeObserver(forTimes: times, queue: queue) {
				observer.onNext(())
			}

			return Disposables.create { self.base.removeTimeObserver(timeObserver)
			}
		}
	}
}
