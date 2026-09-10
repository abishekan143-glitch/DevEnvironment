#if os(iOS)
import SwiftUI
// MARK: - DATA MODEL
public enum FieldType {
    case text
    case date
    case time
    case dateAndTime
    case secure
}

public struct TField: Identifiable {
    public let id = UUID()
    public var label: String
    public var value: Binding<String>
    public var width: CGFloat? = nil
    public var fieldType: FieldType
}

// MARK: - RIBT MAIN (Universal)
public struct RIBT: View {
    @State private var internalSettings: [TField]
    private let isSingle: Bool
    private let externalBinding: Binding<String>?
    private var height: CGFloat
    private var width: CGFloat?
    
    public init(
        placeholder: String,
        value: Binding<String>,
        height: CGFloat = 50,
        width: CGFloat? = nil,
        fieldType: FieldType = .text
    ) {
        self._internalSettings = State(initialValue: [
            TField(
                label: placeholder,
                value: value,
                width: width,
                fieldType: fieldType
            )
        ])
        self.isSingle = true
        self.externalBinding = value
        self.height = height
        self.width = width
    }
    
    public init(
        multipleTextFields: [TField],
        height: CGFloat = 50,
        width: CGFloat? = nil
    ) {
        self._internalSettings = State(initialValue: multipleTextFields)
        self.isSingle = false
        self.externalBinding = nil
        self.height = height
        self.width = width
    }
    
    public var body: some View {
        if isSingle {
            RIBTSingleField(
                item: Binding(
                    get: {
                        TField(
                            label: internalSettings[0].label,
                            value: externalBinding ?? .constant(""),
                            width: internalSettings[0].width ?? width,
                            fieldType: internalSettings[0].fieldType
                        )
                    },
                    set: { newValue in
                        externalBinding?.wrappedValue = newValue.value.wrappedValue
                    }
                ),
                height: height,
                width: internalSettings[0].width ?? width
            )
        } else {
            SettingsTextFieldList(Placeholder: $internalSettings, width: width)
        }
    }
}

public struct SettingsTextFieldList: View {
    @Binding var Placeholder: [TField]
    @State private var selectedFieldID: UUID?
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State public var isPasswordVisible = false
    public var width: CGFloat?
    @State private var text = "Pick Date"
    @FocusState private var focusedFieldID: UUID?

