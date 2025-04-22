//
//  TaskRow.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/17/25.
//

import SwiftUI

struct TaskRow: View {
    let task: Task
    @ObservedObject var taskManager: TaskManager
    @State private var timeRemaining: String = ""
    @State private var timer: Timer? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .fontWeight(.medium)
                    .strikethrough(task.status != .pending)
                    .foregroundColor(statusColor)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .strikethrough(task.status != .pending)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Due at \(task.formattedDueTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if task.status == .pending {
                        Text(timeRemaining)
                            .font(.caption)
                            .foregroundColor(timeRemainingColor)
                            .onAppear {
                                updateTimeRemaining()
                                startTimer()
                            }
                            .onDisappear {
                                timer?.invalidate()
                                timer = nil
                            }
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(pointsText)
                    .font(.caption)
                    .padding(4)
                    .background(pointsBackgroundColor)
                    .foregroundColor(pointsTextColor)
                    .cornerRadius(4)
                
                if task.status == .pending {
                    Button(action: {
                        taskManager.completeTask(task)
                    }) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.purple)
                            .font(.system(size: 24))
                    }
                } else if task.status == .completed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 24))
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 24))
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch task.status {
        case .pending: return .primary
        case .completed: return .green
        case .failed: return .red
        }
    }
    
    private var pointsText: String {
        switch task.status {
        case .pending: return "+\(task.points)"
        case .completed: return "+\(task.points)"
        case .failed: return "0"
        }
    }
    
    private var pointsBackgroundColor: Color {
        switch task.status {
        case .pending: return Color.purple.opacity(0.2)
        case .completed: return Color.green.opacity(0.2)
        case .failed: return Color.red.opacity(0.2)
        }
    }
    
    private var pointsTextColor: Color {
        switch task.status {
        case .pending: return .purple
        case .completed: return .green
        case .failed: return .red
        }
    }
    
    private var timeRemainingColor: Color {
        // Calculate time remaining in minutes
        let calendar = Calendar.current
        let dueDateTime = combineDateTime(date: task.date, time: task.dueTime)
        let timeRemaining = calendar.dateComponents([.minute], from: Date(), to: dueDateTime).minute ?? 0
        
        if timeRemaining < 0 {
            // Past due but within grace period
            return .orange
        } else if timeRemaining < 60 {
            // Less than an hour remaining
            return .orange
        } else {
            // More than an hour remaining
            return .secondary
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        let calendar = Calendar.current
        let dueDateTime = combineDateTime(date: task.date, time: task.dueTime)
        
        if Date() > dueDateTime {
            // Past due time
            let graceEndTime = calendar.date(byAdding: .minute, value: task.gracePeriodMinutes, to: dueDateTime) ?? dueDateTime
            
            if Date() > graceEndTime {
                timeRemaining = "Expired"
                // Ensure task is marked as failed
                DispatchQueue.main.async {
                    taskManager.checkExpiredTasks()
                }
            } else {
                let minutesLeft = calendar.dateComponents([.minute], from: Date(), to: graceEndTime).minute ?? 0
                timeRemaining = "Grace: \(minutesLeft)m left"
            }
        } else {
            // Before due time
            let components = calendar.dateComponents([.hour, .minute], from: Date(), to: dueDateTime)
            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0
            
            if hours > 0 {
                timeRemaining = "\(hours)h \(minutes)m left"
            } else {
                timeRemaining = "\(minutes)m left"
            }
        }
    }
    
    private func combineDateTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        return calendar.date(from: combinedComponents) ?? date
    }
}
