//
//  ContentView.swift
//  MC_Integration
//
//  Created by Rachelle Rosiles on 2/9/24.
//


import SwiftUI

struct ContentView: View {
    
    @State var integralE = 0.0
    @State var totalGuesses = 0.0
    @State var totalIntegral = 0.0
    @State var calcIntegral = 0.0
    @State var radius = 1.0
    @State var calcIntegralString = "0.0"
    @State var integralString = "0.0"
    @State var guessString = "23458"
    @State var totalGuessString = "0"
    
    
    
    // Setup the GUI to monitor the data from the Monte Carlo Integral Calculator
    @ObservedObject var monteCarlo = MonteCarloCircle(withData: true)
    
    //Setup the GUI View
    var body: some View {
        HStack{
            
            VStack{
                
                VStack(alignment: .center) {
                    Text("Guesses")
                        .font(.callout)
                        .bold()
                    TextField("# Guesses", text: $guessString)
                        .padding()
                }
                .padding(.top, 5.0)
                
                VStack(alignment: .center) {
                    Text("Total Guesses")
                        .font(.callout)
                        .bold()
                    TextField("# Total Guesses", text: $totalGuessString)
                        .padding()
                }
                
                VStack(alignment: .center) {
                    Text("Monte Carlo Integral")
                        .font(.callout)
                        .bold()
                    TextField("# integral", text: $integralString)
                        .padding()
                }
                
                VStack(alignment: .center) {
                    Text("Calculated Integral")
                        .font(.callout)
                        .bold()
                    TextField("# Guesses", text: $calcIntegralString)
                        .padding()
                }
                
                Button("Cycle Calculation", action: {Task.init{await self.calculatePi()}})
                    .padding()
                    .disabled(monteCarlo.enableButton == false)
                
                Button("Clear", action: {self.clear()})
                    .padding(.bottom, 5.0)
                    .disabled(monteCarlo.enableButton == false)
                
                if (!monteCarlo.enableButton){
                    
                    ProgressView()
                }
                
                
            }
            .padding()
            
            //DrawingField
            
            
            drawingView(redLayer:$monteCarlo.insideData, blueLayer: $monteCarlo.outsideData)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .drawingGroup()
            // Stop the window shrinking to zero.
            Spacer()
            
        }
    }
    
    func calculatePi() async {
        
        
        monteCarlo.setButtonEnable(state: false)
        
        monteCarlo.guesses = Int(guessString)!
        monteCarlo.xRange = radius
        monteCarlo.totalGuesses = Int(totalGuessString) ?? Int(0.0)
        
        await monteCarlo.calculateIntegral()
        
        totalGuessString = monteCarlo.totalGuessesString
        
        integralString =  monteCarlo.integralString
        
        monteCarlo.setButtonEnable(state: true)
        
    }
    
    func clear(){
        
        guessString = "23458"
        totalGuessString = "0.0"
        integralString =  ""
        monteCarlo.totalGuesses = 0
        monteCarlo.totalIntegral = 0.0
        monteCarlo.insideData = []
        monteCarlo.outsideData = []
        monteCarlo.firstTimeThroughLoop = true
        
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 
