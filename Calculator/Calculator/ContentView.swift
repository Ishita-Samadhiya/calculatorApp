import SwiftUI

struct ContentView: View {
    // State variables to track user input and perform calculations
    @State private var displayText = "0"
    @State private var firstOperand = ""
    @State private var secondOperand = ""
    @State private var currentOperation = ""
    @State private var first = true // Indicates whether it's the first operand or the second one
    
    // Array representing the buttons in the calculator
    @State private var buttons: [[String]] = [
        ["AC", "+/-", "%", "÷"],
        ["7", "8", "9", "x"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            // Display text
            Text(displayText)
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.system(size: 88, weight: .light))
                .lineLimit(1)
                .minimumScaleFactor(0.2)
            // Buttons grid
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            self.buttonTapped(button)
                        }) {
                            // Button with specific styling
                            Text(button)
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: buttonWidth(button), height: buttonHeight())
                                .foregroundColor(buttonForegroundColor(button))
                                .background(buttonBackgroundColor(button))
                                .cornerRadius(buttonHeight() / 2)
                        }
                    }
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all)) // Background color
    }
    
    // Function to handle button taps
    func buttonTapped(_ button: String) {
        // Limit the number of digits on display text to 9
        if displayText.count < 9 && (button.isNumeric || button == "."){
            buttons[0][0] = "C" // Change the "AC" button to "C" when typing
            if button == "." && displayText.contains(".") {
                return
            }
            // Handling the first and second operands
            if !first{
                if displayText == "0" {
                    firstOperand = button
                    displayText = button
                } else {
                    firstOperand += button
                    displayText += button
                }
            } else {
                if displayText != "0" {
                    secondOperand += button
                    displayText += button
                } else {
                    secondOperand = button
                    displayText = button
                }
            }
        } else {
            buttons[0][0] = "AC" // Change the "C" button back to "AC" in other cases
            // Handling operations and other buttons
            switch button {
            case "÷", "x", "-", "+":
                if !firstOperand.isEmpty {
                    first = true // Reset the first operand flag
                    currentOperation = button
                    displayText = "" // Clear the display for the next operand
                }
            case "=":
                if !firstOperand.isEmpty && !secondOperand.isEmpty {
                    calculate() // Calculate the result
                    first = true // Reset the first operand flag
                    secondOperand = "" // Clear the second operand for future use
                    firstOperand = displayText // Store the result as the first operand
                }
            case "AC":
                clearAll() // Clear all operands and reset the calculator
            case "C":
                clearLastEntry() // Clear the last entry on the display
            case "+/-":
                changeSign() // Change the sign of the number
            case "%":
                convertToPercentage() // Convert the number to a percentage
                if first {
                    secondOperand = displayText // Update the second operand after percentage calculation
                } else{
                    firstOperand = displayText // Update the first operand after percentage calculation
                }
            default:
                break
            }
        }
    }

    // Function to calculate the result
    func calculate() {
        guard let first = Double(firstOperand), let second = Double(displayText) else {
            displayText = "Error" // Display an error message if operands are invalid
            return
        }
        
        // Perform the selected operation
        var result: Double = 0
        switch currentOperation {
        case "÷":
            if second == 0 {
                displayText = "Error" // Display an error message for division by zero
                return
            }
            result = first / second
        case "x":
            result = first * second
        case "-":
            result = first - second
        case "+":
            result = first + second
        default:
            break
        }
        
        // Limit the result to 9 digits
        if String(result).count > 9 {
            result = Double(String(result).prefix(9))! // Round the result to 9 digits
        }
        
        // Format the result to remove trailing zeros if necessary
        let formattedResult = String(result).replacingOccurrences(of: ".0", with: "")
        displayText = formattedResult
        firstOperand = formattedResult
    }

    // Function to clear all
    func clearAll() {
        // Clear all state variables and reset the calculator
        displayText = "0"
        firstOperand = ""
        secondOperand = ""
        first = false
        currentOperation = ""
    }

    // Function to clear the last entry
    func clearLastEntry() {
        // Remove the last character from the display text
        if !displayText.isEmpty {
            displayText.removeLast()
        }
        // If the display text is empty, reset it to "0"
        if displayText.isEmpty {
            displayText = "0"
        }
    }

    // Function to change sign
    func changeSign() {
        // Change the sign of the number displayed on the calculator
        if displayText != "0" {
            if displayText.first == "-" {
                displayText.removeFirst()
            } else {
                displayText = "-" + displayText
            }
        }
    }

    // Function to convert to percentage
    func convertToPercentage() {
        // Convert the number displayed on the calculator to a percentage
        guard let number = Double(displayText) else {
            displayText = "Error" // Display an error message for invalid input
            return
        }
        displayText = "\(number / 100)" // Update the display text with the percentage value
    }

    // Function to calculate button width
    func buttonWidth(_ button: String) -> CGFloat {
        // Calculate the width of the button based on its content
        if button == "0" {
            return (UIScreen.main.bounds.width - 48) / 2
        }
        return (UIScreen.main.bounds.width - 60) / 4
    }
    
    // Function to calculate button height
    func buttonHeight() -> CGFloat {
        // Calculate the height of the button based on the screen width
        return (UIScreen.main.bounds.width - 60) / 4
    }
    
    // Function to determine button background color
    func buttonBackgroundColor(_ button: String) -> Color {
        // Determine the background color of the button based on its content
        switch button {
        case "AC", "+/-", "%", "C":
            return Color(red: 0.8, green: 0.8, blue: 0.8) // Gray background for clear-related buttons
        case "=", "÷", "x", "-", "+":
            return Color.orange // Orange background for operation buttons
        default:
            return Color.gray // Gray background for numeric and decimal point buttons
        }
    }
    
    // Function to determine button text color
    func buttonForegroundColor(_ button: String) -> Color {
        // Determine the text color of the button based on its content
        switch button {
        case "AC", "C", "+/-", "%":
            return Color.black // Black text for clear-related buttons
        default:
            return Color.white // White text for other buttons
        }
    }
}

// Extension to check if a string is numeric
extension String {
    var isNumeric: Bool {
        return Double(self) != nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
