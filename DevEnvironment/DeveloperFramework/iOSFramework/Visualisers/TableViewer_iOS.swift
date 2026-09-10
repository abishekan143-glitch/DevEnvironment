//#if os(iOS)
#if os(iOS)
import Foundation
import SwiftUI

public struct SmartTable: View {
    var db: Any
    let tablename: String
    let query: String
    let headerNameMap: [String: String]
    let pageSize: Int = 5
    let headersOrder: [[String]]?
    @State private var isMinimized = false
    @State private var headers: [String] = []
    @State private var data: [[String]] = []
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var pinnedColumns: Set<Int> = []
    @State private var currentPage: Int = 0
    @State private var filteredColumns: Set<Int> = Set()
    @State private var isFilterDialogOpen: Bool = false
    @State private var pageSearchText: String = ""
    @State private var searchText: String = ""
    @State private var currentHeadersOrder: [String] = []
    
    public let baseColumnWidth: CGFloat = 100
    
    public var paginatedData: [[String]] {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, data.count)
        return Array(data[startIndex..<endIndex])
    }
    
    public var totalPages: Int {
        return max(1, (data.count + pageSize - 1) / pageSize)
    }
    
    public var filteredHeaders: [String] {
        filteredColumns.isEmpty ? headers.map { headerNameMap[$0] ?? $0 } : headers.enumerated().filter { filteredColumns.contains($0.offset) }.map { headerNameMap[$0.element] ?? $0.element }
    }
    
    public var displayedData: [[String]] {
        if filteredColumns.isEmpty {
            return paginatedData
        } else {
            return paginatedData.map { row in
                row.enumerated().filter { filteredColumns.contains($0.offset) }.map { $0.element }
            }
        }
    }
    
    public func calculateColumnWidth(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 17)
        let padding: CGFloat = 20
        return max(baseColumnWidth, text.widthOfString(usingFont: font) + padding)
    }
    
    public func calculateHeaderFontSize(for text: String) -> CGFloat {
        let baseFontSize: CGFloat = 17
        let minFontSize: CGFloat = 12
        let idealWidthRatio: CGFloat = 0.8
        let padding: CGFloat = 16
        
        let availableWidth = baseColumnWidth - padding
        let targetWidth = availableWidth * idealWidthRatio
        
        let systemFont = UIFont.systemFont(ofSize: baseFontSize)
        let attributes = [NSAttributedString.Key.font: systemFont]
        let textSize = text.size(withAttributes: attributes)
        
        if textSize.width <= targetWidth {
            return baseFontSize
        }
        
        let scaleFactor = targetWidth / textSize.width
        let scaledSize = baseFontSize * scaleFactor
        return max(minFontSize, min(baseFontSize, scaledSize))
    }
    
    public func sortHeadersAndData() {
        guard let headersOrder = headersOrder else { return }
        
        if let matchingOrder = headersOrder.first(where: { order in
            Set(headers).isSubset(of: Set(order))
        }) {
            let filteredOrder = matchingOrder.filter { headers.contains($0) }
            let newIndices = filteredOrder.compactMap { headers.firstIndex(of: $0) }
            
            headers = newIndices.map { headers[$0] }
            data = data.map { row in
                newIndices.map { row[$0] }
            }
            
            if !filteredColumns.isEmpty {
                let newFilteredIndices = newIndices.enumerated().compactMap { (newIndex, originalIndex) in
                    filteredColumns.contains(originalIndex) ? newIndex : nil
                }
                filteredColumns = Set(newFilteredIndices)
            }
            
            if !pinnedColumns.isEmpty {
                let newPinnedIndices = newIndices.enumerated().compactMap { (newIndex, originalIndex) in
                    pinnedColumns.contains(originalIndex) ? newIndex : nil
                }
                pinnedColumns = Set(newPinnedIndices)
            }
            
            currentHeadersOrder = filteredOrder
        }
    }
    
    public func fetchDataFromDatabase() {
        DispatchQueue.global(qos: .userInitiated).async {
            var result: [[String: String]]?
            if let DatabaseCon = db as? DatabaseConnectionEstablisher {
                result = DatabaseConnectionEstablisher().executeQuery(query).1
            } else if let DevOpsCon = db as? DevOpsConnectionEstablisher {
                result = DevOpsConnectionEstablisher().executeQuery(query).1
            } else if let DeviceFingerprintCon = db as? DeviceFingerprintConnectionEstablisher {
                result = DeviceFingerprintConnectionEstablisher().executeQuery(query).1
            }
            
            if let dictRows = result, !dictRows.isEmpty {
                var columns: [String] = []
                if let firstRow = dictRows.first, !firstRow.keys.isEmpty {
                    columns = Array(firstRow.keys)
                } else {
                    print("Failed to fetch column names from the database")
                }
                
                let rows: [[String]] = dictRows.map { rowDict in
                    columns.map { rowDict[$0] ?? "" }
                }
                DispatchQueue.main.async {
                    self.headers = columns
                    self.data = rows
                    self.sortHeadersAndData()
                }
            } else {
                DispatchQueue.main.async {
                    self.headers = []
                    self.data = []
                }
            }
        }
    }
    
    public init(db: Any, tablename: String, query: String = "SELECT * FROM ",
                headerNameMap: [String: String] = [:], headersOrder: [[String]]? = nil) {
        self.db = db
        self.tablename = tablename
        self.query = query + tablename
        self.headerNameMap = headerNameMap
        self.headersOrder = headersOrder
    }
    
    public init(headers: [String], data: [[String]], headerNameMap: [String: String] = [:],
                headersOrder: [[String]]? = nil) {
        self.db = NSNull()
        self.tablename = ""
        self.query = ""
        self.headerNameMap = headerNameMap
        self.headersOrder = headersOrder
        _headers = State(initialValue: headers)
        _data = State(initialValue: data)
        _currentHeadersOrder = State(initialValue: headers)
        
        let _ = sortHeadersAndData()
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            SearchBar(hint: "Search...", text: $searchText)
                .padding(.horizontal)
                .padding(.top, -60)
            
            ZStack(alignment: .topLeading) {
                if isMinimized {
                    MinimizedTableView(
                        headers: filteredHeaders,
                        data: displayedData,
                        isMinimized: $isMinimized,
                        columnWidth: baseColumnWidth,
                        searchText: searchText
                    )
                    .transition(.opacity.combined(with: .scale))
                } else {
                    CoverFlowTable(
                        headers: filteredHeaders,
                        data: displayedData,
                        pinnedColumns: $pinnedColumns,
                        isMinimized: $isMinimized,
                        columnWidth: baseColumnWidth,
                        searchText: searchText,
                        fontSizeCalculator: calculateHeaderFontSize
                    )
                    .frame(height: 400)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isMinimized)
            
            HStack {
                Button(action: {
                    isFilterDialogOpen = true
                }) {
                    Text("Filter Columns")
                        .bold()
                        .padding()
                        .frame(height: 40)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.mustardYellow, .amberYellow]),
                                startPoint: .top,
                                endPoint: .bottom
                            ).opacity(0.8)
                            .ignoresSafeArea()
                        )
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                TextField("Go to Page", text: $pageSearchText)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 8)
                    .frame(width: 100, height: 40)
                    .background(Color.silverGray.opacity(0.3))
                    .cornerRadius(8)
                    .onChange(of: pageSearchText) { newValue in
                        if let pageNumber = Int(newValue) {
                            if pageNumber < 1 {
                                currentPage = 0
                            } else if pageNumber > totalPages {
                                currentPage = totalPages - 1
                            } else {
                                currentPage = pageNumber - 1
                            }
                        }
                    }
            }
            .padding(.horizontal)
            
            HStack(spacing: 10) {
                Button(action: { currentPage = 0 }) {
                    Image(systemName: "chevron.left.2")
                        .padding(10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.mustardYellow, .amberYellow]),
                                startPoint: .top,
                                endPoint: .bottom
                            ).opacity(0.8)
                            .ignoresSafeArea()
                        )
                        .foregroundColor(.black)
                        .cornerRadius(5)
                        .shadow(radius: 2)
                }
                .disabled(currentPage == 0)
                
                Button(action: {
                    if currentPage > 0 { currentPage -= 1 }
                }) {
                    Image(systemName: "chevron.left")
                        .padding(10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.mustardYellow, .amberYellow]),
                                startPoint: .top,
                                endPoint: .bottom
                            ).opacity(0.8)
                            .ignoresSafeArea()
                        )
                        .foregroundColor(.black)
                        .cornerRadius(5)
                        .shadow(radius: 2)
                }
                .disabled(currentPage == 0)
                
                Text("Page \(currentPage + 1) of \(totalPages)")
                    .font(.headline)
                    .foregroundColor(.white) // Single color for both modes
                
                Button(action: {
                    if currentPage < totalPages - 1 { currentPage += 1 }
                }) {
                    Image(systemName: "chevron.right")
                        .padding(10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.mustardYellow, .amberYellow]),
                                startPoint: .top,
                                endPoint: .bottom
                            ).opacity(0.8)
                            .ignoresSafeArea()
                        )
                        .foregroundColor(.black)
                        .cornerRadius(5)
                        .shadow(radius: 2)
                }
                .disabled(currentPage >= totalPages - 1)
                
                Button(action: { currentPage = totalPages - 1 }) {
                    Image(systemName: "chevron.right.2")
                        .padding(10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.mustardYellow, .amberYellow]),
                                startPoint: .top,
                                endPoint: .bottom
                            ).opacity(0.8)
                            .ignoresSafeArea()
                        )
                        .foregroundColor(.black)
                        .cornerRadius(5)
                        .shadow(radius: 2)
                }
                .disabled(currentPage >= totalPages - 1)
            }
            .padding()
        }
        .padding()
        .onAppear {
            if !(db is NSNull) {
                fetchDataFromDatabase()
            }
        }
        .fullScreenCover(isPresented: $isFilterDialogOpen) {
            FilterDialog(
                headers: headers.map { headerNameMap[$0] ?? $0 },
                filteredColumns: $filteredColumns,
                isFilterDialogOpen: $isFilterDialogOpen
            )
        }
    }
}

