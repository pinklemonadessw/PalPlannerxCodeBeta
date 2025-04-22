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
    
    init() {
        startExpirationTimer()
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
    
    func checkExpiredTasks() {
        var updated = false
        
        for (index, task) in tasks.enumerated() {
            if task.status == .pending && task.isExpired {
                tasks[index].status = .failed
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
                objectWillChange.send()
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        objectWillChange.send()
    }
    
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDate($0.date, inSameDayAs: date) }
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
