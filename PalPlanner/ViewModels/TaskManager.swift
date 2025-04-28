//
//  TaskManager.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import Foundation
import Combine

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = Task.sampleTasks
    @Published var palPoints: Int = 100
    private var timer: Timer?
    private let notificationManager = NotificationManager.shared
    
    init() {
        startExpirationTimer()
        scheduleDefaultNotifications()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startExpirationTimer() {
        // Check for expired tasks every minute
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkExpiredTasks()
        }
        
        // Also check immediately upon initialization
        checkExpiredTasks()
    }
    
    private func scheduleDefaultNotifications() {
        // Schedule default notifications (15 minutes before) for all pending tasks
        for task in tasks where task.status == .pending {
            notificationManager.scheduleDefaultTaskNotification(for: task)
        }
    }
    
    func checkExpiredTasks() {
        var updated = false
        
        for (index, task) in tasks.enumerated() {
            if task.status == .pending && task.isExpired {
                tasks[index].status = .failed
                // Cancel notifications for failed tasks
                notificationManager.cancelNotifications(for: task.id)
                updated = true
            }
        }
        
        if updated {
            objectWillChange.send()
        }
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        objectWillChange.send()
    }
    
    func completeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            if tasks[index].status == .pending {
                tasks[index].status = .completed
                palPoints += tasks[index].points
                
                // Cancel notifications for completed task
                notificationManager.cancelNotifications(for: task.id)
                
                objectWillChange.send()
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        
        // Cancel notifications for deleted task
        notificationManager.cancelNotifications(for: task.id)
        
        objectWillChange.send()
    }
    
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { combineDateTime(date: $0.date, time: $0.dueTime) < combineDateTime(date: $1.date, time: $1.dueTime) }
    }
    
    // Helper to combine date and time components
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
    
    func pendingTasksForDate(_ date: Date) -> [Task] {
        return tasksForDate(date).filter { $0.status == .pending }
    }
    
    func completedTasksForDate(_ date: Date) -> [Task] {
        return tasksForDate(date).filter { $0.status == .completed }
    }
    
    func failedTasksForDate(_ date: Date) -> [Task] {
        return tasksForDate(date).filter { $0.status == .failed }
    }
}