    public var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if showDatePicker || showTimePicker {
                        showDatePicker = false
                        showTimePicker = false
                        selectedFieldID = nil
                        print("Background tapped, pickers dismissed")
                    }
                }
            
            VStack(spacing: 16) {
                ForEach(Array(Placeholder.enumerated()), id: \.element.id) { index, item in
                    HStack {
                        Text(uc(item.label))
                            .foregroundColor(Color.silverGray)
                            .frame(minWidth: 80, alignment: .leading)
                            .bold()
                        Spacer()
                        HStack {
                            if item.fieldType == .secure {
                                Group {
                                    if isPasswordVisible {
                                        TextField("", text: item.value)
                                            .textFieldStyle(.plain)
                                            .focused($focusedFieldID, equals: item.id)
                                    } else {
                                        SecureField("", text: item.value)
                                            .textFieldStyle(.plain)
                                            .focused($focusedFieldID, equals: item.id)
                                    }
                                }
                                .foregroundColor(Color.silverGray)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 12)
                                .padding(.leading, 16)

                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(
                                        systemName: isPasswordVisible
                                            ? "eye" : "eye.slash"
                                    )
                                    .foregroundColor(Color.silverGray)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.trailing, 8)
                            } else {
                                TextField(
                                    " \(item.label.lowercased())",
                                    text: item.value
                                )
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Color.silverGray)
                                .textFieldStyle(.plain)
                                .disabled(
                                    item.fieldType != .text
                                        && item.fieldType != .secure
                                )
                                .focused($focusedFieldID, equals: item.id)
                            }
                            if item.fieldType == .date || item.fieldType == .dateAndTime {
                                Button {
                                    if selectedFieldID == item.id && showDatePicker {
                                        showDatePicker = false
                                        selectedFieldID = nil
                                    } else {
                                        selectedFieldID = item.id
                                        showDatePicker = true
                                        showTimePicker = false
                                        selectedDate = item.value.wrappedValue.isEmpty
                                            ? Date()
                                            : dateFromString(item.value.wrappedValue, isDate: true) ?? Date()
                                        if item.fieldType == .dateAndTime {
                                            selectedTime = item.value.wrappedValue.isEmpty
                                                ? Date()
                                                : dateFromString(item.value.wrappedValue, isDate: false) ?? Date()
                                        }
                                        print("Date picker toggled for field \(item.label), ID: \(item.id)")
                                    }
                                } label: {
                                    Text("📅")
                                        .font(.system(size: 22))
                                        .padding(.trailing, 8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else if item.fieldType == .time || item.fieldType == .dateAndTime {
                                Button {
                                    if selectedFieldID == item.id && showTimePicker {
                                        showTimePicker = false
                                        selectedFieldID = nil
                                    } else {
                                        selectedFieldID = item.id
                                        showDatePicker = false
                                        showTimePicker = true
                                        selectedTime = item.value.wrappedValue.isEmpty
                                            ? Date()
                                            : dateFromString(item.value.wrappedValue, isDate: false) ?? Date()
                                        print("Time picker toggled for field \(item.label), ID: \(item.id)")
                                    }
                                } label: {
                                    Text("🕒")
                                        .font(.system(size: 22))
                                        .padding(.trailing, 8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 12)
                        .cornerRadius(25)
                    }
                    .padding(.vertical, 8)

                    // Inline Date Picker for iOS
                    if showDatePicker && selectedFieldID == item.id {
                        #if os(iOS)
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { selectedDate },
                                set: { newDate in
                                    selectedDate = newDate
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .medium
                                    formatter.timeStyle = .none
                                    if let fieldIndex = Placeholder.firstIndex(where: { $0.id == selectedFieldID }) {
                                        Placeholder[fieldIndex].value.wrappedValue = formatter.string(from: newDate)
                                        print("Updated field \(Placeholder[fieldIndex].label) to \(formatter.string(from: newDate))")
                                        if item.fieldType == .dateAndTime {
                                            showDatePicker = false
                                            showTimePicker = true
                                        }
                                    }
                                }
                            ),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.wheel)
                        .padding()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding()
                        #elseif os(macOS)
                        VStack {
                            if selectedFieldID == nil {
                                Text("Error: Unable to load date picker. Please try again.")
                                    .foregroundColor(.red)
                                    .padding()
                                    .onAppear {
                                        print("Error: selectedFieldID is nil for macOS date picker")
                                    }
                            } else if let fieldID = selectedFieldID,
                                      let fieldIndex = Placeholder.firstIndex(where: { $0.id == fieldID }) {
                                VStack(spacing: 20) {
                                    DatePickerView(
                                        selectedDate: Binding(
                                            get: { selectedDate },
                                            set: { newDate in
                                                selectedDate = newDate
                                                let formatter = DateFormatter()
                                                formatter.dateStyle = .medium
                                                formatter.timeStyle = .none
                                                Placeholder[fieldIndex].value.wrappedValue = formatter.string(from: newDate)
                                                print("macOS: Updated field \(Placeholder[fieldIndex].label) to \(formatter.string(from: newDate))")
                                            }
                                        ),
                                        item: $Placeholder[fieldIndex]
                                    )
                                    
                                    Button(Placeholder[fieldIndex].fieldType == .date ? "Done" : "Next") {
                                        if Placeholder[fieldIndex].fieldType == .date {
                                            showDatePicker = false
                                            selectedFieldID = nil
                                            selectedDate = Date()
                                        } else {
                                            showDatePicker = false
                                            showTimePicker = true
                                        }
                                        print("macOS: Date picker dismissed for field ID \(fieldID)")
                                    }
                                    .padding()
                                }
                                .padding()
                            } else {
                                Text("Error: Unable to load date picker. Please try again.")
                                    .foregroundColor(.red)
                                    .padding()
                                    .onAppear {
                                        print("Error: selectedFieldID \(selectedFieldID?.uuidString ?? "nil") not found in Placeholder")
                                    }
                            }
                        }
                        #endif
                    }

                    // Inline Time Picker for iOS
                    if showTimePicker && selectedFieldID == item.id {
                        #if os(iOS)
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { selectedTime },
                                set: { newTime in
                                    selectedTime = newTime
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .none
                                    formatter.timeStyle = .short
                                    if let fieldIndex = Placeholder.firstIndex(where: { $0.id == selectedFieldID }) {
                                        if item.fieldType == .time {
                                            Placeholder[fieldIndex].value.wrappedValue = formatter.string(from: newTime)
                                            print("Updated time for field \(Placeholder[fieldIndex].label) to \(formatter.string(from: newTime))")
                                        } else if item.fieldType == .dateAndTime {
                                            let calendar = Calendar.current
                                            let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                                            let timeComponents = calendar.dateComponents([.hour, .minute], from: newTime)
                                            var combinedComponents = DateComponents()
                                            combinedComponents.year = dateComponents.year
                                            combinedComponents.month = dateComponents.month
                                            combinedComponents.day = dateComponents.day
                                            combinedComponents.hour = timeComponents.hour
                                            combinedComponents.minute = timeComponents.minute
                                            if let combinedDate = calendar.date(from: combinedComponents) {
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "MMM d, yyyy"
                                                let timeFormatter = DateFormatter()
                                                timeFormatter.dateFormat = "h:mm a"
                                                let combinedString = "\(dateFormatter.string(from: combinedDate)) | \(timeFormatter.string(from: combinedDate))"
                                                Placeholder[fieldIndex].value.wrappedValue = combinedString
                                                print("Updated date and time for field \(Placeholder[fieldIndex].label) to \(combinedString)")
                                            }
                                        }
                                    }
                                }
                            ),
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(.wheel)
                        .padding()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding()
                        #elseif os(macOS)
                        VStack {
                            if selectedFieldID == nil {
                                Text("Error: Unable to load time picker. Please try again.")
                                    .foregroundColor(.red)
                                    .padding()
                                    .onAppear {
                                        print("Error: selectedFieldID is nil for time picker")
                                    }
                            } else if let fieldID = selectedFieldID,
                                      let fieldIndex = Placeholder.firstIndex(where: { $0.id == fieldID }) {
                                VStack(spacing: 20) {
                                    DatePicker(
                                        "Select Time",
                                        selection: Binding(
                                            get: { selectedTime },
                                            set: { newTime in
                                                selectedTime = newTime
                                                let formatter = DateFormatter()
                                                formatter.dateStyle = .none
                                                formatter.timeStyle = .short
                                                if Placeholder[fieldIndex].fieldType == .time {
                                                    Placeholder[fieldIndex].value.wrappedValue = formatter.string(from: newTime)
                                                    print("macOS: Updated time for field \(Placeholder[fieldIndex].label) to \(formatter.string(from: newTime))")
                                                } else if Placeholder[fieldIndex].fieldType == .dateAndTime {
                                                    let calendar = Calendar.current
                                                    let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                                                    let timeComponents = calendar.dateComponents([.hour, .minute], from: newTime)
                                                    var combinedComponents = DateComponents()
                                                    combinedComponents.year = dateComponents.year
                                                    combinedComponents.month = dateComponents.month
                                                    combinedComponents.day = dateComponents.day
                                                    combinedComponents.hour = timeComponents.hour
                                                    combinedComponents.minute = timeComponents.minute
                                                    if let combinedDate = calendar.date(from: combinedComponents) {
                                                        let dateFormatter = DateFormatter()
                                                        dateFormatter.dateFormat = "MMM d, yyyy"
                                                        let timeFormatter = DateFormatter()
                                                        timeFormatter.dateFormat = "h:mm a"
                                                        let combinedString = "\(dateFormatter.string(from: combinedDate)) | \(timeFormatter.string(from: combinedDate))"
                                                        Placeholder[fieldIndex].value.wrappedValue = combinedString
                                                        print("macOS: Updated date and time for field \(Placeholder[fieldIndex].label) to \(combinedString)")
                                                    }
                                                }
                                            }
                                        ),
                                        displayedComponents: [.hourAndMinute]
                                    )
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                                    
                                    Button("Done") {
                                        showTimePicker = false
                                        selectedFieldID = nil
                                        selectedTime = Date()
                                        print("macOS: Time picker dismissed for field ID \(fieldID)")
                                    }
                                    .padding()
                                }
                                .padding()
                                .onAppear {
                                    print("Time picker presented for field ID \(fieldID)")
                                }
                                .onDisappear {
                                    print("Time picker dismissed")
                                    showTimePicker = false
                                    selectedFieldID = nil
                                    selectedTime = Date()
                                }
                            } else {
                                Text("Error: Unable to load time picker. Please try again.")
                                    .foregroundColor(.red)
                                    .padding()
                                    .onAppear {
                                        print("Error: selectedFieldID \(selectedFieldID?.uuidString ?? "nil") not found in Placeholder for time picker")
                                    }
                            }
                        }
                        #endif
                    }
                }
            }
            .padding()
            .frame(width: width)
            .background(
                textFieldBackground.cornerRadius(25)
            )
            .padding(.horizontal, 20)
            .onChange(of: focusedFieldID) { newValue in
                if newValue != selectedFieldID && (showDatePicker || showTimePicker) {
                    showDatePicker = false
                    showTimePicker = false
                    selectedFieldID = nil
                    print("Focus changed to field ID: \(newValue?.uuidString ?? "nil"), pickers dismissed")
                }
            }
            .onChange(of: selectedFieldID) { newValue in
                print("selectedFieldID changed to: \(newValue?.uuidString ?? "nil") at \(Date())")
            }
        }
    }

    private func dateFromString(_ string: String, isDate: Bool) -> Date? {
        let formatter = DateFormatter()
        if isDate {
            if string.contains("|") {
                let datePart = string.split(separator: "|").first?.trimmingCharacters(in: .whitespaces) ?? ""
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.date(from: datePart)
            } else {
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.date(from: string)
            }
        } else {
            if string.contains("|") {
                let timePart = string.split(separator: "|").last?.trimmingCharacters(in: .whitespaces) ?? ""
                formatter.dateFormat = "h:mm a"
                return formatter.date(from: timePart)
            } else {
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return formatter.date(from: string)
            }
        }
    }
    public var textFieldBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.75, green: 0.75, blue: 0.75, opacity: 0.2),
                          Color(red: 0.75, green: 0.75, blue: 0.75, opacity: 0.3),
                          Color(red: 0.75, green: 0.75, blue: 0.75, opacity: 0.4)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

