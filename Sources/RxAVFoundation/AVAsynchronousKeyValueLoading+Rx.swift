//
//  AVAsynchronousKeyValueLoading+Rx.swift
//  
//
//  Created by Pawel Rup on 14/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

extension Reactive where Base: AVAsynchronousKeyValueLoading {

	/// Tells the asset to load the values of all of the specified keys (property names) that are not already loaded.
	/// - Parameter keys: An array of strings containing the required keys. The keys are the property names of a class that adopts the protocol.
	public func loadValuesAsynchronously(forKeys keys: [String]) -> Single<Void> {
		Single.create { event in
			base.loadValuesAsynchronously(forKeys: keys) {
				event(.success(()))
			}
			return Disposables.create()
		}
	}
}
