//
//  GameView.swift
//  HeadTrackerApp
//
//  Created by Shank on 12/6/25.
//

import SwiftUI
import CoreMotion
import Combine

// Game View - 管理游戏的入口和生命周期
struct GameView: View {
    @StateObject private var headphoneMotionManager = HeadphoneMotionManager()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GameViewBody(headphoneMotionManager: headphoneMotionManager, onBack: {
            presentationMode.wrappedValue.dismiss()
        })
        .navigationBarHidden(true)
        .onAppear {
            headphoneMotionManager.start()
        }
        .onDisappear {
            headphoneMotionManager.stop()
        }
    }
}

// Game View
struct GameViewBody: View {
    @ObservedObject var headphoneMotionManager: HeadphoneMotionManager
    let onBack: () -> Void
    @StateObject private var gameManager = GameManager()
    @State private var gameTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if headphoneMotionManager.isDeviceConnected {
                GameContent(gameManager: gameManager, headphoneMotionManager: headphoneMotionManager, onBack: onBack)
            } else {
                ConnectionWaitingView(headphoneMotionManager: headphoneMotionManager, onBack: onBack)
            }
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            stopGame()
        }
    }
    
    private func startGame() {
        gameManager.startGame()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            gameManager.updateGame(
                pitch: headphoneMotionManager.pitch,
                roll: headphoneMotionManager.roll,
                yaw: headphoneMotionManager.yaw
            )
        }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
}

struct GameContent: View {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var headphoneMotionManager: HeadphoneMotionManager
    let onBack: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Game area circle
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: gameManager.gameRadius * 2, height: gameManager.gameRadius * 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Player (red heart) in center
                Text("❤️")
                    .font(.system(size: 40))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Weapon (sword) controlled by head movements
                ZStack {
                    // Weapon collision area (for debugging)
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 70, height: 70) // Shows the collision detection area
                    
                    Text("🗡️")
                        .font(.system(size: 30))
                        .rotationEffect(.degrees(gameManager.weaponAngle + 90))
                }
                .position(
                    x: geometry.size.width / 2 + cos(gameManager.weaponAngle * .pi / 180) * gameManager.weaponDistance,
                    y: geometry.size.height / 2 + sin(gameManager.weaponAngle * .pi / 180) * gameManager.weaponDistance
                )
                
                // Enemies (red dots)
                ForEach(gameManager.enemies) { enemy in
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                        
                        // Pulsing effect for enemies
                        Circle()
                            .stroke(Color.red.opacity(0.5), lineWidth: 2)
                            .frame(width: 30, height: 30)
                            .scaleEffect(enemy.pulseScale)
                    }
                    .position(
                        x: geometry.size.width / 2 + enemy.x,
                        y: geometry.size.height / 2 + enemy.y
                    )
                }
                
                // Game UI
                VStack {
                    HStack {
                        Button(action: onBack) {
                            Text("← 返回")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        // Lives display with hearts
                        HStack(spacing: 5) {
                            Text("生命值:")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            ForEach(0..<3, id: \.self) { index in
                                Text(index < gameManager.lives ? "❤️" : "🖤")
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
                        
                        Text("分数: \(gameManager.score)")
                            .foregroundColor(.yellow)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .padding()
                    
                    Spacer()
                    
                    if gameManager.isGameOver {
                        GameOverView(score: gameManager.score) {
                            gameManager.startGame()
                        }
                    }
                }
            }
        }
        .onChange(of: gameManager.isGameOver) { _, isGameOver in
            if isGameOver {
                // 游戏结束时的震动反馈
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
            }
        }
    }
}

struct ConnectionWaitingView: View {
    @ObservedObject var headphoneMotionManager: HeadphoneMotionManager
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button(action: onBack) {
                    Text("← 返回")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Spacer()
            }
            .padding()
            
            Spacer()
            
            Image(systemName: "airpodspro")
                .font(.system(size: 80))
                .foregroundColor(.white)
            
            Text("等待 AirPods Pro 连接...")
                .font(.title2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                Text("游戏说明:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• 左右歪头控制 🗡️ 旋转方向")
                    Text("• 前后仰头控制 🗡️ 距离远近")
                    Text("• 用武器消灭向红心移动的红点")
                    Text("• 每消灭一个敌人得1分")
                    Text("• 敌人碰到红心会失去生命值")
                    Text("• 生命值归零游戏结束")
                }
                .font(.body)
                .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            
            Text("请确保您的 AirPods Pro 已连接到设备")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: {
                headphoneMotionManager.restart()
            }) {
                Text("重试连接")
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct GameOverView: View {
    let score: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("游戏结束")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("最终分数: \(score)")
                .font(.title)
                .foregroundColor(.yellow)
            
            Button(action: onRestart) {
                Text("重新开始")
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(25)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(20)
    }
}

// Enemy model
struct Enemy: Identifiable, Equatable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat = 1.0
    var pulseScale: CGFloat = 1.0
    
    mutating func moveTowardsCenter() {
        let distance = sqrt(x * x + y * y)
        if distance > 0 {
            let normalizedX = x / distance
            let normalizedY = y / distance
            x -= normalizedX * speed
            y -= normalizedY * speed
        }
        
        // Update pulse animation
        pulseScale = 1.0 + sin(Date().timeIntervalSince1970 * 3) * 0.2
    }
    
    func distanceFromCenter() -> CGFloat {
        return sqrt(x * x + y * y)
    }
    
    func distanceFromWeapon(weaponX: CGFloat, weaponY: CGFloat) -> CGFloat {
        let dx = x - weaponX
        let dy = y - weaponY
        return sqrt(dx * dx + dy * dy)
    }
}

