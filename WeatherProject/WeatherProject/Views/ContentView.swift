import SwiftUI

struct ContentView: View {
    
    @State private var filteredCities: [String] = citiesList
    @State private var selectedCity = "Riyadh"
    @State private var searchedText = ""
    @State private var weatherData: WeatherData?
    @State private var isMetric = true
    @State private var backgroundColor: Color = Color.init(red: 232/255, green: 172/255, blue: 136/255)

    var body: some View {
        
        VStack {
            // MARK: Search for a city
            HStack {
                 TextField(" Search city", text: $searchedText)
                    .font(.custom("Queensides", size: 18))
                    .foregroundColor(.white)
                     .padding(.horizontal, 8)
                     .padding(.vertical, 7)
                      .background(
                          RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white, lineWidth: 1.5)
                              .background(Color.clear)
                      )
                 Button(action: {
                     selectedCity = searchedText
                 }) {
                     Text("Search")
                    .font(.custom("Queensides", size: 18))
                 }
             }
            
            // MARK: Selecting a city from a dropdown menu
            Picker("Select a city", selection: $selectedCity) {
                ForEach(filteredCities, id: \.self) { city in
                    Text(city)
                        .font(.custom("Queensides", size: 18))
                        .foregroundColor(.white)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedCity) { newValue in
                fetchData(for: newValue)
            }
            
            // MARK: Displaying the date and time
            Text(getFormattedDate())
                .font(.custom("Queensides", size: 20))
                .padding(.top)
            Text(getFormattedTime())
                .font(.custom("Queensides", size: 28))
            Text("")
            
            // MARK: Displaying the selected city name
            Text("\(selectedCity)")
                .font(.custom("Queensides", size: 40))
            
            // MARK: Displaying the data
            if let data = weatherData {
                if let iconName = weatherIconMapping[data.weather[0].description] {
                    Image(iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 115)
                }
                
                if isMetric {
                    let tempInCelsius = Int(data.main.temp - 273.15)
                    Text("\(tempInCelsius) °C")
                        .font(.custom("Queensides", size: 60))
                    Text("\n")
                    Text("Wind Speed: \(String(format: "%.2f", data.wind.speed)) m/s")
                        .font(.custom("Queensides", size: 25))
                } else {
                    let tempInFahrenheit = (data.main.temp - 273.15) * 9/5 + 32
                    Text("\(String(format: "%.2f", tempInFahrenheit)) °F")
                        .font(.custom("Queensides", size: 60))
                    Text("\n")
                    Text("Wind Speed: \(String(format: "%.2f", data.wind.speed * 2.237)) mph")
                        .font(.custom("Queensides", size: 25))
                }
                Text("Humidity: \(data.main.humidity)%")
                    .font(.custom("Queensides", size: 25))
                Text("\(data.weather[0].description)")
                    .font(.custom("Queensides", size: 25))
            } else {
                Text("\n\n\nLoading...")
                    .font(.custom("Queensides", size: 40))
            }
            Spacer()
            .padding()
            
            //MARK: Switching between Metric and Imperial Units
            HStack {
                Button(action: {
                    isMetric = true
                }) {
                    Text("Metric")
                        .font(.custom("Queensides", size: 15))
                        .foregroundColor(isMetric ? .black : .white)
                        .padding()
                        .frame(width: 100, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(isMetric ? Color.white : Color.white, lineWidth: 2)
                                .background(isMetric ? Color.white : Color.clear)
                        )
                        .cornerRadius(30)
                }
                Button(action: {
                    isMetric = false
                }) {
                    Text("Imperial")
                        .font(.custom("Queensides", size: 15))                        .foregroundColor(isMetric ? .white : .black)
                        .padding()
                        .frame(width: 100, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(isMetric ? Color.white : Color.white, lineWidth: 2)
                                .background(isMetric ? Color.clear : Color.white)
                        )
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .foregroundColor(.white)
        .background(backgroundColor)
        .onAppear {
            fetchData(for: selectedCity)
        }
    }

        func fetchData(for city: String) {
            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=e295a7ef84892b5360f380bbc91b41ec") else {
                return
            }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.weatherData = decodedData
                    if let weatherDescription = decodedData.weather.first?.description,
                       let bgColor = backgroundColorMapping[weatherDescription.lowercased()] {
                        backgroundColor = bgColor
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    // MARK: Funcs to fetch the date and time
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }
    func getFormattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
