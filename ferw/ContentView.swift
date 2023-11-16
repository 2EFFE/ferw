//
//  ContentView.swift
//  ferw
//
//  Created by Fabio Festa on 14/11/23.
//
import SwiftUI

struct Note: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var content: String
}



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


//INZIO CODICEEEEEEEEEEEEEEEEEEEEEEEEEE
struct TextEditorView: View {
    @Binding var note: Note

    var body: some View {
        VStack {
            TextEditor(text: $note.content)
                .frame(minHeight: 50)
                .padding()
        }
        .navigationTitle(note.title)
    }
}


struct ContentView: View {
    @EnvironmentObject var noteData: NoteData
    @State private var isEditingNote = false
    @State private var selectedNote: Note?
    @State private var isGalleryPresented = false
    @State private var noteTitle = ""
    @State private var noteContent = ""
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            
            
            
            ZStack {
                
                VStack{
                    
                    Text("Fewr")
                        
                        .font(Font.custom("SF Pro", size: 50))
                    
                    Text("your friendly Notebook")
                    
                        .font(Font.custom("SF Pro", size: 20))
                    
                    NavigationLink(destination: Gallery().environmentObject(noteData)) {
                        Text("Create Note")
                            .font(Font.custom("SF Pro", size: 30))
                            .multilineTextAlignment(.center)
                    }.padding(.top)
                        
                        
                    
                }.padding(.bottom, 550)
                
                
                
                    
                    Image("image")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.2)
                    
                
                    
                VStack{
                    
                    
                    
                }
                
              
                           
                        
                      
                        
                        
                        
                    
                
            }
        }
    }

    func deleteNote(at offsets: IndexSet) {
        noteData.notes.remove(atOffsets: offsets)
    }
}




struct Gallery: View {
    @EnvironmentObject var noteData: NoteData
        @State private var noteTitle = ""
        @State private var noteContent = ""
        @State private var isEditing = false
        @State private var isEditingNote = false
        @State private var selectedNote: Note?
        @State private var isDetailViewPresented = false
    
    var body: some View {
        
       
    
            Form {
                
                Section(header: Text("Create Note")) {
                    TextField("Title", text: $noteTitle)
                    TextEditor(text: $noteContent)
                        .frame(minHeight: 50)
                        .padding()
                    Button(action: createNote) {
                        Text("Create")
                            .padding(10)
                            .font(Font.custom("SF Pro", size: 20))
                        
                     
                    }
                }
                
                Section(header: Text("Your Note")) {
                    ForEach(noteData.notes) { note in
                        NavigationLink(destination: Text(note.content).navigationTitle(note.title)) {
                            Text(note.title)
                                .listStyle(InsetGroupedListStyle())
                                               .navigationTitle("Notes")
                                               .navigationBarItems(trailing: EditButton())
                        }
                    }
                    .onDelete(perform: deleteNote)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Folder")
            
       
        }
    

    
    func createNote() {
        // Assegna automaticamente "Nota" come titolo se il titolo è vuoto
        let newNoteTitle = noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Nota" : noteTitle
        
        if isEditing, let index = noteData.notes.firstIndex(where: { $0.id == selectedNote?.id }) {
            // Modifica la nota esistente
            noteData.notes[index].title = newNoteTitle
            noteData.notes[index].content = noteContent
            isEditing = false // Esci dalla modalità di modifica
        } else {
            
            
            let newNote = Note(title: newNoteTitle, content: noteContent)
            noteData.notes.append(newNote)
            noteTitle = ""
            noteContent = ""
        }}

    func deleteNote(at offsets: IndexSet) {
        noteData.notes.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NoteData())
    }
}

