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
            Text("🎉 Congratulations! 🎉")
                .font(.largeTitle)
                .padding()
            Text("You completed: \(todoTitle)")
                .font(.title2)
                .padding(.bottom)
            Text("Keep up the great work!")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

enum CelebrationViewImage {
    static func renderAsImage(view: CelebrationView) -> UIImage {
        let controller = UIHostingController(rootView: view)
        let view = controller.view

        let targetSize = CGSize(width: 300, height: 200)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}

struct ShareCelebrationView: View {
    var todoTitle: String
    @State private var isShareSheetPresented = false

    var body: some View {
        VStack {
//            CelebrationView(todoTitle: todoTitle)
            Button(action: shareCelebrationImage) {
                Text("Share on X")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }

    func shareCelebrationImage() {
        let image = CelebrationViewImage.renderAsImage(view: CelebrationView(todoTitle: todoTitle))
        let activityVC = UIActivityViewController(activityItems: [image, "I just completed \(todoTitle)! 🎉"], applicationActivities: nil)

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
