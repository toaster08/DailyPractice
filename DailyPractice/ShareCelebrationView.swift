//
//  ShareCelebrationView.swift
//  DailyPractice
//
//  Created by 山田　天星 on 2024/11/10.
//

import SwiftUI
import UIKit

struct CelebrationView: View {
    var todoTitle: String

    var body: some View {
        VStack {
            Text("🎉")
                .font(.largeTitle)
                .padding()
            Text("\(todoTitle)")
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

enum CelebrationViewImage {
    static func renderAsImage(view: CelebrationView) -> UIImage {
        let controller = UIHostingController(rootView: view)
        let view = controller.view

        // CelebrationViewのコンテンツサイズを計算
        let contentSize = controller.sizeThatFits(in: UIScreen.main.bounds.size)

        // 余白を含めた画像のサイズを設定（上下左右に8ptの余白を追加）
        let padding: CGFloat = 16
        let targetSize = CGSize(width: contentSize.width + padding * 6, height: contentSize.height + padding * 6)
        /// shadowの分だけwidthとheightを指定する必要がある
        let renderSize = CGSize(width: contentSize.width, height: contentSize.height)

        // viewのboundsと背景色を設定
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        // UIGraphicsImageRendererを使用して画像を生成
        let renderer = UIGraphicsImageRenderer(size: renderSize)
        return renderer.image { _ in
            // 余白分オフセットして描画
            view?.drawHierarchy(
                in: CGRect(
                    x: 0,
                    y: -padding,
                    width: contentSize.width,
                    height: contentSize.height
                ),
                afterScreenUpdates: true
            )
        }
    }
}

struct ShareCelebrationView: View {
    var todoTitle: String
    @State private var isShareSheetPresented = false

    var body: some View {
        VStack(spacing: 16) {
            CelebrationView(todoTitle: todoTitle)
            Button(action: shareCelebrationImage) {
                Text("Share")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }

    func shareCelebrationImage() {
        let image = CelebrationViewImage.renderAsImage(view: CelebrationView(todoTitle: todoTitle))
        let activityVC = UIActivityViewController(
            activityItems: [image, "I just completed \(todoTitle)! 🎉"],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController
        {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

#Preview {
    ShareCelebrationView(todoTitle: "Your Task Title")
}
