//
//  ContentView.swift
//  GeneracionToken
//
//  Created by Felipe Ramirez Vargas on 26/3/21.
//

import SwiftUI
import Amplify
import LocalAuthentication
import SCLAlertView

class ContentViewModel: ObservableObject {
    @Published var logged = false
    
    func isLogged()->Bool{
        return logged
    }
}

struct ContentView: View {
    @State private var logged = false
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView{
            if self.isLogged() {
                OTP()
                    .toolbar {
                        Button("LogOut"){
                            self.logOut()
                        }
                    }
            }else{
                VStack{
                    Text("BAC CREDOMATIC").bold().font(.title).background(Color.red)
                    Text("Ingresar a la plataforma").font(.subheadline)
                        .padding(EdgeInsets(top:0, leading: 0, bottom: 10, trailing: 0))
                    
                    TextField("Username", text:$username)
                        .padding()
                        .background(Color("flash-white"))
                        .cornerRadius(4.0)
                        .padding(EdgeInsets(top:0, leading: 0, bottom: 15, trailing: 0))
                        .autocapitalization(.none)
                    
                    SecureField("Password", text:$password)
                        .padding()
                        .background(Color("flash-white"))
                        .cornerRadius(4.0)
                        .padding(.bottom,10)
                        .autocapitalization(.none)
                    
                    Button(action: signIn) {
                        HStack(alignment: .center){
                            Spacer()
                            Text("Login").foregroundColor(Color.white).bold()
                            Spacer()
                        }
                    }.padding().background(Color.red).cornerRadius(15.0)
                    
                    VStack(spacing: 15){
                        Text("Ingresar con huella").font(.subheadline).padding(.top, 15)
                        if getBiometricStatus(){
                            Button(
                                action: authenticateUser,
                                label: {
                                    Image(systemName: LAContext().biometryType == .faceID ? "faceid" : "touchid")
                                        .font(.title)
                                        .foregroundColor(.black)
                                }
                            )
                        }
                    }
                    
                    NavigationLink(destination: SignUp()){
                        HStack(alignment: .center){
                            Spacer()
                            Text("Registrarse").foregroundColor(Color.red)
                            Spacer()
                        }
                    }.padding().background(Color.white).cornerRadius(15.0)
                    
                }
            }
        }
        .onAppear{self.fetchCurrentAuthSession()}
        .navigationBarTitle("Welcome")
    }
    
    func signIn() {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            
            case.success:
                print("\(username) signed in")
                DispatchQueue.main.async {
                    self.logged = true
                    print("Login in")
                }
             
            case.failure(let error):
                print(error)
                DispatchQueue.main.async {
                    SCLAlertView().showError("Error", subTitle: error.errorDescription)
                }
            }
        }
    }
    
    func getBiometricStatus()->Bool{
        let scanner = LAContext()
        //Biometry is available on the device
        if scanner.canEvaluatePolicy(.deviceOwnerAuthentication, error: .none){
            return true
        }
        return false
    }
    
    func authenticateUser(){
        let scanner = LAContext()
        scanner.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "To Unlock \(username)"){(status, error) in
            if error != nil{
                print("Error")
                print(error!.localizedDescription)
                return
            }
            withAnimation(.easeOut){
                self.logged = true
            }
        }
    }
    
    func fetchCurrentAuthSession(){
        Amplify.Auth.fetchAuthSession { result in
            switch result {
            case.success(let session):
                print("Is user signed in - \(session.isSignedIn)")
                if session.isSignedIn {
                    self.logged = true
                }
            case.failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
    }
    
    func isLogged()->Bool{
        return logged
    }
    
    func logOut(){
        Amplify.Auth.signOut(){ result in
            switch result {
            case.success:
                print("Successfully signed out")
                self.logged = false
            case.failure(let error):
                print("Sign out failed with error \(error)")
                self.logged = true
            }
        }
    }
}

struct OTP: View {
    @State var start = false
    @State var to : CGFloat = 0
    @State var count = 0
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var otp1 = 0
    @State var otp2 = 0
    @State var otp3 = 0
    @State var otp4 = 0
    @State var otp5 = 0
    @State var otp6 = 0
    
    var body: some View{
        ZStack{
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            VStack{
                ZStack{
                    //Creditos a KAVSOFT por la idea de los circulos
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.black.opacity(0.09), style: StrokeStyle(lineWidth:35, lineCap: .round))
                        .frame(width: 280, height: 280)
                    
                    Circle()
                        .trim(from: 0, to: self.to)
                        .stroke(Color.red, style: StrokeStyle(lineWidth:35, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.init(degrees: -90))
                    
                    VStack{
                        Text("OTP")
                            .padding(.top)
                            .font(.system(size: 25))
                        Text("\(self.otp1)\(self.otp2)\(self.otp3)\(self.otp4)\(self.otp5)\(self.otp6)")
                            .fontWeight(.bold)
                            .font(.system(size: 40))
                            .padding(.top)
                    }
                }
                .onAppear{
                    getRandomNumbers()
                    self.start.toggle()
                }
            }
        }
        .onReceive(self.time, perform: { (_) in
            if self.start{
                if self.count != 60{
                    self.count += 1
                    withAnimation(.default){
                        self.to = CGFloat(self.count) / 60
                    }
                }
                else{
                    getRandomNumbers()
                        self.count = 0
                        withAnimation(.default){
                            self.to = 0
                        }
                }
            }
        })
    }
    
    func getRandomNumbers(){
        otp1 = Int.random(in: 0..<10)
        otp2 = Int.random(in: 0..<10)
        otp3 = Int.random(in: 0..<10)
        otp4 = Int.random(in: 0..<10)
        otp5 = Int.random(in: 0..<10)
        otp6 = Int.random(in: 0..<10)
    }
    
    func deleteRandomNumbers(){
        otp1 = 0
        otp2 = 0
        otp3 = 0
        otp4 = 0
        otp5 = 0
        otp6 = 0
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
