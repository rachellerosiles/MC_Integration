//
//  MonteCarlo Circle.swift
//  MC_Integration
//
//  Created by Rachelle Rosiles on 2/9/24.
//
//

import Foundation
import SwiftUI

class MonteCarloCircle: NSObject, ObservableObject {
    
    @MainActor @Published var insideData = [(xPoint: Double, yPoint: Double)]()
    @MainActor @Published var outsideData = [(xPoint: Double, yPoint: Double)]()
    @Published var totalGuessesString = ""
    @Published var guessesString = ""
    @Published var integralString = ""
    @Published var enableButton = true
    @Published var calcIntegralString = ""
    
    var calcIntegral = 0.0
    var integral = 0.0
    var guesses = 1
    var totalGuesses = 0
    var totalIntegral = 0.0
    var xRange = 1.0
    var yRange = 1.0
    var firstTimeThroughLoop = true
    
    @MainActor init(withData data: Bool){
        
        super.init()
        
        insideData = []
        outsideData = []
        
    }


    /// calculate the value of π
    ///
    /// - Calculates the Value of π using Monte Carlo Integration
    ///
    /// - Parameter sender: Any
    func calculateIntegral() async {
        
        //calculate actual integral
        calcIntegral = integrate
        
        var maxGuesses = 0.0
        let boundingBoxCalculator = BoundingBox() ///Instantiates Class needed to calculate the area of the bounding box.
        
        
        maxGuesses = Double(guesses)
        
        let newValue = await calculateMonteCarloIntegral(domain: xRange, maxGuesses: maxGuesses)
        
        totalIntegral = totalIntegral + newValue
        
        totalGuesses = totalGuesses + guesses
        
        await updateTotalGuessesString(text: "\(totalGuesses)")
        
        //totalGuessesString = "\(totalGuesses)"
        
        ///Calculates the value of π from the area of a unit circle
        
        integral = totalIntegral/Double(totalGuesses) * boundingBoxCalculator.calculateSurfaceArea(numberOfSides: 2, lengthOfSide1: 2.0*xRange, lengthOfSide2: 2.0*yRange, lengthOfSide3: 0.0)
        
        await updatePiString(text: "\(integral)")
        
        //piString = "\(pi)"
        
       
        
    }

    /// calculates the Monte Carlo Integral of a Circle
    ///
    /// - Parameters:
    ///   - radius: radius of circle
    ///   - maxGuesses: number of guesses to use in the calculaton
    /// - Returns: ratio of points inside to total guesses. Must mulitply by area of box in calling function
    func calculateMonteCarloIntegral(domain: Double, maxGuesses: Double) async -> Double {
        
        var numberOfGuesses = 0.0
        var pointsUnderCurve = 0.0
        var integral = 0.0
        var point = (xPoint: 0.0, yPoint: 0.0)
        var eNegXVal = 0.0
        
        var newInsidePoints : [(xPoint: Double, yPoint: Double)] = []
        var newOutsidePoints : [(xPoint: Double, yPoint: Double)] = []
        
        
        while numberOfGuesses < maxGuesses {
            
            /* Calculate 2 random values within the box */
            /* Determine e^(-x) */
            /* If y<= e^(-x), count the point being within the Unit Circle */
            point.xPoint = Double.random(in: 0...domain)
            point.yPoint = Double.random(in: 0...domain)
            
            eNegXVal = exp(Double(-point.xPoint))
            //sqrt(pow(point.xPoint,2.0) + pow(point.yPoint,2.0))
            
            
            // if inside the circle add to the number of points in the radius
            if((eNegXVal - point.yPoint) >= 0.0){
                pointsUnderCurve += 1.0
                
                
                newInsidePoints.append(point)
               
            }
            else { //if outside the circle do not add to the number of points in the radius
                
                
                newOutsidePoints.append(point)

                
            }
            
            numberOfGuesses += 1.0
            
            
            
            
            }

        
        integral = Double(pointsUnderCurve)
        
        //Append the points to the arrays needed for the displays
        //Don't attempt to draw more than 250,000 points to keep the display updating speed reasonable.
        
        if ((totalGuesses < 500001) || (firstTimeThroughLoop)){
        
//            insideData.append(contentsOf: newInsidePoints)
//            outsideData.append(contentsOf: newOutsidePoints)
            
            var plotInsidePoints = newInsidePoints
            var plotOutsidePoints = newOutsidePoints
            
            if (newInsidePoints.count > 750001) {
                
                plotInsidePoints.removeSubrange(750001..<newInsidePoints.count)
            }
            
            if (newOutsidePoints.count > 750001){
                plotOutsidePoints.removeSubrange(750001..<newOutsidePoints.count)
                
            }
            
            await updateData(insidePoints: plotInsidePoints, outsidePoints: plotOutsidePoints)
            firstTimeThroughLoop = false
        }
        
        return integral
        }
    
    
    /// updateData
    /// The function runs on the main thread so it can update the GUI
    /// - Parameters:
    ///   - insidePoints: points inside the circle of the given radius
    ///   - outsidePoints: points outside the circle of the given radius
    @MainActor func updateData(insidePoints: [(xPoint: Double, yPoint: Double)] , outsidePoints: [(xPoint: Double, yPoint: Double)]){
        
        insideData.append(contentsOf: insidePoints)
        outsideData.append(contentsOf: outsidePoints)
    }
    
    /// updateTotalGuessesString
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter text: contains the string containing the number of total guesses
    @MainActor func updateTotalGuessesString(text:String){
        
        self.totalGuessesString = text
        
    }
    
    /// updatePiString
    /// The function runs on the main thread so it can update the GUI
    /// - Parameter text: contains the string containing the current value of Pi
    @MainActor func updatePiString(text:String){
        
        self.integralString = text
        
    }
    
    
    /// setButton Enable
    /// Toggles the state of the Enable Button on the Main Thread
    /// - Parameter state: Boolean describing whether the button should be enabled.
    @MainActor func setButtonEnable(state: Bool){
        
        
        if state {
            
            Task.init {
                await MainActor.run {
                    
                    
                    self.enableButton = true
                }
            }
            
            
                
        }
        else{
            
            Task.init {
                await MainActor.run {
                    
                    
                    self.enableButton = false
                }
            }
                
        }
        
    }

}
