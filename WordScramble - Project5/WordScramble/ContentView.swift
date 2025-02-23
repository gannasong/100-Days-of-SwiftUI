//
//  ContentView.swift
//  WordScramble
//
//  Created by SUNG HAO LIN on 2022/8/8.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWord: [String] = []
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var restartRotate = false
    @State private var wordVerify = false
    @State private var score: Int = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                } header: {
                    Text("New word").textCase(nil)
                }
                
                Section {
                    Text("Current Score: \(score)")
                } header: {
                    Text("Your score")
                }
                
                Section {
                    ForEach(usedWord, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle") // .circle.fill
                            Text(word)
                        }
                    }
                } header: {
                    Text("Used Word")
                        .opacity(usedWord.isEmpty ? 0 : 1)
                        .textCase(nil)
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onChange(of: newWord) { input in
                if input.count > 3 && input != rootWord {
                    wordVerify = true
                } else {
                    wordVerify = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            restartRotate = true
                            startGame()
                        }
                        
                        restartRotate = false
                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                                .foregroundColor(.red)
                                .rotationEffect(.degrees(restartRotate ? 360 : 0))
                                
                            Text("Restart")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                        }
                    }
                }
            }
        }
    }
    
    func addNewWord() {
        guard wordVerify else {
            wordError(title: "Hey!", message: "You can't input shorter than three letters or are just our start word!")
            return
        }
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        // Extra validation to come
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        // 用 insert 插在前面
        withAnimation {
            usedWord.insert(answer, at: 0)
        }
        newWord = ""
        score += 1
    }
    
    func startGame() {
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0
                usedWord = []
                return
            }
        }
        
        fatalError("Could not laod start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWord.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
