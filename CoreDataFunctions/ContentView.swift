//
//  ContentView.swift
//  CoreDataFunctions
//
//  Created by Patrick Wynne on 1/21/23.
//

import SwiftUI
import CoreData

extension PersistenceController {
    func employeeCount() -> Int {
        let count = try? container.viewContext.count(for: Employee.fetchRequest())
        return count ?? 0
    }
    
    func minSalary() -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "Employee")
        request.resultType = .dictionaryResultType
        
        let salaryExp = NSExpressionDescription()
        salaryExp.expressionResultType = .doubleAttributeType
        salaryExp.expression = NSExpression(forFunction: "min:", arguments: [NSExpression(forKeyPath: "salary")])
        salaryExp.name = "minSalary"
        
        request.propertiesToFetch = [salaryExp]
        
        let result = try! container.viewContext.fetch(request) as! [[String: AnyObject]]
        let minSalary = result[0]["minSalary"] as? Double ?? 0.0
        return minSalary
    }
    
    func maxSalary() -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "Employee")
        request.resultType = .dictionaryResultType
        
        let salaryExp = NSExpressionDescription()
        salaryExp.expressionResultType = .doubleAttributeType
        salaryExp.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "salary")])
        salaryExp.name = "maxSalary"
        
        request.propertiesToFetch = [salaryExp]
        
        let result = try! container.viewContext.fetch(request) as! [[String: AnyObject]]
        let maxSalary = result[0]["maxSalary"] as? Double ?? 0.0
        return maxSalary
    }
    
    func averageSalary() -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "Employee")
        request.resultType = .dictionaryResultType
        
        let salaryExp = NSExpressionDescription()
        salaryExp.expressionResultType = .doubleAttributeType
        salaryExp.expression = NSExpression(forFunction: "average:", arguments: [NSExpression(forKeyPath: "salary")])
        salaryExp.name = "avgSalary"
        
        request.propertiesToFetch = [salaryExp]
        
        let result = try! container.viewContext.fetch(request) as! [[String: AnyObject]]
        let avgSalary = result[0]["avgSalary"] as? Double ?? 0.0
        return avgSalary
    }
    
    func salarySum() -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "Employee")
        request.resultType = .dictionaryResultType
        
        let salaryExp = NSExpressionDescription()
        salaryExp.expressionResultType = .doubleAttributeType
        salaryExp.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "salary")])
        salaryExp.name = "sumSalary"
        
        request.propertiesToFetch = [salaryExp]
        
        let result = try! container.viewContext.fetch(request) as! [[String: AnyObject]]
        let sumSalary = result[0]["sumSalary"] as? Double ?? 0.0
        return sumSalary
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.salary)])
    private var employees: FetchedResults<Employee>
    
    var employeeCount: Int {
        PersistenceController.shared.employeeCount()
    }
    
    var minSalary: Double {
        PersistenceController.shared.minSalary()
    }
    
    var maxSalary: Double {
        PersistenceController.shared.maxSalary()
    }
    
    var avgSalary: Double {
        PersistenceController.shared.averageSalary()
    }
    
    var salarySum: Double {
        PersistenceController.shared.salarySum()
    }
    
    func infoLine(_ label: String, data: String) -> some View {
        HStack {
            Text("\(label): ")
            Spacer()
            Text(data).monospacedDigit()
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .leading) {
                    infoLine("Employee Count", data: employeeCount.formatted())
                    infoLine("Min Salary", data: minSalary.formatted(.currency(code: "USD")))
                    infoLine("Average Salary", data: avgSalary.formatted(.currency(code: "USD")))
                    infoLine("Max Salary", data: maxSalary.formatted(.currency(code: "USD")))
                    infoLine("Salary Sum", data: salarySum.formatted(.currency(code: "USD")))
                }
                ForEach(employees) { employee in
                    infoLine("\(employee.type!)", data: employee.salary.formatted(.currency(code: "USD")))
                }
            }
            .toolbar {
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
            .navigationTitle("Employee Data")
        }
    }
    
    private func addEmployee() {
        withAnimation {
            let newEmployee = Employee(context: viewContext)
            newEmployee.type = "Employee"
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
