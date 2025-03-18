import AVFoundation
import Foundation
import os
import SwiftUI

struct ScannerView : Configurable, UIViewControllerRepresentable {
    
    var config  : confdt
    var callback: ((String) -> Void)?
    var error   : Binding<String>?
    
    init ( 
        _ incomingConfig: confdt = [:], 
          error         : Binding<String>?, 
        _ callback      : ((String) -> Void)? = nil 
    ) {
        self.error    = error
        self.callback = callback
        
        self.config = mergeDictionaries(defaultConfig, incomingConfig)
    }
    
    func makeUIViewController ( context: Context ) -> ScannerViewController {
        let controller      = ScannerViewController(config, error: error)
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func makeCoordinator () -> Coordinator {
        Coordinator(config, error, callback)
    }
    
    func updateUIViewController ( _ uiViewController: ScannerViewController, context: Context ) {}
    
    let defaultConfig : confdt = [
        .debounce        : .wrap(0.25),
        .captureMode     : .wrap(CaptureMode.continuous),
        .recognizedTypes : .wrap([AVMetadataObject.ObjectType.qr]),
        .cameraPriority  : .wrap([AVCaptureDevice.DeviceType.builtInWideAngleCamera, AVCaptureDevice.DeviceType.external, AVCaptureDevice.DeviceType.continuityCamera])
    ]
}

extension ScannerView {
    
    class Coordinator : NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var config  : confdt
        var callback: ((String) -> Void)?
        var error   : Binding<String>?
        
        var lastExecution : Date = .distantPast
        var hasBeenExecuted : Bool = false
        
        init ( 
            _ config  : confdt,
            _ error   : Binding<String>?,
            _ callback: ((String) -> Void)? 
        ) {
            self.config   = config
            self.error    = error
            self.callback = callback
        }
        
        func metadataOutput (
            _         output         : AVCaptureMetadataOutput, 
            didOutput metadataObjects: [AVMetadataObject], 
            from      connection     : AVCaptureConnection
        ) {
            guard 
                Date.now >= lastExecution.addingTimeInterval(config[.debounce]!.take(as: TimeInterval.self)!),
                metadataObjects.count > 0 
            else { return }
            
            self.lastExecution = .now
            
            if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if let recognizedTypes = config[.recognizedTypes]?.take(as: [AVMetadataObject.ObjectType.self]) {
                    if recognizedTypes.contains(metadataObj.type), let result = metadataObj.stringValue {
                        if .singleScan == config[.captureMode]?.take(as: CaptureMode.self) && hasBeenExecuted
                        { return }
                        
                        self.hasBeenExecuted = true
                        callback?(result)
                        
                    } else {
                        error?.wrappedValue = "Unrecognized type: \(metadataObj.type)"
                        return
                    }
                    
                } else {
                    error?.wrappedValue = "Unable to understand the config's recognizedTypes: \(String(describing: config[.recognizedTypes]))"
                    return
                }
                
            } else {
                error?.wrappedValue = "Unable to convert metadataObjects[0] to AVMetadataMachineReadableCodeObject"
                return
            }
        }
    }
    
}

extension ScannerView {
    
    enum CaptureMode {
        case singleScan
        case continuous
    }
    
}

extension ScannerView {
    
    enum Config {
        case captureMode
        case debounce
        case cameraPriority
        case recognizedTypes
    }
    
    typealias confdt = [Config: TypeWrapper<Any>]
    
}
