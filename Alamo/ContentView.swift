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

//ยังupdate หน้าui เวลา recall api ไม่ได้
// ยังเก็บdataส่งค่าไปอีกหน้าไม่ได้ แต่ทำarrayไว้รอรับแล้วถ้า data มาจะโชว์ List

struct ContentView: View {
   
    @ObservedObject var obs = observe()
    let defaults = UserDefaults.standard
    
    var body: some View {
       
        NavigationView{
            List(obs.datas){ i in
                
                card(currencyUSD: i.currencyUSD, currencyEUR: i.currencyEUR, currencyGBP: i.currencyGBP,dateUpdate: i.dateUpdate)

            }.onAppear() {
//               card()
            }
            
            .navigationBarTitle("BTC Price")
                .toolbar {
                    NavigationLink(
                        destination: ListScreen(),
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
struct Card_Previews: PreviewProvider {
    static var previews: some View {
        card()
    }
}

class observe: ObservableObject, Identifiable{
    @Published var datas = [datatype]()
    @Published var coinHistory = [coinRecord]()
    let defaults = UserDefaults.standard
    
    init(){
        
        AF.request("https://api.coindesk.com/v1/bpi/currentprice.json",method: .get).responseData { (data) in
            
            let json = try! JSON(data: data.data!)

            self.datas.append(datatype(id: json["time"]["updateduk"].stringValue, currencyEUR: json["bpi"]["EUR"]["rate"].stringValue, currencyUSD: json["bpi"]["USD"]["rate"].stringValue, currencyGBP: json["bpi"]["GBP"]["rate"].stringValue,dateUpdate: json["time"]["updateduk"].stringValue))

            self.coinHistory.append(coinRecord(id: json["time"]["updateduk"].stringValue, currencyEUR: json["bpi"]["EUR"]["rate"].stringValue, currencyUSD: json["bpi"]["USD"]["rate"].stringValue, currencyGBP: json["bpi"]["GBP"]["rate"].stringValue))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
            observe()
//            ContentView()
          
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
struct coinRecord : Identifiable{
    
    @State var id: String
    @State var currencyEUR :String
    @State var currencyUSD :String
    @State var currencyGBP :String

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
    let defaults = UserDefaults.standard
    var coinData = [String:[String]]()

    var body: some View{
        
        List(obs.coinHistory){ coinData in
            VStack{
                
                Text(coinData.id)
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
                    Text(coinData.currencyGBP)
                    
                }
                HStack{
                    
                    Image("dollar")
                        .resizable()
                        .frame(width: 30,height: 30)
                        .foregroundColor(Color.green)
                        .clipShape(Circle())
                        .padding()
                    Text(coinData.currencyUSD)
                    
                }
                HStack{
                    
                    Image("euro")
                        .resizable()
                        .frame(width: 30,height: 30)
                        .clipShape(Circle())
                        .padding()
                    Text(coinData.currencyEUR)
                    
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
