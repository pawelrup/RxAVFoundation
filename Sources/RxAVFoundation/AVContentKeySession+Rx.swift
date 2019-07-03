//
//  AVContentKeySession+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(tvOS) || os(macOS)
@available(iOS 10.3, tvOS 10.2, macOS 10.12.4, *)
extension AVContentKeySession: HasDelegate {

	public var delegate: Delegate? {
		get {
			return value(forKey: "delegate") as? Delegate
		}
		set(newValue) {
			setDelegate(newValue, queue: .main)
		}
	}

	public typealias Delegate = AVContentKeySessionDelegate
}

@available(iOS 10.3, tvOS 10.3, macOS 10.15, *)
private class RxAVContentKeySessionDelegateProxy: DelegateProxy<AVContentKeySession, AVContentKeySessionDelegate>, DelegateProxyType, AVContentKeySessionDelegate {

	private var didProvideKeyRequestSubject = PublishSubject<AVContentKeyRequest>()
	private var didProvidePersistableKeyRequestSubject = PublishSubject<AVPersistableContentKeyRequest>()

	var didProvideKeyRequest: Observable<AVContentKeyRequest>
	var didProvidePersistableKeyRequest: Observable<AVPersistableContentKeyRequest>

	public weak private (set) var view: AVContentKeySession?

	public init(view: ParentObject) {
		self.view = view
		didProvideKeyRequest = didProvideKeyRequestSubject.asObservable()
		didProvidePersistableKeyRequest = didProvidePersistableKeyRequestSubject.asObservable()
		super.init(parentObject: view, delegateProxy: RxAVContentKeySessionDelegateProxy.self)
	}

	static func registerKnownImplementations() {
		register { RxAVContentKeySessionDelegateProxy(view: $0) }
	}

	func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
		didProvideKeyRequestSubject.onNext(keyRequest)
	}

	func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVPersistableContentKeyRequest) {
		didProvidePersistableKeyRequestSubject.onNext(keyRequest)
	}
}

@available(iOS 10.3, tvOS 10.3, macOS 10.15, *)
extension Reactive where Base: AVContentKeySession {

	public var delegate: DelegateProxy<AVContentKeySession, AVContentKeySessionDelegate> {
		return RxAVContentKeySessionDelegateProxy.proxy(for: base)
	}

	// MARK: - Functions

