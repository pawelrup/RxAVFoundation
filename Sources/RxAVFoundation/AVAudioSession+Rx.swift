//
//  AVAudioSession+Rx.swift
//  HRnew
//
//  Created by Pawel Rup on 27.03.2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(watchOS) || os(tvOS)
public typealias AVAudioSessionRouteChangeInfo = (reason: AVAudioSession.RouteChangeReason, previousRouteDescription: AVAudioSessionRouteDescription?)

extension Reactive where Base: AVAudioSession {

	// MARK: - Notifications

	public var routeChange: Observable<AVAudioSessionRouteChangeInfo> {
		return NotificationCenter.default.rx.notification(AVAudioSession.routeChangeNotification, object: base)
			.map { $0.userInfo }
			.map {
				let reasonRaw = $0?[AVAudioSessionRouteChangeReasonKey] as? UInt
				let previousRoute = $0?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
				return (reasonRaw, previousRoute)
			}
			.map { (reasonRaw: UInt?, previousRoute: AVAudioSessionRouteDescription?) -> AVAudioSessionRouteChangeInfo in
				let reason: AVAudioSession.RouteChangeReason
				if let raw = reasonRaw {
					reason = AVAudioSession.RouteChangeReason(rawValue: raw) ?? .unknown
				} else {
					reason = .unknown
				}
				return (reason: reason, previousRouteDescription: previousRoute)
		}
	}

	// MARK: - Functions

	#if os(iOS) || os(watchOS)
	/// Requests the user’s permission for audio recording.
	public func requestRecordPermission() -> Single<Bool> {
		return Single.create { event -> Disposable in
			self.base.requestRecordPermission { (granted) in
				event(.success(granted))
			}
			return Disposables.create()
		}
	}
	#endif
}
#endif
