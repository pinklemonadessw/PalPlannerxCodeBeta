//
//  CalendarView.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var selectedDate = Date()
    @State private var showingAddTask = false
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Month and year header
                HStack {
                    Text(monthYearString(from: selectedDate))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    
                    Button(action: {
                        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                // Days of week header
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(Array(daysInMonth(for: selectedDate).enumerated()), id: \.offset) { index, date in
                        if let date = date {
                            let tasksForDay = taskManager.tasksForDate(date)
                            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                            let hasPendingTasks = !taskManager.pendingTasksForDate(date).isEmpty
                            let hasCompletedTasks = !taskManager.completedTasksForDate(date).isEmpty
                            let hasFailedTasks = !taskManager.failedTasksForDate(date).isEmpty
                            
                            Button(action: {
                                selectedDate = date
                            }) {
                                VStack {
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.system(size: 16))
                                        .fontWeight(isSelected ? .bold : .regular)
                                    
                                    if !tasksForDay.isEmpty {
                                        HStack(spacing: 3) {
                                            if hasPendingTasks {
                                                Circle()
                                                    .fill(Color.purple)
                                                    .frame(width: 6, height: 6)
                                            }
                                            
                                            if hasCompletedTasks {
                                                Circle()
                                                    .fill(Color.green)
                                                    .frame(width: 6, height: 6)
                                            }
                                            
                                            if hasFailedTasks {
                                                Circle()
                                                    .fill(Color.red)
                                                    .frame(width: 6, height: 6)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(isSelected ? Color.purple.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                            }
                        } else {
                            Text("")
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 8)
                
                Divider()
                    .padding(.vertical)
                
                // Tasks for selected day
                VStack(alignment: .leading) {
                    HStack {
                        Text("Tasks for \(dayString(from: selectedDate))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddTask = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // Task status legend
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 8, height: 8)
                            Text("Pending")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("Failed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 4)
                    
                    if taskManager.tasksForDate(selectedDate).isEmpty {
                        VStack {
                            Spacer()
                            Text("No tasks for this day")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .frame(height: 200)
                    } else {
                        List {
                            ForEach(taskManager.tasksForDate(selectedDate)) { task in
                                TaskRow(task: task, taskManager: taskManager)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Planner")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(taskManager: taskManager, selectedDate: selectedDate)
            }
            .onAppear {
                // Check for expired tasks when the view appears
                taskManager.checkExpiredTasks()
            }
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func daysInMonth(for date: Date) -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        var days = [Date?](repeating: nil, count: firstWeekday - 1)
        
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        // Fill the remaining cells to complete the grid
        let remainingCells = 7 - (days.count % 7)
        if remainingCells < 7 {
            days.append(contentsOf: [Date?](repeating: nil, count: remainingCells))
        }
        
        return days
    }
}