import SwiftUI

public struct RIBTSingleField: View {
    @Binding var item: TField
    @FocusState private var isFocused: Bool
    let height: CGFloat
    public var width: CGFloat? = nil
    private let defaultWidth: CGFloat = 300
    @Environment(\.colorScheme) var colorScheme
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var isPasswordVisible = false
    @State private var validationMessage: String?
    @State private var itemValue = ""
    
    public var floatingYOffset: CGFloat {
        height >= 100 ? -height / 2 + 2 : -35
    }
    
    public var maskYOffset: CGFloat {
        height >= 100 ? -height / 2 + 2 : -26
    }
    
    public var placeholderRestingYOffset: CGFloat {
        switch height {
        case 0..<60:
            return 0
        case 60..<100:
            return -20
        default:
            return -height * 0.3
        }
    }
    
    public var floatingLabelOffset: CGFloat {
        switch height {
        case 0..<60:
            return -10
        case 60..<100:
            return -18
        default:
            return -height * 0
        }
    }
    
    public var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if showDatePicker || showTimePicker {
                        showDatePicker = false
                        showTimePicker = false
                        print("Background tapped, pickers dismissed for field \(item.label)")
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                ZStack(alignment: .leading) {
                    Group {
                        if height >= 100 {
                            TextEditor(text: item.value)
                                .focused($isFocused)
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(height: height)
                                .frame(width: item.width ?? width ?? defaultWidth)
                                .foregroundColor(Color.silverGray)
                                .background(textFieldBackground)
                                .cornerRadius(30)
                                .padding(.horizontal, 20)
                        } else {
                            HStack {
                                if item.fieldType == .secure {
                                    Group {
                                        if isPasswordVisible {
                                            TextField(
                                                "",
                                                text: Binding(
                                                    get: { item.value.wrappedValue },
                                                    set: { newValue in
                                                        item.value.wrappedValue = newValue
                                                        validateInput(newValue)
                                                    }
                                                )
                                            )
                                        } else {
                                            SecureField(
                                                "",
                                                text: Binding(
                                                    get: { item.value.wrappedValue },
                                                    set: { newValue in
                                                        item.value.wrappedValue = newValue
                                                        validateInput(newValue)
                                                    }
                                                )
                                            )
                                        }
                                    }
                                    .foregroundColor(Color.silverGray)
                                    .textFieldStyle(.plain)
                                    .padding(.vertical, 12)
                                    .padding(.leading, 16)
                                    .focused($isFocused)
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(
                                            systemName: isPasswordVisible
                                                ? "eye" : "eye.slash"
                                        )
                                        .foregroundColor(Color.silverGray.opacity(0.7))
                                        .padding(.trailing, 16)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    TextField(
                                        "",
                                        text: item.value,
                                        onEditingChanged: { editing in
                                            withAnimation(.spring()) {
                                                isFocused = editing
                                            }
                                        }
                                    )
                                    .foregroundColor(Color.silverGray)
                                    .textFieldStyle(.plain)
                                    .padding(.vertical, 12)
                                    .padding(.leading, 16)
                                    .disabled(item.fieldType != .text)
                                    .focused($isFocused)
                                    if item.fieldType == .date || item.fieldType == .dateAndTime {
                                        Button {
                                            showDatePicker.toggle()
                                            showTimePicker = false
                                            isFocused = false
                                            selectedDate = item.value.wrappedValue.isEmpty
                                                ? Date()
                                                : dateFromString(item.value.wrappedValue, isDate: true) ?? Date()
                                            if item.fieldType == .dateAndTime {
                                                selectedTime = item.value.wrappedValue.isEmpty
                                                    ? Date()
                                                    : dateFromString(item.value.wrappedValue, isDate: false) ?? Date()
                                            }
                                            print("Date picker toggled for field \(item.label)")
                                        } label: {
                                            Text("📅")
                                                .font(.system(size: 22))
                                                .padding(.trailing, 16)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else if item.fieldType == .time {
                                        Button {
                                            showTimePicker.toggle()
                                            showDatePicker = false
                                            isFocused = false
                                            selectedTime = item.value.wrappedValue.isEmpty
                                                ? Date()
                                                : dateFromString(item.value.wrappedValue, isDate: false) ?? Date()
                                            print("Time picker toggled for field \(item.label)")
                                        } label: {
                                            Text("🕒")
                                                .font(.system(size: 22))
                                                .padding(.trailing, 16)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .frame(height: height)
                            .frame(width: item.width ?? width ?? defaultWidth)
                            .background(textFieldBackground)
                            .cornerRadius(30)
                            .padding(.horizontal, 20)
                        }
                    }
                    .mask(
                        GeometryReader { _ in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                if isFocused || !item.value.wrappedValue.isEmpty {
                                    Text(item.label)
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)
                                        .background(
                                            GeometryReader { textGeometry in
                                                RoundedRectangle(cornerRadius: 10)
                                                    .frame(
                                                        width: textGeometry.size.width,
                                                        height: textGeometry.size.height
                                                    )
                                                    .offset(x: 46, y: maskYOffset)
                                                    .blendMode(.destinationOut)
                                            }
                                        )
                                }
                            }
                        }
                    )
                    .onChange(of: item.value.wrappedValue) { _ in
                        withAnimation(.spring()) {
                            // no special action needed here
                        }
                    }
                    .onChange(of: isFocused) { newValue in
                        withAnimation(.spring()) {
                            if newValue && (showDatePicker || showTimePicker) {
                                showDatePicker = false
                                showTimePicker = false
                                print("Text field focused, pickers dismissed for field \(item.label)")
                            }
                        }
                    }
                    
                    if isFocused || !item.value.wrappedValue.isEmpty {
                        Text(item.label)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.silverGray.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.top, height >= 100 ? 0 : 20)
                            .background(Color.clear)
                            .padding(.leading, 43)
                            .offset(y: floatingYOffset)
                            .transition(.opacity.combined(with: .offset(y: -10)))
                    } else {
                        Text(item.label)
                            .font(.system(size: 16))
                            .foregroundColor(Color.silverGray.opacity(0.7))
                            .padding(.horizontal, 8)
                            .background(Color.clear)
                            .offset(x: 35, y: placeholderRestingYOffset)
                            .transition(.opacity.combined(with: .offset(y: 0)))
                    }
                }
                .padding()

                // Inline Date Picker for iOS
                if showDatePicker {
                    #if os(iOS)
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { selectedDate },
                            set: { newDate in
                                selectedDate = newDate
                                let formatter = DateFormatter()
                                formatter.dateStyle = .medium
                                formatter.timeStyle = .none
                                item.value.wrappedValue = formatter.string(from: newDate)
                                print("Updated field \(item.label) to \(formatter.string(from: newDate))")
                                if item.fieldType == .dateAndTime {
                                    showDatePicker = false
                                    showTimePicker = true
                                }
                            }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .frame(height: 200)
                    #elseif os(macOS)
                    VStack(spacing: 20) {
                        DatePickerView(
                            selectedDate: Binding(
                                get: { selectedDate },
                                set: { newDate in
                                    selectedDate = newDate
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .medium
                                    formatter.timeStyle = .none
                                    item.value.wrappedValue = formatter.string(from: newDate)
                                    print("macOS: Updated field \(item.label) to \(formatter.string(from: newDate))")
                                }
                            ),
                            item: $item
                        )
                        
                        Button(item.fieldType == .date ? "Done" : "Next") {
                            if item.fieldType == .date {
                                showDatePicker = false
                                selectedDate = Date()
                            } else {
                                showDatePicker = false
                                showTimePicker = true
                            }
                            print("macOS: Date picker dismissed for field \(item.label)")
                        }
                        .padding()
                    }
                    .padding()
                    .onDisappear {
                        showDatePicker = false
                        selectedDate = Date()
                    }
                    #endif
                }

                // Inline Time Picker for iOS
                if showTimePicker {
                    #if os(iOS)
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { selectedTime },
                            set: { newTime in
                                selectedTime = newTime
                                let formatter = DateFormatter()
                                formatter.dateStyle = .none
                                formatter.timeStyle = .short
                                if item.fieldType == .time {
                                    item.value.wrappedValue = formatter.string(from: newTime)
                                    print("Updated time for field \(item.label) to \(formatter.string(from: newTime))")
                                } else if item.fieldType == .dateAndTime {
                                    let calendar = Calendar.current
                                    let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                                    let timeComponents = calendar.dateComponents([.hour, .minute], from: newTime)
                                    var combinedComponents = DateComponents()
                                    combinedComponents.year = dateComponents.year
                                    combinedComponents.month = dateComponents.month
                                    combinedComponents.day = dateComponents.day
                                    combinedComponents.hour = timeComponents.hour
                                    combinedComponents.minute = timeComponents.minute
                                    if let combinedDate = calendar.date(from: combinedComponents) {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "MMM d, yyyy"
                                        let timeFormatter = DateFormatter()
                                        timeFormatter.dateFormat = "h:mm a"
                                        let combinedString = "\(dateFormatter.string(from: combinedDate)) | \(timeFormatter.string(from: combinedDate))"
                                        item.value.wrappedValue = combinedString
                                        print("Updated date and time for field \(item.label) to \(combinedString)")
                                    }
                                }
                            }
                        ),
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .padding()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding()
                    #elseif os(macOS)
                    VStack(spacing: 20) {
                        DatePicker(
                            "Select Time",
                            selection: Binding(
                                get: { selectedTime },
                                set: { newTime in
                                    selectedTime = newTime
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .none
                                    formatter.timeStyle = .short
                                    if item.fieldType == .time {
                                        item.value.wrappedValue = formatter.string(from: newTime)
                                        print("macOS: Updated time for field \(item.label) to \(formatter.string(from: newTime))")
                                    } else if item.fieldType == .dateAndTime {
                                        let calendar = Calendar.current
                                        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                                        let timeComponents = calendar.dateComponents([.hour, .minute], from: newTime)
                                        var combinedComponents = DateComponents()
                                        combinedComponents.year = dateComponents.year
                                        combinedComponents.month = dateComponents.month
                                        combinedComponents.day = dateComponents.day
                                        combinedComponents.hour = timeComponents.hour
                                        combinedComponents.minute = timeComponents.minute
                                        if let combinedDate = calendar.date(from: combinedComponents) {
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "MMM d, yyyy"
                                            let timeFormatter = DateFormatter()
                                            timeFormatter.dateFormat = "h:mm a"
                                            let combinedString = "\(dateFormatter.string(from: combinedDate)) | \(timeFormatter.string(from: combinedDate))"
                                            item.value.wrappedValue = combinedString
                                            print("macOS: Updated date and time for field \(item.label) to \(combinedString)")
                                        }
                                    }
                                }
                            ),
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        
                        Button("Done") {
                            showTimePicker = false
                            selectedTime = Date()
                            print("macOS: Time picker dismissed for field \(item.label)")
                        }
                        .padding()
                    }
                    .padding()
                    .onDisappear {
                        showTimePicker = false
                        selectedTime = Date()
                    }
                    #endif
                }

                if item.fieldType == .secure, let message = validationMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                }
            }
            .compositingGroup()
            .frame(width: item.width ?? width ?? defaultWidth)
            .padding()
        }
    }
    
