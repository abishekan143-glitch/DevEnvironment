#if os(iOS)
import Foundation
import SwiftUI
public struct FillFromDatabase: View {
    var BindVar: Binding<String>
    var Query: String
    var ErrorApnd: String
    var SelectBoxName: String
    var FirstDeafultValue: String = ""
    @State private var returnArray: [String] = []
    @State private var selectedProject1: String = ""
    @State private var a = 0
    @State private var isExpanded = false
    @State private var oneResult = false
    @State private var zeroResult = false
    @State private var results: [String] = []
    @Environment(\.colorScheme) var colorScheme
    public init(
            BindVar: Binding<String>,
            Query: String,
            ErrorApnd: String,
            SelectBoxName: String,
            FirstDeafultValue: String = ""
        ) {
            self.BindVar = BindVar
            self.Query = Query
            self.ErrorApnd = ErrorApnd
            self.SelectBoxName = SelectBoxName
            self.FirstDeafultValue = FirstDeafultValue
        }
    public func ProjectDropdown(query: String) -> [String] {
        var names: [String] = []
        let components = query
            .replacingOccurrences(of: "SELECT", with: "", options: .caseInsensitive)
            .components(separatedBy: "FROM")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard let columns = components, columns.count > 0 else { return names }
        let firstColumn = columns[0]
        let secondColumn = columns.count > 1 ? columns[1] : firstColumn
        _ = sql.reset()
        if let dictArray = sql.executeQuery(query).1 as? [[String: String]] {
            for dict in dictArray {
                if let firstValue = dict[firstColumn], !names.contains(firstValue) {
                    names.append(firstValue)
                }
                if let secondValue = dict[secondColumn], !results.contains(secondValue) {
                    results.append(secondValue)
                }
            }
            if names.count == 1 {
                oneResult = true
            }
        } else {
            zeroResult = true
        }
        return names
    }
    public var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack(spacing: 24) {
                    customPicker(label: SelectBoxName, selection: $selectedProject1)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            if !FirstDeafultValue.isEmpty {
                BindVar.wrappedValue = FirstDeafultValue
            }
            let newData = ProjectDropdown(query: Query)
            returnArray.append(contentsOf: newData.filter { !returnArray.contains($0) })
            selectedProject1 = SelectBoxName
            if oneResult {
                BindVar.wrappedValue = returnArray[0]
            }
        }.preferredColorScheme(.dark)
    }
    public func customPicker(label: String, selection: Binding<String>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.silverGray)
                .frame(height: 50)
            Menu {
                if !(oneResult || zeroResult) {
                    ForEach([label] + returnArray, id: \.self) { option in
                        Button(action: {
                            a = 1
                            isExpanded = false
                            selectedProject1 = option
                            if selectedProject1 != label {
                                BindVar.wrappedValue = selectedProject1
                                if let index = returnArray.firstIndex(of: selectedProject1) {
                                    BindVar.wrappedValue = results[index]
                                }
                            } else {
                                BindVar.wrappedValue = ""
                            }
                        }) {
                            Text(option)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } label: {
                HStack {
                    Text(label)
                        .foregroundColor(Color.silverGray)
                    Spacer()
                    Text(oneResult ? returnArray[0] :
                         zeroResult ? ErrorApnd :
                         selectedProject1 == label ? (a == 0 && !FirstDeafultValue.isEmpty) ? FirstDeafultValue : "" : selectedProject1)
                    .foregroundColor(.gray)
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color.silverGray)
                }
                .padding(.horizontal)
            }
        }
    }
}
public struct DropDown: View {
    var BindVar: Binding<String>
    var ShowArray: [String]
    var ErrorApnd: String
    var SelectBoxName: String
    var FirstDeafultValue: String = ""
    @State private var selectedProject1: String = ""
    @State private var a = 0
    @State private var oneResult = false
    @State private var zeroResult = false
    @Environment(\.colorScheme) var colorScheme
    public var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack(spacing: 24) {
                    customPicker(label: SelectBoxName, selection: $selectedProject1)
                }
                .onAppear(){
                    if ShowArray.isEmpty {
                        zeroResult = true
                    } else if ShowArray.count == 1 {
                        oneResult = true
                    }
                    if !FirstDeafultValue.isEmpty && !ShowArray.isEmpty {
                        BindVar.wrappedValue = FirstDeafultValue
                    }
                    selectedProject1 = SelectBoxName
                }
            }
            .padding(.horizontal)
        }.preferredColorScheme(.dark)
    }
    public init(
            BindVar: Binding<String>,
            ShowArray: [String],
            ErrorApnd: String,
            SelectBoxName: String,
            FirstDeafultValue: String = ""
        ) {
            self.BindVar = BindVar
            self.ShowArray = ShowArray
            self.ErrorApnd = ErrorApnd
            self.SelectBoxName = SelectBoxName
            self.FirstDeafultValue = FirstDeafultValue
        }
    public func customPicker(label: String, selection: Binding<String>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.silverGray)
                .frame(height: 50)
            Menu {
                if !(oneResult || zeroResult) {
                    ForEach([label] + ShowArray, id: \.self) { option in
                        Button(action: {
                            a = 1
                            selectedProject1 = option
                            if selectedProject1 != label {
                                BindVar.wrappedValue = selectedProject1
                                if let index = ShowArray.firstIndex(of: selectedProject1) {
                                    BindVar.wrappedValue = ShowArray[index]
                                }
                            } else {
                                BindVar.wrappedValue = ""
                            }
                        }) {
                            Text(option)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } label: {
                HStack {
                    Text(label)
                        .foregroundColor(Color.silverGray)
                    Spacer()
                    Text(oneResult ? ShowArray[0] : zeroResult ? ErrorApnd : selectedProject1 != label ? selectedProject1 : (a == 0 && !FirstDeafultValue.isEmpty) ? FirstDeafultValue : "")
                    .foregroundColor(.gray)
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color.silverGray)
                }
                .padding(.horizontal)
            }
        }
    }
}
#endif