// Game manager
class GameManager: ObservableObject {
    @Published var enemies: [Enemy] = []
    @Published var lives: Int = 3
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var weaponAngle: Double = 0.0
    @Published var weaponDistance: CGFloat = 60.0
    
    let gameRadius: CGFloat = 200
    private var enemySpawnTimer: Timer?
    private var cumulativeAngle: Double = 0.0 // 累积角度，避免角度跳跃
    
    func startGame() {
        enemies = []
        lives = 3
        score = 0
        isGameOver = false
        isPaused = false
        weaponAngle = 0.0
        weaponDistance = 60.0
        cumulativeAngle = 0.0
        
        // Start spawning enemies (gets faster as score increases)
        startEnemySpawning()
    }
    
    func updateGame(pitch: Double, roll: Double, yaw: Double) {
        if isGameOver || isPaused { return }
        
        // Update weapon position based on head movements
        // Roll controls rotation: left tilt = counterclockwise, right tilt = clockwise
        // Pitch controls distance: forward = closer, backward = farther
        
        // Convert roll to angular velocity (degrees per frame)
        let rollSensitivity = 0.8 // Reduced from 2.0 to make rotation slower and more precise
        let rollDegrees = roll * rollSensitivity
        
        // Update cumulative angle based on roll (left negative, right positive)
        cumulativeAngle += rollDegrees
        weaponAngle = cumulativeAngle
        
        // Convert pitch to distance (30-100 pixels range)
        let pitchSensitivity = 0.8
        let baseDist: CGFloat = 65.0
        let pitchOffset = CGFloat(pitch * pitchSensitivity)
        weaponDistance = max(30, min(100, baseDist - pitchOffset)) // Forward pitch decreases distance
        
        // Update enemy positions
        for i in enemies.indices {
            enemies[i].moveTowardsCenter()
        }
        
        // Check for collisions with weapon first (before removing enemies that hit center)
        let weaponX = cos(weaponAngle * .pi / 180) * weaponDistance
        let weaponY = sin(weaponAngle * .pi / 180) * weaponDistance
        
        var enemiesToRemove: [UUID] = []
        
        for enemy in enemies {
            // Check collision with weapon - increased collision radius for better detection
            let distance = enemy.distanceFromWeapon(weaponX: weaponX, weaponY: weaponY)
            if distance < 35 { // Increased from 25 to 35 for better collision detection
                enemiesToRemove.append(enemy.id)
                score += 1
                // Light haptic feedback for destroying enemy
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                print("敌人被击中! 距离: \(distance), 分数: \(score)") // Debug info
            }
        }
        
        // Remove enemies hit by weapon
        enemies.removeAll { enemy in
            enemiesToRemove.contains(enemy.id)
        }
        
        // Check for collisions with player (center)
        enemies.removeAll { enemy in
            if enemy.distanceFromCenter() < 30 { // Heart collision radius
                lives -= 1
                // Haptic feedback for taking damage
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                print("玩家受伤! 剩余生命: \(lives)") // Debug info
                
                if lives <= 0 {
                    isGameOver = true
                    enemySpawnTimer?.invalidate()
                    enemySpawnTimer = nil
                }
                return true
            }
            return false
        }
    }
    
    private func spawnEnemy() {
        if isGameOver { return }
        
        // Random angle for spawning
        let angle = Double.random(in: 0...(2 * .pi))
        let spawnRadius = gameRadius + 50 // Spawn outside the game circle
        
        let enemy = Enemy(
            x: cos(angle) * spawnRadius,
            y: sin(angle) * spawnRadius,
            speed: CGFloat.random(in: 0.8...1.5)
        )
        
        enemies.append(enemy)
    }
    
    func pauseGame() {
        isPaused = true
        enemySpawnTimer?.invalidate()
        enemySpawnTimer = nil
    }
    
    private func startEnemySpawning() {
        if isPaused || isGameOver { return }
        let interval = max(1.5, 3.0 - Double(score) * 0.1) // Slower spawn rate for testing, gets faster with higher score
        enemySpawnTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.spawnEnemy()
            self?.startEnemySpawning() // Restart with new interval
        }
    }
    
    deinit {
        enemySpawnTimer?.invalidate()
    }
}
