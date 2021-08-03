//
//  ContentView.swift
//  HeteroTaskGroupChallenge
//
//  Created by Russell Gordon on 2021-08-03.
//

import SwiftUI

// This is the bit that lets us handle task groups with heterogeneous types
// Associated values to the enum cases
enum FetchResult {
    case user(User)
    case messages([Message])
    case favourites(Favourites)
}

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .task(loadData)
    }
    
    func loadData() async {
        
        let consolidatedUser = await withThrowingTaskGroup(of: FetchResult.self) { group -> ConsolidatedUser in

            group.addTask {
                let url = URL(string: "https://www.hackingwithswift.com/samples/username.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = String(decoding: data, as: UTF8.self)
                return .user(result)
            }
            
            group.addTask {
                let url = URL(string: "https://www.hackingwithswift.com/samples/user-messages.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode([Message].self, from: data)
                return .messages(result)
            }

            group.addTask {
                let url = URL(string: "https://www.hackingwithswift.com/samples/user-favorites.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode(Favourites.self, from: data)
                return .favourites(result)
            }

            // Now, what did we actually get back?
            var user = ""
            var messages = [Message]()
            var favourites = Set<Int>()
            
            do {
                // Here we unpack the enum
                // I've got a FetchResult
                // What kind of FetchResult? What's inside you? Scores, OK, take and put in [Scores] array, etc
                for try await value in group {
                    // What is this value? NewsStory? or Score?
                    switch value {
                    case .user(let downloadedUser):
                        user = downloadedUser
                    case .messages(let downloadedMessages):
                        messages = downloadedMessages
                    case .favourites(let downloadedFavourites):
                        favourites = Set(downloadedFavourites)
                    }
                }
            } catch DecodingError.keyNotFound(let key, let context) {
                Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
            } catch DecodingError.valueNotFound(let type, let context) {
                Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
            } catch DecodingError.typeMismatch(let type, let context) {
                Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
            } catch DecodingError.dataCorrupted(let context) {
                Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
            } catch let error as NSError {
                NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
            }
            
            return ConsolidatedUser(username: user,
                                    messages: messages,
                                    favourites: favourites)
            
        }

        print("DRUM ROLL PLEASE...")
        print(consolidatedUser)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
