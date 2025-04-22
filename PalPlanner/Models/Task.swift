//
//  Task.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import Foundation

enum TaskStatus: String, Codable {
    case pending
    case completed
    case failed
}

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var date: Date
    var dueTime: Date
    var status: TaskStatus = .pending
    var points: Int = 10
    var gracePeriodMinutes: Int = 30 // Grace period in minutes
    
    var isExpired: Bool {
        guard status == .pending else { return false }
        
        let calendar = Calendar.current
        let dueDateTime = combineDateTime(date: date, time: dueTime)
        let graceEndTime = calendar.date(byAdding: .minute, value: gracePeriodMinutes, to: dueDateTime) ?? dueDateTime
        
        return Date() > graceEndTime
    }
    
    var formattedDueTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: dueTime)
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
    
    static var sampleTasks: [Task] {
        let calendar = Calendar.current
        let today = Date()
        
        // Create time components for sample tasks
        var morning = DateComponents()
        morning.hour = 8
        morning.minute = 0
        
        var afternoon = DateComponents()
        afternoon.hour = 14
        afternoon.minute = 30
        
        var evening = DateComponents()
        evening.hour = 19
        evening.minute = 0
        
        return [
            Task(
                title: "Morning Workout",
                description: "30 minutes of cardio",
                date: today,
                dueTime: calendar.date(from: morning) ?? today,
                points: 15
            ),
            Task(
                title: "Study Swift",
                description: "Learn about SwiftUI animations",
                date: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                dueTime: calendar.date(from: afternoon) ?? today,
                points: 20
            ),
            Task(
                title: "Grocery Shopping",
                description: "Buy fruits and vegetables",
                date: calendar.date(byAdding: .day, value: 2, to: today) ?? today,
                dueTime: calendar.date(from: evening) ?? today,
                points: 10
            )
        ]
    }
}
