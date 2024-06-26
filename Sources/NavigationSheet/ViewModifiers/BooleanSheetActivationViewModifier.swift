//
//  File.swift
//
//
//  Created by Archibbald on 27.01.2024.
//

import SwiftUI

public struct BooleanSheetActivationViewModifier<SheetContent: View>: ViewModifier {
    
    @Binding var sheetActive: Bool
    @ViewBuilder var content: () -> SheetContent
    
    @EnvironmentObject var sheetModel: SheetViewModel
    @EnvironmentObject var configModel: ConfigurationViewModel
    
    @Environment(\.hostingController) var controller
    @Environment(\.self) var environments
    
    public func body(content: Content) -> some View {
        let _ = update()
        
        content
            .background {
                Color.clear
                    .onAppear(perform: onCreate)
                    .onChange(of: sheetActive) { active in
                        guard active != sheetModel.sheetActive else { return }
                        
                        sheetModel.controller = controller ?? configModel.rootViewController
                        sheetModel.configuration = configModel
                        sheetModel.environments = environments
                        
                        if active {
                            sheetModel.present(content: self.content)
                        } else {
                            sheetModel.dismiss()
                        }
                    }
                    .onReceive(
                        sheetModel.$sheetActive
                            .dropFirst()
                            .receive(on: RunLoop.main)
                            .removeDuplicates()
                    ) { active in
                        guard active != sheetActive else { return }
                        
                        sheetActive = active
                    }
            }            
    }
    
    // MARK: - Sheet settings    
    private func onCreate() {
        guard sheetActive else { return }
        
        sheetModel.controller = controller ?? configModel.rootViewController
        sheetModel.configuration = configModel  
        sheetModel.environments = environments
        sheetModel.present(content: content)
    }
    
    private func update() {
        sheetModel.hostingController?.rootView = sheetModel.prepare(content: content)
    }
}
