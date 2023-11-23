//
//  ContentView.swift
//  ferw
//
//  Created by Fabio Festa on 14/11/23.
//
import SwiftUI
import LocalAuthentication


class NoteData: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }

    init() {
        loadNotes()
    }

    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: "notes")
        } catch {
            print("Error encoding notes: \(error)")
        }
    }

    func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "notes") {
            do {
                notes = try JSONDecoder().decode([Note].self, from: data)
            } catch {
                print("Error decoding notes: \(error)")
            }
        }
    }
}







struct TextEditorView: View {
 

    @Binding var note: Note
    @State private var selectedNote: Note?


   
      @State private var noteTitle: String
      @State private var noteContent: String
    
    
   
    
    init(note: Binding<Note>) {
           _note = note
           _noteTitle = State(initialValue: note.wrappedValue.title)
           _noteContent = State(initialValue: note.wrappedValue.content)
       }

    var body: some View {
        
        
        
           VStack {
               TextField("Title", text: $noteTitle)
                   .padding()
               
               
               TextEditor(text: $noteContent)
                   .frame(minHeight: 30)
                   .padding()
               
                          
                         
           }
           .navigationTitle(note.title)
           .onAppear {
               noteTitle = note.title
               noteContent = note.content
              
              
           }
           .onDisappear {
               note.title = noteTitle
               note.content = noteContent
              
           }
        
       }
    
   
  }
   
    



struct ContentView: View {
    @EnvironmentObject var noteData: NoteData
     @State private var noteTitle = ""
     @State private var noteContent = ""
     @State private var isEditing = false
     @State private var selectedNote: Note?
     @State private var isDetailViewPresented = false
     @State private var searchText = ""
    
    @State private var isFaceIDAuthenticated = false

    
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        return formatter
    }
    
   
    
    var body: some View {
        
       
            
            NavigationView {
                
             
             
           
                                                       
                
            Form{
                
             
                    
                VStack{
                    
                    
                    ScrollView{
                        
                        Text("")
                            .navigationBarTitle("Notes", displayMode: .large)
                          
                            
                          
                        
                        
                        NavigationLink(destination: Gallery().environmentObject(noteData)) {
                            Rectangle()
                                .foregroundColor(.gray.opacity(0))
                                .frame(width: 330, height: 50)
                                .cornerRadius(10)
                            
                            
                                .overlay(
                                    
                                    HStack{
                                        
                                        
                                     
                                        
                                        Text("New")
                                            .font(Font.custom("Helvetica-Bold", size: 30))
                                            .foregroundColor(.yellow)
                                            .padding(.leading, 5)
                                        
                                        
                                        
                                        Image(systemName: "folder.badge.plus")
                                            .foregroundColor(.yellow)
                                            .imageScale(.large)
                                    }
                                )
                             
                        }
                        
                    }//scroll view}
                }
                
                
             
                    
                Section(header: Text("Your Note").foregroundStyle(.white).opacity(0.7) .font(Font.custom("Helvetica-Bold", size: 14))) {
                    
                    
                    
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.yellow)
                        TextField("Search...", text: $searchText)
                        
                        
                    }
                    
                   
                        ForEach(noteData.notes.filter {
                            searchText.isEmpty ||
                            $0.title.localizedCaseInsensitiveContains(searchText)
                        }) { note in
                            NavigationLink(destination: noteDetailView(note: note)) {
                                
                                
                                
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
                                    Spacer()
                                    if isEditing {
                                        Button(action: {
                                            startEditing(note: note)
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundColor(.yellow)
                                        }
                                        Button(action: {
                                            deleteSelectedNote()
                                        }) {
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                        .onDelete(perform: deleteNote)
                    
                    }
                
                }
         
                        
            }//navigationlink
           
        }//someview
    
    
    func noteDetailView(note: Note) -> some View {
           if isFaceIDAuthenticated {
               return AnyView(TextEditorView(note: $noteData.notes[noteData.notes.firstIndex(of: note)!]).navigationBarBackButtonHidden(true))
           } else {
               return AnyView(FaceIDAuthenticationVieww(isAuthenticated: $isFaceIDAuthenticated, onSuccess: {
                   // Chiamato quando l'autenticazione è riuscita
                   isFaceIDAuthenticated = true
               }))
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
        
    
    }//contentview


    
struct FaceIDAuthenticationVieww: View {
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
    




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NoteData())
    }
}



