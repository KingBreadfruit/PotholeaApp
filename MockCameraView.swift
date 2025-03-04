import SwiftUI

struct MockCameraView: View {
    @State private var depthData: String = "No LiDAR data yet"

    var body: some View {
        VStack {
            // Simulated Camera Feed
            Rectangle()
                .fill(Color.gray)
                .frame(maxWidth: .infinity, maxHeight: 300)
                .overlay(
                    Text("Simulated Camera Feed")
                        .foregroundColor(.white)
                        .font(.headline)
                )
            
            Spacer()
            
            // Simulated LiDAR Depth Data
            Text("LiDAR Depth Data: \(depthData)")
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            
            Spacer()
            
            // Simulate Data Button
            Button(action: {
                // Simulate Depth Data
                depthData = "Depth: \(Int.random(in: 1...100)) cm"
            }) {
                Text("Simulate LiDAR Data")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