// MARK: - String Extension
public extension String {
    subscript(range: String) -> String {
        let lowercasedSelf = self.lowercased()
        let lowercasedRange = range.lowercased()
        
        if let rangeStart = lowercasedSelf.range(of: lowercasedRange) {
            let startIndex = self.index(self.startIndex, offsetBy: self.distance(from: self.startIndex, to: rangeStart.lowerBound))
            let endIndex = self.index(startIndex, offsetBy: range.count)
            return String(self[startIndex..<endIndex])
        }
        return ""
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: attributes)
        return size.width
    }
}

// MARK: - SearchBar
public struct SearchBar: View {
    let hint: String
    @Binding var text: String
    
    public var body: some View {
        HStack {
            TextField(hint, text: $text)
                .padding(10)
                .background(Color.silverGray.opacity(0.3))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white) // Single color for both modes
                                    .padding(8)
                            }
                        }
                    }
                )
        }
    }
}

// MARK: - FilterDialog
public struct FilterDialog: View {
    let headers: [String]
    @Binding var filteredColumns: Set<Int>
    @Binding var isFilterDialogOpen: Bool
    
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.dimGray, .ebonyGray]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.7)
            .ignoresSafeArea()
            
            VStack {
                Text("Filter Columns")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white) // Single color for both modes
                
                ScrollView {
                    VStack(spacing: 2) {
                        Button(action: {
                            filteredColumns = Set()
                        }) {
                            HStack {
                                Text("All Columns")
                                    .bold()
                                    .foregroundColor(.white) // Single color for both modes
                                Spacer()
                                if filteredColumns.isEmpty {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.mustardYellow)
                                }
                            }
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        ForEach(headers.indices, id: \.self) { index in
                            HStack {
                                Text(headers[index])
                                    .foregroundColor(.white) // Single color for both modes
                                Spacer()
                                if filteredColumns.contains(index) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.mustardYellow)
                                }
                            }
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                if filteredColumns.contains(index) {
                                    filteredColumns.remove(index)
                                } else {
                                    filteredColumns.insert(index)
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Button(action: {
                        isFilterDialogOpen = false
                    }) {
                        Text("Cancel")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.dimGray, .jetGray]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .foregroundColor(.mustardYellow)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isFilterDialogOpen = false
                    }) {
                        Text("Apply")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.mustardYellow, .amberYellow]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ).opacity(0.8)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .padding()
        }
        .cornerRadius(12)
    }
}

