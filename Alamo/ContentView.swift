//
//  ContentView.swift
//  Alamo
//
//  Created by Suphawat Lerdthanaporn on 5/1/2566 BE.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import Combine


// ยังเก็บdataส่งค่าไปอีกหน้าไม่ได้ แต่ทำarrayไว้รอรับแล้วถ้า data มาจะโชว์ List

struct ContentView: View {
   
    @ObservedObject var obs = observe()
    
    
    var body: some View {
       
        NavigationView{
            List(obs.datas){ i in
                
                card(currencyUSD: i.currencyUSD, currencyEUR: i.currencyEUR, currencyGBP: i.currencyGBP,dateUpdate: i.dateUpdate)

            }.navigationBarTitle("BTC Price")
                .toolbar {
                    NavigationLink(
                        destination: ListScreen(coinData: obs.coinData),
                        label: {
                            Text("History")
                        })
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class observe: ObservableObject, Identifiable{
    @Published var datas = [datatype]()
    @Published var coinData = [[String]]()
    
    init(){
        coinData.removeAll()
        performFetch()
     
    }
    func performFetch() {
        
        AF.request("https://api.coindesk.com/v1/bpi/currentprice.json", method: .get).responseData { (response) in
            switch response.result{
            case let .success(value):
                
                let json = try! JSON(data: value)
                
                self.datas.append(datatype(id: json["time"]["updateduk"].stringValue, currencyEUR: json["bpi"]["EUR"]["rate"].stringValue, currencyUSD: json["bpi"]["USD"]["rate"].stringValue, currencyGBP: json["bpi"]["GBP"]["rate"].stringValue,dateUpdate: json["time"]["updateduk"].stringValue))
                
                self.coinData.append([json["time"]["updateduk"].stringValue,json["bpi"]["EUR"]["rate"].stringValue,json["bpi"]["USD"]["rate"].stringValue,json["bpi"]["GBP"]["rate"].stringValue])
                
            case let .failure(err):
                print(err)
                print("error")
                
            }
            print(self.coinData)
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                self.datas.removeAll()
                self.performFetch()
            }
      }
    }
}

struct datatype : Identifiable{
    
    @State var id: String
    @State var currencyEUR :String
    @State var currencyUSD :String
    @State var currencyGBP :String
    @State var dateUpdate :String
}


struct card: View{
  
    @State var currencyUSD = ""
    @State var currencyEUR = ""
    @State var currencyGBP = ""
    @State var dateUpdate = ""
    @State var myFloat = ""
    @State var options = ["USD", "EUR", "GBP"]
    @State var selectedItem = "USD"
    @State var currencyCal: Double = 0.0
    @ObservedObject var viewModel = ViewModel()
    let thousandsSep = Locale.current.groupingSeparator

    var body: some View{
        
        VStack{
            HStack{
                
                Image("pound")
                    .resizable()
                    .frame(width: 30,height: 30)
                    .clipShape(Circle())
                    .padding()
                Text(currencyGBP)
            
            }
            HStack{
                
                Image("dollar")
                    .resizable()
                    .frame(width: 30,height: 30)
                    .foregroundColor(Color.green)
                    .clipShape(Circle())
                    .padding()
                Text(currencyUSD)
                
            }
            HStack{
                
                Image("euro")
                    .resizable()
                    .frame(width: 30,height: 30)
                    .clipShape(Circle())
                    .padding()
                Text(currencyEUR)
                
            }
        }.listRowSeparator(.visible)
        VStack{
            HStack{
                
                Picker("Pick a Currency", selection: $selectedItem) {
                            ForEach(options, id: \.self) { item in
                                Text(item)
                            }
                }
            }
            HStack{
                
                TextField("0.00",text: self.$viewModel.location, onEditingChanged: { (changed) in
                    if changed {
                        print("text edit has begun \(selectedItem)")
                    } else {
                        let textType = viewModel.location.trimmingCharacters(in: .whitespaces)
                        if textType == "." || textType == ""{
                            currencyCal = 0.0
                        }else{
                            
                            if selectedItem == "USD" {
                                myFloat = currencyUSD
                            }else  if selectedItem == "EUR" {
                                myFloat = currencyEUR
                            }else  if selectedItem == "GBP" {
                                myFloat = currencyGBP
                            }else{
                                myFloat = currencyUSD
                            }
                            myFloat = myFloat.replacingOccurrences(of: thousandsSep!, with: "")
                            currencyCal = (Double(textType)! * Double(myFloat)!)
                        }
                    }
                }).keyboardType(.decimalPad)
            }
            Text("\(currencyCal)")
        }.listRowSeparator(.visible)
        
        VStack{
            
            Text(dateUpdate)
                .padding(.vertical)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
            
        }.listRowSeparator(.visible)
    }
}

struct ListScreen: View{
    
    @ObservedObject var obs = observe()
    var coinData = [[String]]()

    var body: some View{
 
        List(coinData, id: \.self){ coinData in
            VStack{
                
                Text(coinData[0])
                    .padding(.vertical)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                
            }.listRowSeparator(.visible)
            VStack {
                HStack{
                    
                    Image("pound")
                        .resizable()
                        .frame(width: 30,height: 30)
                        .clipShape(Circle())
                        .padding()
                    Text(coinData[3])
                    
                }
                HStack{
                    
                    Image("dollar")
                        .resizable()
                        .frame(width: 30,height: 30)
                        .foregroundColor(Color.green)
                        .clipShape(Circle())
                        .padding()
                    Text(coinData[2])
                    
                }
                HStack{
                    
                    Image("euro")
                        .resizable()
                        .frame(width: 30,height: 30)
                        .clipShape(Circle())
                        .padding()
                    Text(coinData[1])
                    
                }
            }
        }
    }
}

class ViewModel: ObservableObject {
    @Published var location = "0.0" {
        didSet {

        }
    }
}