    private func dateFromString(_ string: String, isDate: Bool) -> Date? {
        let formatter = DateFormatter()
        if isDate {
            if string.contains("|") {
                let datePart = string.split(separator: "|").first?.trimmingCharacters(in: .whitespaces) ?? ""
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.date(from: datePart)
            } else {
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.date(from: string)
            }
        } else {
            if string.contains("|") {
                let timePart = string.split(separator: "|").last?.trimmingCharacters(in: .whitespaces) ?? ""
                formatter.dateFormat = "h:mm a"
                return formatter.date(from: timePart)
            } else {
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return formatter.date(from: string)
            }
        }
    }
    
    public var textFieldBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.75, green: 0.75, blue: 0.75, opacity: 0.2),
                Color(red: 0.75, green: 0.75, blue: 0.75, opacity: 0.3),
                Color(red: 0.75, green: 0.75, blue: 0.75, opacity: 0.4)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    public func validateInput(_ text: String) {
        if text.count < 8 {
            validationMessage = "Password must be at least 8 characters"
        } else {
            validationMessage = nil
        }
    }
}

// MARK: - DATE PICKER VIEW
struct DatePickerView: View {
    @Binding var selectedDate: Date
    @State private var currentDate: Date
    @State private var selectedPart: DatePart = .day
    @Binding var item: TField
    private let calendar = Calendar.current
    
