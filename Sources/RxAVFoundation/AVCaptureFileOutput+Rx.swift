//
//  AVCaptureFileOutput+Rx.swift
//  
//
//  Created by Pawel Rup on 15/06/2019.
//

import AVFoundation
import RxSwift
import RxCocoa

#if os(iOS) || os(macOS)
// TODO: How to do a delegate proxy for startRecording(to:recordingDelegate:) ?
extension Reactive where Base: AVCaptureFileOutput {
}
#endif
