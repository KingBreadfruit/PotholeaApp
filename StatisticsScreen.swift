import SwiftUI
import Charts

struct StatisticsScreen: View {
    @Environment(\.presentationMode) var presentationMode  // For navigating back
    @State private var userReports: Int = 5  // Placeholder for number of reports
    @State private var resolvedReports: Int = 3  // Placeholder for resolved reports
    @State private var accuracyRate: Double = 75.0  // Placeholder accuracy rate
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [AppColors.backgroundBlack, AppColors.surfaceBlack]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("STATISTICS")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryGold)
                        .tracking(2)
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // User Reports Card
                VStack(spacing: 24) {
                    Text("REPORTS OVERVIEW")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textGray)
                        .tracking(2)
                    
                    // Metrics in circular indicators
                    HStack(spacing: 30) {
                        // Total Reports
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .fill(AppColors.surfaceBlack)
                                    .frame(width: 72, height: 72)
                                
                                Text("\(userReports)")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(AppColors.primaryGold)
                            }
                            
                            Text("Submitted")
                                .font(.caption)
                                .foregroundColor(AppColors.textGray)
                        }
                        
                        // Resolved Reports
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .fill(AppColors.surfaceBlack)
                                    .frame(width: 72, height: 72)
                                
                                Text("\(resolvedReports)")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(AppColors.primaryGold)
                            }
                            
                            Text("Resolved")
                                .font(.caption)
                                .foregroundColor(AppColors.textGray)
                        }
                    }
                    .padding(.vertical, 12)
                    
                    // Resolution Progress
                    VStack(spacing: 10) {
                        HStack {
                            Text("Resolution Rate")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppColors.textGray)
                            
                            Spacer()
                            
                            Text("\(Int((Double(resolvedReports) / Double(userReports)) * 100))%")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.primaryGold)
                        }
                        
                        // Custom Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: geometry.size.width, height: 12)
                                    .foregroundColor(AppColors.surfaceBlack)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                                    )
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: (geometry.size.width * CGFloat(resolvedReports)) / CGFloat(userReports), height: 12)
                                    .foregroundColor(AppColors.primaryGold)
                            }
                        }
                        .frame(height: 12)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 12)
                }
                .padding(20)
                .background(AppColors.surfaceBlack)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                // Accuracy Chart
                VStack(spacing: 20) {
                    Text("DETECTION ACCURACY")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textGray)
                        .tracking(2)
                    
                    // Accuracy Display
                    ZStack {
                        Circle()
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [AppColors.darkGold.opacity(0.3), AppColors.primaryGold]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(Double(accuracyRate) * 360 / 100)
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 150, height: 150)
                        
                        VStack(spacing: 4) {
                            Text("\(Int(accuracyRate))%")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(AppColors.primaryGold)
                            
                            Text("Accuracy")
                                .font(.caption)
                                .foregroundColor(AppColors.textGray)
                        }
                    }
                    .padding(.vertical, 16)
                    
                    // Chart View for Accuracy
                    Chart {
                        BarMark(
                            x: .value("Metric", "Accuracy"),
                            y: .value("Percentage", accuracyRate)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.primaryGold, AppColors.darkGold]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(8)
                    }
                    .frame(height: 120)
                    .padding()
                    .chartYScale(domain: 0...100)
                }
                .padding(20)
                .background(AppColors.surfaceBlack)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.darkGold.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.primaryGold)
                        Text("Back")
                            .foregroundColor(AppColors.primaryGold)
                    }
                }
            }
        }
    }
}

#Preview {
    StatisticsScreen()
}
