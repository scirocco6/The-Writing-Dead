//
//  GameController.swift
//  The Writing Dead
//
//  Created by six on 12/28/15.
//  Copyright © 2015 Apple. All rights reserved.
//
import GameController

protocol controlDelegate: class {
    func pause()
    func shhh()
    func releaseCat()
    func addZombie()
}

class Controller {
    weak var delegate: controlDelegate?

    var controller: GCController?
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleControllerDidConnectNotification:",    name: GCControllerDidConnectNotification,    object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleControllerDidDisconnectNotification:", name: GCControllerDidDisconnectNotification, object: nil)
    }
    
    @objc func handleControllerDidConnectNotification(notification: NSNotification) {
        //let connectedGameController = notification.object as! GCController
        
        controller = GCController.controllers().first
        if controller != nil {
            print("Controller detected")
            controller!.playerIndex = GCControllerPlayerIndex.Index1
            controller!.controllerPausedHandler = handleControllerDidPause
            
            if let pad = controller?.extendedGamepad {
                pad.leftTrigger.pressedChangedHandler  = leftTrigger
                pad.rightTrigger.pressedChangedHandler = rightTrigger
                pad.buttonA.pressedChangedHandler      = buttonA
                //pad.buttonB
                //pad.buttonX
                //pad.buttonY
            }
        }
    }
    
    @objc func handleControllerDidDisconnectNotification(notification: NSNotification) {
        let disconnectedGameController = notification.object as! GCController
        
        if disconnectedGameController == controller {
            controller = nil
        }
    }
    
    func handleControllerDidPause(controller: GCController) {
        delegate?.pause()
    }
    
    func leftTrigger(button: GCControllerButtonInput, value: Float,  pressed: Bool) {
        if pressed {
            delegate?.shhh()
        }
    }
    
    func rightTrigger(button: GCControllerButtonInput, value: Float,  pressed: Bool) {
        if pressed {
            delegate?.releaseCat()
        }
    }
    
    func buttonA(button: GCControllerButtonInput, value: Float,  pressed: Bool) {
        if pressed {
            delegate?.addZombie()
        }
    }
}