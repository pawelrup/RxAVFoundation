//
//  AVPlayerItemMetadataCollector+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

@available(iOS 9.3, tvOS 9.3, macOS 10.11.3, *)
extension AVPlayerItemMetadataCollector: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVPlayerItemMetadataCollectorPushDelegate
}

@available(iOS 9.3, tvOS 9.3, macOS 10.11.3, *)
private class RxAVPlayerItemMetadataCollectorDelegateProxy: DelegateProxy<AVPlayerItemMetadataCollector, AVPlayerItemMetadataCollectorPushDelegate>, DelegateProxyType, AVPlayerItemMetadataCollectorPushDelegate {

	private var didCollectMetadataGroupsSubject = PublishSubject<([AVDateRangeMetadataGroup], IndexSet, IndexSet)>()

	var didCollectMetadataGroups: Observable<([AVDateRangeMetadataGroup], IndexSet, IndexSet)>

	public weak private (set) var view: AVPlayerItemMetadataCollector?

	public init(view: ParentObject) {
		self.view = view
		didCollectMetadataGroups = didCollectMetadataGroupsSubject.asObservable()
		super.init(parentObject: view, delegateProxy: RxAVPlayerItemMetadataCollectorDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVPlayerItemMetadataCollectorDelegateProxy(view: $0) }
	}

	func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
		didCollectMetadataGroupsSubject.onNext((metadataGroups, indexesOfNewGroups, indexesOfModifiedGroups))
	}
}

@available(iOS 9.3, tvOS 9.3, macOS 10.11.3, *)
extension Reactive where Base: AVPlayerItemMetadataCollector {

	public var delegate: DelegateProxy<AVPlayerItemMetadataCollector, AVPlayerItemMetadataCollectorPushDelegate> {
		RxAVPlayerItemMetadataCollectorDelegateProxy.proxy(for: base)
	}

	/// Tells that the collected metadata group information has changed and needs to be updated.
	public var didCollectMetadataGroups: Observable<([AVDateRangeMetadataGroup], IndexSet, IndexSet)> {
		(delegate as! RxAVPlayerItemMetadataCollectorDelegateProxy).didCollectMetadataGroups
	}
}
