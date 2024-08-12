//
//  ContentUnavailableSample.swift
//  DailyPractice
//
//  Created by 山田　天星 on 2024/08/11.
//

import Combine
import Foundation
import SwiftUI

struct Contact: Identifiable {
    let id: UUID
    let name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

class ContactsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var searchText: String = ""

    var searchResults: [Contact] {
        if searchText.isEmpty {
            contacts
        } else {
            contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    init() {
        contacts = [
            Contact(name: "John Doe"),
            Contact(name: "Jane Smith"),
            Contact(name: "Alice Johnson"),
            Contact(name: "Bob Brown"),
        ]
    }
}

struct ContactsView: View {
    let contact: Contact

    var body: some View {
        VStack {
            Text(contact.name)
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("Contact Detail")
    }
}

struct ContentUnavailableSampleView: View {
    @ObservedObject private var viewModel = ContactsViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResults) { contact in
                    NavigationLink {
                        ContactsView(contact: contact)
                    } label: {
                        Text(contact.name)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Contacts")
            .searchable(text: $viewModel.searchText)
            .overlay {
                if viewModel.searchResults.isEmpty {
                    ContentUnavailableView.search
                }
            }
        }
    }
}
