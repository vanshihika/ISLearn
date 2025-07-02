//
//  Supabase.swift
//  islearn
//
//  Created by student-2 on 01/04/25.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://ydhprtlbxlswgcscajdd.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlkaHBydGxieGxzd2djc2NhamRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDczMTA0MjEsImV4cCI6MjA2Mjg4NjQyMX0.WZn9mi4wjs19OPk09r1g7bzbWyKNznsMr6O9Y3j6daU"
        )

        Task {
            try await self.restoreSession()
        }
    }

    var auth: AuthClient {
        return client.auth
    }

    func saveSession(_ session: Session) {
            UserDefaults.standard.set(session.accessToken, forKey: "supabaseAccessToken")
            UserDefaults.standard.set(session.refreshToken, forKey: "supabaseRefreshToken")
        }

    func restoreSession() async throws {
        guard let accessToken = UserDefaults.standard.string(forKey: "supabaseAccessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "supabaseRefreshToken") else {
            print("No tokens found.")
            return
        }

        do {
            // Set the session
            try await auth.setSession(accessToken: accessToken, refreshToken: refreshToken)
            print("Session restored successfully.")
            
            // Now directly check if the user exists
            let user = try await auth.session.user
            if user != nil {
                print("✅ User session is active: \(user.id)")
                let profile = await ProfileDataModel.sharedInstance.fetchUserProfile(user: user)
                if profile.id == UUID() {
                    _ = try await ProfileDataModel.sharedInstance.createUserProfile(for: user)
                }
            } else {
                print("No current user profile found.")
            }
        } catch {
            print("Failed to restore session: \(error)")
            throw error
        }
    }

        func clearSession() {
            UserDefaults.standard.removeObject(forKey: "supabaseAccessToken")
            UserDefaults.standard.removeObject(forKey: "supabaseRefreshToken")
            Task {
                try? await auth.signOut()
            }
        }
        
        enum SessionError: Error {
            case noSessionFound
        }
    }
   