// MARK: - MinimizedTableView
public struct MinimizedTableView: View {
    let headers: [String]
    let data: [[String]]
    @Binding var isMinimized: Bool
    let columnWidth: CGFloat
    let searchText: String
    
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(Array(headers.enumerated()), id: \.offset) { index, header in
                            Text(header)
                                .font(.system(size: 10))
                                .bold()
                                .frame(width: 100, height: 20)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.mustardYellow, .amberYellow]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ).opacity(0.8)
                                    .ignoresSafeArea()
                                )
                                .foregroundColor(.black)
                                .border(Color.gray.opacity(0.5))
                                .multilineTextAlignment(.center)
                                .onLongPressGesture {
                                    withAnimation(.spring()) {
                                        isMinimized.toggle()
                                    }
                                }
                        }
                    }
                    
                    ForEach(data, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(Array(row.enumerated()), id: \.offset) { index, cell in
                                HighlightedText(text: cell, searchText: searchText)
                                    .font(.system(size: 10))
                                    .frame(width: 100, height: 20)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.slateGray, .jetGray]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ).opacity(0.6)
                                    )
                                    .border(Color.gray.opacity(0.2))
                                    .foregroundColor(.white) // Single color for both modes
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
                .frame(width: CGFloat(headers.count) * columnWidth)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .scaleEffect(currentScale * gestureZoomScale)
            .offset(
                x: currentOffset.width + gestureOffset.width,
                y: currentOffset.height + gestureOffset.height
            )
            .clipped()
            .gesture(
                MagnificationGesture()
                    .updating($gestureZoomScale) { value, state, _ in
                        state = value
                    }
                    .onEnded { value in
                        let newScale = currentScale * value
                        currentScale = min(max(newScale, 1.0), 5.0)
                    }
            )
            .gesture(
                DragGesture()
                    .updating($gestureOffset) { value, state, _ in
                        let maxX = (geometry.size.width * (currentScale - 1)) / 2
                        let maxY = (geometry.size.height * (currentScale - 1)) / 2
                        state = CGSize(
                            width: min(max(value.translation.width, -maxX), maxX),
                            height: min(max(value.translation.height, -maxY), maxY)
                        )
                    }
                    .onEnded { value in
                        let maxX = (geometry.size.width * (currentScale - 1)) / 2
                        let maxY = (geometry.size.height * (currentScale - 1)) / 2
                        currentOffset.width = min(max(currentOffset.width + value.translation.width, -maxX), maxX)
                        currentOffset.height = min(max(currentOffset.height + value.translation.height, -maxY), maxY)
                    }
            )
        }
        .frame(height: 400)
        .clipped()
    }
}

