import Foundation
import UserNotifications

enum NotificationTime: String, CaseIterable, Identifiable {
    case dayBefore = "1 day before"
    case dayOf = "Day of task"
    case hourBefore = "1 hour before"
    case fifteenMinutesBefore = "15 minutes before"
    case none = "No notification"
    
    var id: String { self.rawValue }
    
    func timeInterval(from dueDate: Date) -> TimeInterval? {
        guard self != .none else { return nil }
        
        let calendar = Calendar.current
        switch self {
        case .dayBefore:
            return calendar.date(byAdding: .day, value: -1, to: dueDate)?.timeIntervalSinceNow
        case .dayOf:
            // Set to 9 AM on the day of
            var components = calendar.dateComponents([.year, .month, .day], from: dueDate)
            components.hour = 9
            components.minute = 0
            return calendar.date(from: components)?.timeIntervalSinceNow
        case .hourBefore:
            return calendar.date(byAdding: .hour, value: -1, to: dueDate)?.timeIntervalSinceNow
        case .fifteenMinutesBefore:
            return calendar.date(byAdding: .minute, value: -15, to: dueDate)?.timeIntervalSinceNow
        case .none:
            return nil
        }
    }
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleTaskNotification(for task: Task, time: NotificationTime) {
        guard let timeInterval = time.timeInterval(from: combineDateTime(date: task.date, time: task.dueTime)),
              timeInterval > 0 else {
            print("Notification time is in the past or invalid")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "\(time.rawValue): \(task.title)"
        content.sound = .default
        
        // Create a unique identifier for this notification
        let identifier = "\(task.id)-\(time.rawValue)"
        
        // Create the trigger and request
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Task notification scheduled for \(time.rawValue)")
            }
        }
    }
    
    func scheduleDefaultTaskNotification(for task: Task) {
        // Schedule the 15 minutes before notification by default
        scheduleTaskNotification(for: task, time: .fifteenMinutesBefore)
    }
    
    func cancelNotifications(for taskId: UUID) {
        // Create an array of possible identifiers for this task
        let identifiers = NotificationTime.allCases.map { "\(taskId)-\($0.rawValue)" }
        
        // Remove these notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
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
} 