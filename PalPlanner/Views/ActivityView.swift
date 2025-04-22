//
//  ActivityView.swift
//  PalPlanner
//
//  Created by Logan Leatherwood on 4/16/25.
//

import SwiftUI

struct ActivityView: View {
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        NavigationView {
            VStack {
                // Points summary
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total PalPoints")
                            .font(.headline)
                        
                        Text("\(taskManager.palPoints)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Tasks Completed")
                            .font(.headline)
                        
                        Text("\(taskManager.tasks.filter { $0.status == .completed }.count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding()
                
                // Recent activity list
                List {
                    Section(header: Text("Recent Activity")) {
                        let completedTasks = taskManager.tasks.filter { $0.status == .completed }.sorted { $0.date > $1.date }
                        
                        if completedTasks.isEmpty {
                            Text("No completed tasks yet")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(completedTasks) { task in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(task.title)
                                            .fontWeight(.medium)
                                        
                                        HStack {
                                            Text(formattedDate(task.date))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text("at \(task.formattedDueTime)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("+\(task.points)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.purple)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.purple.opacity(0.2))
                                        .cornerRadius(8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Section(header: Text("Upcoming Tasks")) {
                        let pendingTasks = taskManager.tasks.filter { $0.status == .pending }.sorted { $0.date < $1.date }
                        
                        if pendingTasks.isEmpty {
                            Text("No upcoming tasks")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(pendingTasks) { task in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(task.title)
                                            .fontWeight(.medium)
                                        
                                        HStack {
                                            Text(formattedDate(task.date))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text("at \(task.formattedDueTime)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("+\(task.points)")
                                        .font(.subheadline)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.purple.opacity(0.2))
                                        .cornerRadius(8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Section(header: Text("Failed Tasks")) {
                        let failedTasks = taskManager.tasks.filter { $0.status == .failed }.sorted { $0.date > $1.date }
                        
                        if failedTasks.isEmpty {
                            Text("No failed tasks")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(failedTasks) { task in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(task.title)
                                            .fontWeight(.medium)
                                            .foregroundColor(.red)
                                        
                                        HStack {
                                            Text(formattedDate(task.date))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text("at \(task.formattedDueTime)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("Failed")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.2))
                                        .foregroundColor(.red)
                                        .cornerRadius(8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Check for expired tasks when the view appears
                taskManager.checkExpiredTasks()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
