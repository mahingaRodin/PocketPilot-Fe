//
//  CameraManager.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI
import AVFoundation

class CameraManager: ObservableObject {
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var capturedImage: UIImage?
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
    
    func checkPermission() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    var hasPermission: Bool {
        permissionStatus == .authorized
    }
}
