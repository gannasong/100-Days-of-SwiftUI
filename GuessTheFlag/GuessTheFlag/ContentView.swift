//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by SUNG HAO LIN on 2022/7/30.
//

import SwiftUI

struct ContentView: View {
    @State private var showingScore = false
    @State private var showingReset = false
    @State private var scoreTitle = ""
    @State private var aleretMessage = ""
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var score: Int = 0
    @State private var playCount: Int = 0
    
    @State private var selectedNumber = 0
    @State private var correctFlag = false
    @State private var isTapped = false
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.5), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
            ], center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            withAnimation {
                                flagTapped(number)
                            }
                        } label: {
                            FlagImage(countries[number])
                        }
                        .rotation3DEffect(.degrees(correctFlag && selectedNumber == number ? 1800 : 0), axis: (x: 0, y: 1, z: 0))
                        .opacity(isTapped ? selectedNumber == number ? 1 : 0.25 : 1)
                        .scaleEffect(isTapped ? selectedNumber == number ? 1 : 0.8 : 1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(score)")
                    .foregroundColor(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button {
                askQuestion()
            } label: {
                Text("Continue")
            }
        } message: {
            Text(aleretMessage)
        }
        .alert("Game Over", isPresented: $showingReset) {
            Button {
                reset()
            } label: {
                Text("Reset")
            }
        } message: {
            Text("Your score is \(score) !")
        }
    }
    
    @ViewBuilder
    private func FlagImage(_ name: String) -> some View {
        Image(name)
            .renderingMode(.original)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
    
    func flagTapped(_ number: Int) {
        selectedNumber = number
        isTapped = true
        
        if number == correctAnswer {
            score += 1
            scoreTitle = "Correct"
            aleretMessage = "Your score is \(score)"
            correctFlag = true
        } else {
            scoreTitle = "Wrong"
            aleretMessage = "That’s the flag of \(countries[number])"
        }
        
        playCount += 1
        
        if playCount == 8 {
            showingReset = true
        } else {
            showingScore = true
        }
    }
    
    func askQuestion() {
        countries = countries.shuffled()
        correctAnswer = Int.random(in: 0...2)
        correctFlag = false
        isTapped = false
    }
    
    func reset() {
        score = 0
        playCount = 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