// MARK: - CoverFlowTable
public struct CoverFlowTable: View {
    let headers: [String]
    let data: [[String]]
    @Binding var pinnedColumns: Set<Int>
    @Binding var isMinimized: Bool
    let columnWidth: CGFloat
    let searchText: String
    let fontSizeCalculator: (String) -> CGFloat
    
    private let pinnedColumnSpacing: CGFloat = 6
    
    private func maxColumnHeight() -> CGFloat {
        let maxDataCount = data.map { $0.count }.max() ?? 0
        let headerHeight: CGFloat = 44
        let cellHeight: CGFloat = 44
        let footerHeight: CGFloat = 44
        return headerHeight + (CGFloat(maxDataCount) * cellHeight) + footerHeight
    }
    
    private func calculateWidth(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 17)
        let padding: CGFloat = 20
        return text.widthOfString(usingFont: font) + padding
    }
    
    public var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(Array(pinnedColumns), id: \.self) { index in
                    ColumnView(
                        header: headers[index],
                        data: data.map { $0[index] },
                        isPinned: true,
                        headers: headers,
                        pinnedColumns: $pinnedColumns,
                        isMinimized: $isMinimized,
                        columnWidth: max(columnWidth, calculateWidth(for: headers[index])),
                        searchText: searchText,
                        fontSizeCalculator: fontSizeCalculator
                    )
                }
                .zIndex(1)
                
                Color.clear
                    .frame(width: pinnedColumnSpacing)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(headers.indices, id: \.self) { index in
                            if !pinnedColumns.contains(index) {
                                if pinnedColumns.isEmpty {
                                    GeometryReader { colGeo in
                                        let midScreenX = geometry.size.width / 2
                                        let minX = colGeo.frame(in: .global).midX
                                        let distanceX = midScreenX - minX
                                        let angleX = Double(distanceX / midScreenX) * 45
                                        let scaleX = max(0.7, 1.0 - abs(distanceX / midScreenX) * 0.5)
                                        
                                        ColumnView(
                                            header: headers[index],
                                            data: data.map { $0[index] },
                                            isPinned: false,
                                            headers: headers,
                                            pinnedColumns: $pinnedColumns,
                                            isMinimized: $isMinimized,
                                            columnWidth: max(columnWidth, calculateWidth(for: headers[index])),
                                            searchText: searchText,
                                            fontSizeCalculator: fontSizeCalculator
                                        )
                                        .rotation3DEffect(.degrees(-angleX), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                                        .scaleEffect(scaleX)
                                        .opacity(scaleX)
                                    }
                                    .frame(width: max(columnWidth, calculateWidth(for: headers[index])))
                                } else {
                                    ColumnView(
                                        header: headers[index],
                                        data: data.map { $0[index] },
                                        isPinned: false,
                                        headers: headers,
                                        pinnedColumns: $pinnedColumns,
                                        isMinimized: $isMinimized,
                                        columnWidth: max(columnWidth, calculateWidth(for: headers[index])),
                                        searchText: searchText,
                                        fontSizeCalculator: fontSizeCalculator
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, pinnedColumns.isEmpty ? geometry.size.width / 4 : 0)
                }
            }
        }
    }
}

