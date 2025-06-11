import SwiftUI

@main
struct HeadTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("AirPods Pro 应用")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Image(systemName: "airpodspro")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 20) {
                    NavigationLink(destination: ContentView()) {
                        MenuButton(title: "📊 头部追踪演示", subtitle: "查看头部方向数据")
                    }
                }
                
                Spacer()
                
                Text("请确保您的 AirPods Pro 已连接")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)
            }
            .padding()
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
