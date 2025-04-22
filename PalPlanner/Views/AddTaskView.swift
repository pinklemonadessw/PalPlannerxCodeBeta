//
//  AddTaskView.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/17/25.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var title = ""
    @State private var description = ""
    @State private var points = 10
    @State private var dueTime = Date()
    @State private var gracePeriod = 30
    let selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    
    private let gracePeriodOptions = [15, 30, 60, 120]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    
                    Stepper("Points: \(points)", value: $points, in: 5...50, step: 5)
                    
                    DatePicker("Due Time", selection: $dueTime, displayedComponents: .hourAndMinute)
                    
                    Picker("Grace Period", selection: $gracePeriod) {
                        ForEach(gracePeriodOptions, id: \.self) { minutes in
                            Text(minutes == 1 ? "1 minute" : "\(minutes) minutes")
                        }
                    }
                    
                    Text("Date: \(formattedDate)")
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Task Deadline Info")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tasks must be completed by the due time.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("A grace period gives you extra time after the due time.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("If not completed within the grace period, the task will be marked as failed and no points will be awarded.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveTask()
                }
                .disabled(title.isEmpty)
            )
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    private func saveTask() {
        let newTask = Task(
            title: title,
            description: description,
            date: selectedDate,
            dueTime: dueTime,
            points: points,
            gracePeriodMinutes: gracePeriod
        )
        
        taskManager.addTask(newTask)
        presentationMode.wrappedValue.dismiss()
    }
}
