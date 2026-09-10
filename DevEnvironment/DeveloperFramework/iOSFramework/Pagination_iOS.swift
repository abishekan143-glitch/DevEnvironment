//
//  Pagination.swift
//  Search
//
//  Created by Sabinash on 02/03/25.
//
#if os(iOS)

import Foundation
import SwiftUI
import AVFoundation
import Speech

public protocol PaginationDelegate: View{
    var pnSearch: String { get set }
}

public struct Pagination<T: PaginationDelegate>: View {
    public var PageSize: Int
    public var id: String
    public var paginationData: [T]
    public var maxPageNumbersToShow: Int = 3
    @State private var items: [T] = []
    @State private var itemsDisplay: [T] = []
    @State private var a = 0
    @State private var countt = 4
    @State private var currentPage = 1
    @State private var pageSize = 4
    @State private var givenPageSize = 4
    @State private var totalPages = 1
    @State private var isRecording = false
    @State private var recognizedText = ""
    @State private var searchQuery = "" // For debounced search
    @State private var debouncedSearchQuery = "" // For delayed search filtering
    @State private var similarityResults: [String: Double] = [:]
    @State private var audioRecorder: AVAudioRecorder?
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @Environment(\.colorScheme) var colorScheme
    public let debounceInterval: TimeInterval = 0.5
    @State private var tappedIndexR1: Int? = nil
    let audioEngine = AVAudioEngine()
   
   // Timer for debounced search
   @State private var debounceTimer: Timer?
    public init(
        PageSize: Int,
        id: String,
        paginationData: [T],
        maxPageNumbersToShow: Int = 3
    ) {
        self.PageSize = PageSize
        self.id = id
        self.paginationData = paginationData
        self.maxPageNumbersToShow = maxPageNumbersToShow
    }

    public var body: some View {
       VStack {
           ZStack {
               HStack(spacing: -10) {
                   Button(action: {
                       cl("Sorry Bro, Mic ellam Production ku tha, Budget Problem")
                       if isRecording {
                           isRecording = false
                       } else {
                           isRecording = true
                       }
                   }) {
                       Image(systemName: isRecording ? "mic.fill" : "mic")
                           .font(.system(size: 30))
                           .foregroundColor(isRecording ? .red : Color.silverGray)
                           .padding(.top, 20)
                           .padding(.horizontal, 20)
                   }
                   TextField(text: $recognizedText) {
                       Text("Search..")
                           .foregroundColor(Color.silverGray)
                   }
                   .padding()
                   .foregroundColor(Color.silverGray)
                   .autocorrectionDisabled()
                   .background(
                       LinearGradient(
                           gradient: Gradient(colors: [
                               Color.black.opacity(0.10),
                               Color.black.opacity(0.2),
                               Color.black.opacity(0.3)
                           ]),
                           startPoint: .top,
                           endPoint: .bottom
                       )
                   )
                   .cornerRadius(20)
                   .frame(height: 50)
                   .padding(.horizontal, 10)
                   .overlay(
                       RoundedRectangle(cornerRadius: 20)
                           .stroke(Color.clear, lineWidth: 1)
                   )
                   .padding(.top, 20)
                   .padding(.trailing, 20)
                   .onChange(of: recognizedText) { newValue in
//                         Reset the items and pagination
                       itemsDisplay = []
                       currentPage = 1
//                         Perform the expensive similarity calculation in the background
                       DispatchQueue.global(qos: .userInitiated).async {
                           // Get similarity results
                           
                               let pnSearchList = paginationData.map { $0.pnSearch }
                               if let index = pnSearchList.firstIndex(of: newValue) {
                                   itemsDisplay.append(paginationData[index])
                                   var a = 0
                                   while a < paginationData.count {
                                      itemsDisplay.append(paginationData[a])
                                      a += 1
                                   }
                                   loadPage(page: 1)
                               } else {
                                   emptyData()
                               }
                           
                           DispatchQueue.main.async {
                               // Add items based on similarity
                               if itemsDisplay.count < givenPageSize {
                                   countt = givenPageSize - itemsDisplay.count
                                   var a = 0
                                   while a < countt {
                                       itemsDisplay.append(paginationData[a])
                                       a += 1
                                   }
                               }
                               // Handle pagination based on number of items
                               if itemsDisplay.count > givenPageSize {
                                   if itemsDisplay.count % givenPageSize == 0 {
                                       totalPages = itemsDisplay.count / givenPageSize
                                   } else {
                                       totalPages = itemsDisplay.count / givenPageSize + 1
                                       countt = givenPageSize - itemsDisplay.count % givenPageSize
                                       var a = 0
                                       while a < countt {
                                           itemsDisplay.append(paginationData[a])
                                           a += 1
                                       }
                                   }
                               } else {
                                   totalPages = 1
                               }
                               // Load the first page with the filtered items
                               loadPage(page: 1)
                           }
                       }
                   }
               }
           }
           if pageSize > 0 {
               VStack {
                   ForEach(items.indices, id: \.self) { index in
                       items[index]// Just for testing
                       if index != items.indices.last {
                           Rectangle()
                               .fill(Color.black)
                               .frame(width: UIScreen.main.bounds.width-50, height: 1)
                       }
                   }
                   HStack(spacing: 0.5) {
                       PaginationView(currentPage: $currentPage, totalPages: totalPages, onPageChange: loadPage, maxPageNumbersToShow: maxPageNumbersToShow)
                   }
                   .frame(maxWidth: .infinity)
               }
               .padding(.top, 10)
               .onAppear {
                   loadPage(page: currentPage)
//                           totalPages = paginationData.count/PageSize
               }
           }
       }
       .onAppear{
           if a == 0 {
               countt = PageSize
               pageSize = PageSize
               givenPageSize = PageSize
               totalPages = maxPageNumbersToShow
               a += 1
           }
           emptyData()
       }
   }
    public func emptyData() {
        itemsDisplay.append(contentsOf: paginationData)
        var tot = Int(itemsDisplay.count) - (PageSize * maxPageNumbersToShow)
        var a2 = 0
        if tot > 0 {
            while a2 < tot {
                itemsDisplay.removeLast()
                a2 += 1
            }
        } else if tot < 0 {
            tot *= -1
            while a2 < tot {
                itemsDisplay.append(itemsDisplay[a2])
                a2 += 1
            }
        }
    }
    public var currentItems: [T] {
        let endIndex = min(PageSize, paginationData.count)
        return Array(paginationData[0..<endIndex])
    }
    