    private let daysOfWeek: [(id: String, name: String)] = [
        ("Sun", "S"), ("Mon", "M"), ("Tue", "T"), ("Wed", "W"),
        ("Thu", "T"), ("Fri", "F"), ("Sat", "S")
    ]
    
    private struct CalendarDay: Identifiable {
        let id: String
        let value: Int
    }
    
    enum DatePart {
        case day, month, year
    }
    
    private var dateComponents: (day: String, month: String, year: String) {
        let components = calendar.dateComponents([.day, .month, .year], from: selectedDate)
        let day = String(format: "%02d", components.day ?? 1)
        let month = String(format: "%02d", components.month ?? 1)
        let year = String(format: "%04d", components.year ?? 2025)
        return (day, month, year)
    }
    
    init(selectedDate: Binding<Date>, item: Binding<TField>) {
        self._selectedDate = selectedDate
        self._item = item
        let initialDate = selectedDate.wrappedValue
        if calendar.dateComponents([.year, .month, .day], from: initialDate).year == nil {
            print("Invalid initial date, falling back to current date")
            self._currentDate = State(initialValue: Date())
        } else {
            self._currentDate = State(initialValue: initialDate)
        }
    }
    
    var body: some View {
        if calendar.dateComponents([.year, .month, .day], from: selectedDate).year == nil {
            Text("Invalid date selected. Please try again.")
                .padding()
        } else {
            VStack(spacing: 20) {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(dateComponents.day)
                           // .font(.system(size: 14))
                            .padding(.horizontal, 2)
                            .background(selectedPart == .day ? Color.blue.opacity(0.3) : Color.clear)
                            .onTapGesture {
                                selectedPart = .day
                            }
                        
                        Text("/")
                            .font(.system(size: 14))
                        
                        Text(dateComponents.month)
                            .font(.system(size: 14))
                            .padding(.horizontal, 2)
                            .background(selectedPart == .month ? Color.blue.opacity(0.3) : Color.clear)
                            .onTapGesture {
                                selectedPart = .month
                            }
                        
                        Text("/")
                            .font(.system(size: 14))
                        
                        Text(dateComponents.year)
                            .font(.system(size: 14))
                            .padding(.horizontal, 2)
                            .background(selectedPart == .year ? Color.blue.opacity(0.3) : Color.clear)
                            .onTapGesture {
                                selectedPart = .year
                            }
                    }
                    .frame(width: 100, height: 30)
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            incrementSelectedPart()
                            currentDate = selectedDate
                        }) {
                            Image(systemName: "chevron.up")
                                .foregroundColor(.blue)
                                .frame(width: 20, height: 15)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Increment \(selectedPart)")
                        
                        Button(action: {
                            decrementSelectedPart()
                            currentDate = selectedDate
                        }) {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.blue)
                                .frame(width: 20, height: 15)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel("Decrement \(selectedPart)")
                    }
                    .padding(.trailing, 5)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                )
                
                VStack(spacing: 10) {
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text(monthYearString)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        ForEach(daysOfWeek, id: \.id) { day in
                            Text(day.name)
                                .font(.caption)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    let days = generateDaysInMonth()
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
                    
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(days) { day in
                            if day.value != 0 {
                                Text("\(day.value)")
                                    .font(.system(size: 14))
                                    .frame(width: 30, height: 30)
                                    .background(
                                        isSelected(day: day.value) ?
                                        AnyView(Circle().fill(Color.blue)) :
                                        AnyView(Color.clear)
                                    )
                                    .foregroundColor(
                                        isSelected(day: day.value) ? .white :
                                        (isCurrentMonth(day: day.value) ? .primary : .secondary)
                                    )
                                    .onTapGesture {
                                        selectDay(day.value)
                                    }
                            } else {
                                Text("")
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .frame(minWidth: 200, maxWidth: 250, minHeight: 350, maxHeight: 350)
            .onAppear {
                print("DatePickerView appeared with selectedDate: \(selectedDate) for field \(item.label)")
                currentDate = selectedDate
            }
            .onChange(of: selectedDate) { newDate in
                print("selectedDate changed to: \(newDate) for field \(item.label)")
                let selectedComponents = calendar.dateComponents([.year, .month], from: newDate)
                let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
                if selectedComponents.year != currentComponents.year || selectedComponents.month != currentComponents.month {
                    currentDate = newDate
                }
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                item.value.wrappedValue = formatter.string(from: newDate)
            }
        }
    }
    
    private func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        syncSelectedDateToCurrentMonth()
    }
    
    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        syncSelectedDateToCurrentMonth()
    }
    
    private func syncSelectedDateToCurrentMonth() {
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        let selectedComponents = calendar.dateComponents([.day], from: selectedDate)
        
        var newComponents = DateComponents()
        newComponents.year = currentComponents.year
        newComponents.month = currentComponents.month
        newComponents.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: newComponents) else { return }
        guard let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else { return }
        let maxDays = range.count
        
        let selectedDay = selectedComponents.day ?? 1
        newComponents.day = min(selectedDay, maxDays)
        
        if let newDate = calendar.date(from: newComponents) {
            selectedDate = newDate
        }
    }
    
    private func daysInMonth() -> Int {
        let components = DateComponents(
            year: calendar.component(.year, from: currentDate),
            month: calendar.component(.month, from: currentDate)
        )
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return 31
        }
        return range.count
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private func generateDaysInMonth() -> [CalendarDay] {
        let components = DateComponents(
            year: calendar.component(.year, from: currentDate),
            month: calendar.component(.month, from: currentDate)
        )
        
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = firstWeekday - calendar.firstWeekday
        let adjustedOffset = offset < 0 ? offset + 7 : offset
        
        var days: [CalendarDay] = []
        for i in 0..<adjustedOffset {
            days.append(CalendarDay(id: "placeholder-\(i)", value: 0))
        }
        for day in 1...range.count {
            days.append(CalendarDay(id: "day-\(day)", value: day))
        }
        
        return days
    }
    
    private func isCurrentMonth(day: Int) -> Bool {
        let components = DateComponents(
            year: calendar.component(.year, from: currentDate),
            month: calendar.component(.month, from: currentDate),
            day: day
        )
        guard let date = calendar.date(from: components) else { return false }
        return calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
    }
    
    private func isSelected(day: Int) -> Bool {
        let components = DateComponents(
            year: calendar.component(.year, from: currentDate),
            month: calendar.component(.month, from: currentDate),
            day: day
        )
        guard let date = calendar.date(from: components) else { return false }
        
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let gridComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        return selectedComponents.year == gridComponents.year &&
               selectedComponents.month == gridComponents.month &&
               selectedComponents.day == gridComponents.day
    }
    
    private func selectDay(_ day: Int) {
        let components = DateComponents(
            year: calendar.component(.year, from: currentDate),
            month: calendar.component(.month, from: currentDate),
            day: day
        )
        if let newDate = calendar.date(from: components) {
            selectedDate = newDate
            currentDate = newDate
        }
    }
    
    private func incrementSelectedPart() {
        switch selectedPart {
        case .day:
            let newDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            selectedDate = newDate
        case .month:
            let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
            selectedDate = newDate
        case .year:
            let newDate = calendar.date(byAdding: .year, value: 1, to: selectedDate) ?? selectedDate
            selectedDate = newDate
        }
    }
    
    private func decrementSelectedPart() {
        switch selectedPart {
        case .day:
            let newDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            selectedDate = newDate
        case .month:
            let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
            selectedDate = newDate
        case .year:
            let newDate = calendar.date(byAdding: .year, value: -1, to: selectedDate) ?? selectedDate
            selectedDate = newDate
        }
    }
}
#endif