// MARK: - ColumnView
public struct ColumnView: View {
    let header: String
    let data: [String]
    let isPinned: Bool
    let headers: [String]
    @Binding var pinnedColumns: Set<Int>
    @Binding var isMinimized: Bool
    let columnWidth: CGFloat
    let searchText: String
    let fontSizeCalculator: (String) -> CGFloat
    
    private let headerHeight: CGFloat = 60
    private let cellHeight: CGFloat = 60
    private let footerHeight: CGFloat = 60
    
    private func calculateWidth(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 17)
        let padding: CGFloat = 20
        return text.widthOfString(usingFont: font) + padding
    }
    
    public var body: some View {
        VStack(spacing: 5) {
            Text(header)
                .font(.system(size: fontSizeCalculator(header)))
                .bold()
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: max(columnWidth, calculateWidth(for: header)),
                       height: headerHeight, alignment: .center)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.mustardYellow, .amberYellow]),
                        startPoint: .top,
                        endPoint: .bottom
                    ).opacity(0.8)
                    .ignoresSafeArea()
                )
                .foregroundColor(.black)
                .cornerRadius(10)
                .onLongPressGesture {
                    withAnimation(.spring()) {
                        isMinimized.toggle()
                    }
                }
            
            ForEach(data, id: \.self) { cell in
                HighlightedText(text: cell, searchText: searchText)
                    .padding()
                    .frame(width: max(columnWidth, calculateWidth(for: header)),
                           height: headerHeight, alignment: .center)
                    .multilineTextAlignment(.center)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.slateGray, .jetGray]),
                            startPoint: .top,
                            endPoint: .bottom
                        ).opacity(0.6)
                    )
                    .cornerRadius(5)
                    .shadow(radius: 2)
            }
            
            if !isPinned {
                Button(action: {
                    if pinnedColumns.count < 2 {
                        pinnedColumns.insert(headers.firstIndex(of: header)!)
                    }
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .frame(height: footerHeight)
                        .padding()
                        .foregroundColor(.white)
                }
            }
            
            if isPinned {
                Button(action: {
                    pinnedColumns.remove(headers.firstIndex(of: header)!)
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .frame(height: footerHeight)
                        .padding()
                        .foregroundColor(.red)
                }
            }
        }
    }
}

// MARK: - HighlightedText
public struct HighlightedText: View {
    let text: String
    let searchText: String
    
    public var body: some View {
        if searchText.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
            let lowercasedText = text.lowercased()
            let lowercasedSearchText = searchText.lowercased()
            let parts = lowercasedText.components(separatedBy: lowercasedSearchText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(parts.indices, id: \.self) { index in
                        Text(text[parts[index]])
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        if index < parts.count - 1 {
                            Text(text[searchText])
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

public extension SmartTable {
    init(headers: [String], data: [[String]], headerNameMap: [String: String] = [:]) {
        self.db = NSNull()
        self.tablename = ""
        self.query = ""
        self.headerNameMap = headerNameMap
        self.headersOrder = nil
        _headers = State(initialValue: headers)
        _data = State(initialValue: data)
        _currentHeadersOrder = State(initialValue: headers)
    }
}
#endif
