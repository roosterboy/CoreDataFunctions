//
//  ContentView.swift
//  CoreDataFunctions
//
//  Created by Patrick Wynne on 1/21/23.
//

import SwiftUI
import CoreData

extension PersistenceController {
    func maxSalary() -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "Employee")
        request.resultType = .dictionaryResultType
        
        let salaryExp = NSExpressionDescription()
        salaryExp.expressionResultType = .doubleAttributeType
        salaryExp.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "salary")])
        salaryExp.name = "maxSalary"
        
        request.propertiesToFetch = [salaryExp]
        
        let result = try! container.viewContext.fetch(request) as! [[String: AnyObject]]
        let max = result[0]["maxSalary"] as? Double ?? 0.0
        return max
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.salary)])
    private var employees: FetchedResults<Employee>
    
    var maxSalary: Double {
        PersistenceController.shared.maxSalary()
    }
    
    var body: some View {
        NavigationView {
            List {
                Text("Max Salary: \(maxSalary.formatted(.currency(code: "USD")))")
                ForEach(employees) { employee in
                    NavigationLink {
                        VStack(spacing: 0) {
                            Text("Type: \(employee.employeeType!)")
                            Text("Salary: \(employee.salary.formatted(.currency(code: "USD")))")
                        }
                    } label: {
                        Text("\(employee.employeeType!) (\(employee.salary.formatted(.currency(code: "USD"))))")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: deleteAllEmployees) {
                        Label("Delete All Employees", systemImage: "minus.diamond")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: addEmployee) {
                        Label("Add Employee", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func addEmployee() {
        withAnimation {
            let newEmployee = Employee(context: viewContext)
            newEmployee.employeeType = "Employee"
            newEmployee.salary = Double.random(in: 60_000...140_000)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { employees[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteAllEmployees() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: "Employee")
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        let context = PersistenceController.shared.container.viewContext
        let batchDelete = try? context.execute(deleteRequest) as? NSBatchDeleteResult
        
        guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else {
            return
        }
        
        let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
        
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [context])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