	#if os(iOS) || os(watchOS) || os(macOS)
	/// Creates a secure server playback context that the client sends to the key server to get an expiration date for the given persistable content key data.
	/// - Parameter persistableContentKeyData: The previously created persistable content key data.
	@available(iOS 11.0, macOS 10.15, *)
	public func makeSecureTokenForExpirationDate(ofPersistableContentKey persistableContentKeyData: Data) -> Single<Data> {
		return Single.create { event -> Disposable in
			self.base.makeSecureTokenForExpirationDate(ofPersistableContentKey: persistableContentKeyData) { (token, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success(token!))
				}
			}
			return Disposables.create()
		}
	}

	/// nvalidates the persistable content key and creates a secure server playback context (SPC) that the client could send to the key server to verify the outcome of invalidation request.
	/// - Parameter persistableContentKeyData: Persistable content key data that was previously created using -[AVContentKeyRequest persistableContentKeyFromKeyVendorResponse:options:error:] or obtained via AVContentKeySessionDelegate callback -contentKeySession:didUpdatePersistableContentKey:forContentKeyIdentifier:.
	/// - Parameter options: Additional information necessary to generate the server playback context, or nil if none. See AVContentKeySessionServerPlaybackContextOption for supported options.
	@available(iOS 12.2, macOS 10.15, *)
	public func invalidatePersistableContentKey(_ persistableContentKeyData: Data, options: [AVContentKeySessionServerPlaybackContextOption : Any]? = nil) -> Single<Data> {
		return Single.create { event -> Disposable in
			self.base.invalidatePersistableContentKey(persistableContentKeyData, options: options) { (token, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success(token!))
				}
			}
			return Disposables.create()
		}
	}

	/// Invalidates all persistable content keys associated with the application and creates a secure server playback context (SPC) that the client could send to the key server to verify the outcome of invalidation request.
	/// - Parameter appIdentifier: An opaque identifier for the application. The contents of this identifier depend on the particular protocol in use by the entity that controls the use of the media data.
	/// - Parameter options: Additional information necessary to generate the server playback context, or nil if none. See AVContentKeySessionServerPlaybackContextOption for supported options.
	@available(iOS 12.2, macOS 10.15, *)
	public func invalidateAllPersistableContentKeys(forApp appIdentifier: Data, options: [AVContentKeySessionServerPlaybackContextOption : Any]? = nil) -> Single<Data> {
		return Single.create { event -> Disposable in
			self.base.invalidateAllPersistableContentKeys(forApp: appIdentifier, options: options) { (token, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success(token!))
				}
			}
			return Disposables.create()
		}
	}
	#endif

	// MARK: - Delegates

	/// Provides the receiver with a new content key request object.
	public var didProvideKeyRequest: Observable<AVContentKeyRequest> {
		return (delegate as! RxAVContentKeySessionDelegateProxy).didProvideKeyRequest
	}

	/// Provides the receiver with a new content key request object for the renewal of an existing content key.
	public var didProvideRenewingContentKeyRequest: Observable<AVContentKeyRequest> {
		return delegate.methodInvoked(#selector(AVContentKeySessionDelegate.contentKeySession(_:didProvideRenewingContentKeyRequest:)))
			.map { $0[1] as! AVContentKeyRequest }
	}

	/// Provides the receiver with a new content key request object to process a persistable content key.
	@available(macOS 10.15, *)
	public var didProvidePersistableKeyRequest: Observable<AVPersistableContentKeyRequest> {
		return (delegate as! RxAVContentKeySessionDelegateProxy).didProvidePersistableKeyRequest
	}

	#if os(iOS) || os(watchOS) || os(macOS)
	/// Provides the receiver with an updated persistable content key for a specific key request.
	@available(iOS 11.0, *)
	public var didUpdatePersistableContentKeyForContentKeyIdentifier: Observable<(Data, Any)> {
		return delegate.methodInvoked(#selector(AVContentKeySessionDelegate.contentKeySession(_:didUpdatePersistableContentKey:forContentKeyIdentifier:)))
			.map { ($0[1] as! Data, $0[2]) }
	}
	#endif

	/// Tells the receiver that the content key request failed.
	public var contentKeyRequestDidFailWithError: Observable<(AVContentKeyRequest, Error)> {
		return delegate.methodInvoked(#selector(AVContentKeySessionDelegate.contentKeySession(_:contentKeyRequest:didFailWithError:)))
			.map { ($0[1] as! AVContentKeyRequest, $0[2] as! Error) }
	}

	#if os(iOS) || os(watchOS) || os(macOS)
	/// Tells the content key session that the response to a content key requeset was successfully processed.
	@available(iOS 12.0, *)
	public var contentKeyRequestDidSucceed: Observable<AVContentKeyRequest> {
		return delegate.methodInvoked(#selector(AVContentKeySessionDelegate.contentKeySession(_:contentKeyRequestDidSucceed:)))
			.map { $0[1] as! AVContentKeyRequest }
	}
	#endif

	/// Tells the receiver the content protection session identifier changed.
	public var contentKeySessionContentProtectionSessionIdentifierDidChange: Observable<Void> {
		return delegate.methodInvoked(#selector(AVContentKeySessionDelegate.contentKeySessionContentProtectionSessionIdentifierDidChange(_:)))
			.map { _ in () }
	}

	#if os(iOS) || os(watchOS) || os(macOS)
	/// Notifies the sender that an expired session report has been generated.
	@available(iOS 12.0, *)
	public var contentKeySessionDidGenerateExpiredSessionReport: Observable<Void> {
		return delegate.methodInvoked(#selector(AVContentKeySessionDelegate.contentKeySessionDidGenerateExpiredSessionReport(_:)))
			.map { _ in () }
	}
	#endif
}

@available(iOS 10.3, tvOS 10.3, macOS 10.12.4, *)
extension Reactive where Base: AVContentKeyRequest {

	/// Obtains encrypted key request data for a specific combination of app and content.
	/// - Parameter appIdentifier: An opaque identifier for the app.
	/// - Parameter contentIdentifier: An opaque identifier for the content.
	/// - Parameter options: A dictionary containing any additional information required to obtain the key. The value of this parameter is nil when no additional information is required.
	public func makeStreamingContentKeyRequestData(forApp appIdentifier: Data, contentIdentifier: Data?, options: [String : Any]? = nil) -> Single<Data> {
		return Single.create { event -> Disposable in
			self.base.makeStreamingContentKeyRequestData(forApp: appIdentifier, contentIdentifier: contentIdentifier, options: options) { (token, error) in
				if let error = error {
					event(.error(error))
				} else {
					event(.success(token!))
				}
			}
			return Disposables.create()
		}
	}
}
#endif
