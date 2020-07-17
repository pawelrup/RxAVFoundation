//
//  AVPlayerLayer+Rx.swift
//  HRnew
//
//  Created by Pawel Rup on 27.03.2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(macOS) || os(tvOS)
extension Reactive where Base: AVPlayerLayer {

	/// A Boolean value that indicates whether the first video frame has been made ready for display for the current item of the associated player.
	public var readyForDisplay: Observable<Bool> {
		observe(Bool.self, #keyPath(AVPlayerLayer.readyForDisplay))
			.map { $0 ?? false }
	}
}
#endif
