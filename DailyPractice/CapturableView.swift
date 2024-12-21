//
//  ShareCelebrationView.swift
//  DailyPractice
//
//  Created by 山田　天星 on 2024/11/10.
//

import SwiftUI
import UIKit

struct PrizeView: View {
    var body: some View {
        VStack {
            Text("🎉")
                .font(.largeTitle)
                .padding()
            Text("Your Task Title")
                .font(.title2)
                .padding(.bottom)
            Text("Keep up the great work!")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(width: 300, height: 200)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

struct CapturableView<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
    }

    func capture() -> UIImage? {
        let rootView = self
            .padding([.top, .bottom, .leading, .trailing])
            .ignoresSafeArea()
        let controller = UIHostingController(rootView: rootView)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .red

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    func captureAsync(size: CGSize, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = self.capture()
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}


struct CaptureContentView: View {
    @State private var capturedImage: UIImage?
    @State private var shouldShowCaptureImage: Bool = false
    @State private var shouldShowCompletionDialog: Bool = false
    
    var body: some View {
        let capturableView = CapturableView { prizeView }
        
        return ZStack {
            VStack(spacing: 16) {
                Text("SwiftUI View to Capture")
                    .font(.largeTitle)
                    .padding()
                
                // キャプチャ対象部分
                capturableView
                
                Button {
                    capturedImage = capturableView.capture()
                    shouldShowCaptureImage = true
                } label: {
                    Text("キャプチャ")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.vertical)
            }
            .frame(maxHeight: .infinity)
            
            if let capturedImage, shouldShowCaptureImage {
                focusedCaputureView(capturedImage)
            }
        }
    }
    
    private var prizeView: some View {
        PrizeView()
    }
    
    private func focusedCaputureView(_ image: UIImage) -> some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    shouldShowCaptureImage = false
                }

            VStack(spacing: 32) {
                Image(uiImage: image)
                
                VStack(spacing: 24) {
                    Button {
                        ImageSaver($shouldShowCompletionDialog).writeToPhotoAlbum(image: image)
                    } label: {
                        Text("カメラロールに保存する")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $shouldShowCompletionDialog) {
                        Alert(
                            title: Text("画像を保存しました。"),
                            message: Text(""),
                            dismissButton: .default(Text("OK"), action: {
                                shouldShowCompletionDialog = false
                            }))
                    }
                    
                    Button {
                        SNSSharedHelper
                            .shareCelebrationImage(
                                .init(image: image, title: "", message: "")
                            )
                    } label: {
                        Text("SNSにもシェアする")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 36)
            }
        }
    }
}

final class ImageSaver: NSObject {
    @Binding var showAlert: Bool
    
    init(_ showAlert: Binding<Bool>) {
        _showAlert = showAlert
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage), nil)
    }

    @objc func didFinishSavingImage(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        
        if error != nil {
            print("保存に失敗しました。")
        } else {
            showAlert = true
        }
    }
}

struct SNSSharedHelper {
    struct Input {
        let image: UIImage
        let title: String
        let message: String
        
        var sharedText: String {
            title + message
        }
    }
    
    static func shareCelebrationImage(_ input: Input) {
        let activityVC = UIActivityViewController(
            activityItems: [input.image, input.sharedText],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController
        {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

#Preview("CaptureContentView") {
    CaptureContentView()
}



