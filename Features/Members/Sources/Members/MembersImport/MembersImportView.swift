//
//  MembersImportView.swift
//
//
//  Created by Albert Bori on 10/15/23.
//

import Components
import SwiftUI
import VSM

public typealias MembersImportViewDependencies = MembersImportViewStateDependencies

struct MembersImportView: View {
    var dependencies: MembersImportViewDependencies
    @Binding var clipboardText: String?
    @ViewState var state: MembersImportViewState = .initialized(MembersImportViewState.ImporterModel())
    
    var body: some View {
        switch state {
        case .initialized(let importerModel):
            confirmationView(importerModel: importerModel)
        case .importing:
            progressView()
        case .importError(let errorModel):
            errorView(errorModel: errorModel)
        case .importComplete(let recordCount):
            successView(recordCount: recordCount)
        }
    }
    
    func progressView() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Expand to all available space
            .background(Color.gray.opacity(0.25))
            .ignoresSafeArea() // This will ignore the safe area and extend to the full screen
    }
    
    func confirmationView(importerModel: MembersImportViewState.ImporterModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Import Members")
                .font(.headline)
                .padding(.top)
            
            Text("Would you like to try and import member information from the contents of your clipboard?")
                .fontWeight(.medium)
                .padding(.vertical)

            ScrollView {
                StatusView(status: .warning, message: """
                    Disclaimer: By selecting 'Import Contents of Clipboard', you affirm that you have obtained the necessary consent from the individuals to store their personal information in this app. This import function will access the following data from your clipboard:
                    
                    - Full Name
                    - Phone Number
                    - Email Address
                    
                    The data you import will be processed and stored confidentially using cloud services and is not disclosed to any additional third parties.
                    """)
            }
            .frame(maxHeight: 200)

            HStack {
                Button("Cancel") {
                    clipboardText = nil
                }
                .foregroundColor(.secondary)
                .padding(.vertical)

                Spacer()

                Button("Import Contents of Clipboard") {
                    $state.observe(importerModel.beginImport(dependencies: dependencies, rawText: clipboardText))
                }
                .foregroundColor(.accentColor)
                .padding(.vertical)
            }
            .padding(.bottom)
        }
        .padding()
        .frame(maxWidth: .infinity)
        #if canImport(AppKit)
        .background(Color(NSColor.windowBackgroundColor)) // macOS Catalyst
        #else
        .background(Color(UIColor.systemBackground)) // iOS
        #endif
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding()
    }

    
    func errorView(errorModel: MembersImportViewState.ErrorModel) -> some View {
        let action: StatusView.Action
        if let retryAction = errorModel.retry {
            action = .button(text: "Retry", action: {
                $state.observe(retryAction())
            })
        } else {
            action = .button(text: "Ok", action: {
                clipboardText = nil
            })
        }
        return StatusView(status: .failure, message: errorModel.errorMessage, action: action)
    }
    
    @ViewBuilder
    func successView(recordCount: Int) -> some View {
        StatusView(status: .success, message: "\(recordCount) members were imported", action: .button(text: "Ok", action: {
            clipboardText = nil
        }))
    }
}

#Preview {
    MembersImportView(dependencies: .Mock(), clipboardText: .constant(""))
}