    public func loadPage(page: Int) {
       guard page > 0 && page <= totalPages else { return }
       currentPage = page
       let startIndex = (page - 1) * pageSize
       let endIndex = min(startIndex + pageSize, itemsDisplay.count)
       items = Array(itemsDisplay[startIndex..<endIndex])
   }
}
public struct PaginationView: View {
    @Binding var currentPage: Int
    var totalPages: Int
    var onPageChange: (Int) -> Void
    var maxPageNumbersToShow: Int

    public init(
        currentPage: Binding<Int>,
        totalPages: Int,
        onPageChange: @escaping (Int) -> Void,
        maxPageNumbersToShow: Int
    ) {
        self._currentPage = currentPage
        self.totalPages = totalPages
        self.onPageChange = onPageChange
        self.maxPageNumbersToShow = maxPageNumbersToShow
    }

    public var body: some View {
        // Fixed maxPageNumbersToShow set to 3

        HStack {
            // Previous button
            Button(action: {
                if currentPage > 1 {
                    currentPage -= 1
                    onPageChange(currentPage)
                }
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundColor(currentPage > 1 ? Color.silverGray : .clear)
            }
            .disabled(currentPage == 1)

            // Page numbers
            ForEach(pageNumbersToDisplay(maxPageNumbersToShow: maxPageNumbersToShow), id: \.self) { page in
                Button(action: {
                    currentPage = page
                    onPageChange(page)
                }) {
                    Text("\(page)")
                        .padding(8)
                        .frame(width: 40)
                        .background(currentPage == page ? Color.black.opacity(0.25) : Color.clear)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .disabled(currentPage == page)
                .liquidGlass(cardWidth: 40)
            }
            // Next button
            Button(action: {
                if currentPage < totalPages {
                    currentPage += 1
                    onPageChange(currentPage)
                }
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title)
                    .foregroundColor(currentPage < totalPages ? Color.silverGray : .clear)
                
            }
            .disabled(currentPage == totalPages)
        }
        .frame(width: 201)
        .padding(.vertical)
        .liquidGlass(cardWidth: 220)
        .cornerRadius(12)
        .padding(.top, 10)
    }

    public func pageNumbersToDisplay(maxPageNumbersToShow: Int) -> [Int] {
        // If the total number of pages is less than or equal to maxPageNumbersToShow, return all pages
        if totalPages <= maxPageNumbersToShow {
            return Array(1...totalPages)
        }

        // Calculate the range of pages to show based on the current page
        let halfRange = maxPageNumbersToShow / 2
        var startPage = currentPage - halfRange
        var endPage = currentPage + halfRange

        // Ensure start and end page are within bounds
        if startPage < 1 {
            startPage = 1
            endPage = min(maxPageNumbersToShow, totalPages)
        }

        if endPage > totalPages {
            endPage = totalPages
            startPage = max(1, totalPages - maxPageNumbersToShow + 1)
        }

        return Array(startPage...endPage)
    }
}
#endif
