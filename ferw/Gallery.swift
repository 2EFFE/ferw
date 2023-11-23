//
//  Gallery.swift
//  ferw
//
//  Created by Fabio Festa on 21/11/23.
//

import SwiftUI
import LocalAuthentication


struct Gallery: View {
    @StateObject var noteData: NoteData = NoteData()
    @State private var noteTitle = ""
    @State private var noteContent = ""
    @State private var isEditing = false
    @State private var selectedNote: Note?
    @State private var isDetailViewPresented = false
    @State private var searchText = ""
    
    @State private var isFaceIDAuthenticated = false

    

    var body: some View {
            NavigationView {
                
                                
                Form {
                  
                        
                    Section(header: Text("Create Note").foregroundStyle(.white).opacity(0.7) .font(Font.custom("Helvetica-Bold", size: 14)))
                              {
                                  
                                  
                        TextField(" Empty Title...", text: $noteTitle)
                        TextEditor(text: $noteContent)
                            .frame(minHeight: 50)
                            .padding()
                        Button(action: createNote) {
                            Text("Create")
                                .padding(10)
                                .font(Font.custom("Helvetica-Bold", size: 20))
                                .foregroundColor(.yellow)
                        }
                    }
               
                    Section(header: Text("Library").foregroundStyle(.white).opacity(0.7) .font(Font.custom("Helvetica-Bold", size: 14))) {
                        
                        HStack{
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.yellow)
                            TextField("Search...", text: $searchText)
                          
                        }
                       
                        ForEach(noteData.notes.filter {
                            searchText.isEmpty ||
                                $0.title.localizedCaseInsensitiveContains(searchText)
                        }  .sorted(by: { $0.creationDate > $1.creationDate })) { note in
                            
                            NavigationLink(destination: noteDetailView(note: note).navigationBarBackButtonHidden(true)) {
                                HStack {
                                    
                                    Image(systemName: "folder")
                                        .foregroundColor(.yellow)
                                        .imageScale(.large)
                                        .padding(.leading, -10.0)
                                      
                                    
                                    VStack(alignment: .leading) {
                                        Text(note.title)
                                        Text("Created on: \(note.creationDate)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                                      
                            }
                                                      
                        }
                        .onDelete(perform: deleteNote)
                    }
                }
                .listStyle(GroupedListStyle())
                
                
            }
        }
    
    func noteDetailView(note: Note) -> some View {
           if isFaceIDAuthenticated {
               return AnyView(TextEditorView(note: $noteData.notes[noteData.notes.firstIndex(of: note)!]))
           } else {
               return AnyView(FaceIDAuthenticationView(isAuthenticated: $isFaceIDAuthenticated, onSuccess: {
                   // Chiamato quando l'autenticazione è riuscita
                   isFaceIDAuthenticated = true
               }))
           }
       }
    

    func createNote() {
        let newNoteTitle = noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Note" : noteTitle
        

        if isEditing, let index = noteData.notes.firstIndex(where: { $0.id == selectedNote?.id }) {
            noteData.notes[index].title = newNoteTitle
            noteData.notes[index].content = noteContent
            isEditing = false
            
        } else {
            let newNote = Note(title: newNoteTitle, content: noteContent)
            noteData.notes.append(newNote)
            noteTitle = ""
            noteContent = ""
        }
    }

    func startEditing(note: Note) {
        selectedNote = note
    }

    func deleteNote(at offsets: IndexSet) {
        noteData.notes.remove(atOffsets: offsets)
        selectedNote = nil // Aggiunto per deselezionare la nota dopo l'eliminazione
    }

    func deleteSelectedNote() {
        if let selectedNote = selectedNote,
           let index = noteData.notes.firstIndex(where: { $0.id == selectedNote.id }) {
            deleteNote(at: IndexSet([index]))
        }
    }
    
    func deleteNoteManually() {
        if let selectedNote = selectedNote,
           let index = noteData.notes.firstIndex(where: { $0.id == selectedNote.id }) {
            deleteNote(at: IndexSet([index]))
         
        }
    }
    
}

struct FaceIDAuthenticationView: View {
    @Binding var isAuthenticated: Bool
    var onSuccess: () -> Void

    var body: some View {
        // Puoi personalizzare la tua interfaccia per l'autenticazione Face ID qui
        VStack {
            Text("Face ID Authentication")
                .font(.title)
                .padding()

            Button("Authenticate") {
                authenticateWithFaceID()
            }
        }
        .padding()
    }

    private func authenticateWithFaceID() {
        let context = LAContext()

        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access the note."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isAuthenticated = true
                        onSuccess()
                    } else {
                        // L'autenticazione Face ID non è riuscita
                        print("Face ID Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            // Il dispositivo non supporta Face ID o Touch ID
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}

#Preview {
    Gallery()
}
