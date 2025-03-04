import SwiftUI
import Charts

struct StatisticsScreen: View {
    @Environment(\.presentationMode) var presentationMode  // For navigating back
    @State private var userReports: Int = 5  // Placeholder for number of reports
    @State private var resolvedReports: Int = 3  // Placeholder for resolved reports
    @State private var accuracyRate: Double = 75.0  // Placeholder accuracy rate
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer(minLength: 20)
                
                // Header with Back Button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Navigate back to Dashboard
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                
                Text("Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                // User Reports & Resolved Cases
                VStack(spacing: 15) {
                    Text("Reports Submitted: \(userReports)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Resolved Reports: \(resolvedReports)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    // Progress Bar for Reports Resolved
                    ProgressView("Resolution Rate", value: Double(resolvedReports), total: Double(userReports))
                        .padding()
                        .accentColor(.green)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal, 30)
                
                // Accuracy Chart
                VStack {
                    Text("Detection Accuracy")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Chart {
                        BarMark(
                            x: .value("Metric", "Accuracy"),
                            y: .value("Percentage", accuracyRate)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 200)
                    .padding()
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding(.top, 50)
            .navigationBarHidden(true) // Hide default navigation bar to use custom back button
        }
    }
}

#Preview {
    StatisticsScreen()
}
