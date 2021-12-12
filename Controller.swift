//
//  GameController.swift
//  The Writing Dead
//
//  Created by six on 12/28/15.
//  Copyright © 2015 Apple. All rights reserved.
//
import GameController

protocol controlDelegate: AnyObject {
    func pause()
    func shhh()
    func releaseCat()
    func addZombie()
    func dropLastLetter()
    func scoreWord()
    func goLeft()
    func goRight()
    func goUp()
    func goDown()
    func goStop()
}

class Controller {
    weak var delegate: controlDelegate?

    var controller: GCController?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(Controller.handleControllerDidConnectNotification(_:)),    name: NSNotification.Name.GCControllerDidConnect,    object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Controller.handleControllerDidDisconnectNotification(_:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    @objc func handleControllerDidConnectNotification(_ notification: Notification) {
        //let connectedGameController = notification.object as! GCController
        
        controller = GCController.controllers().first
        if controller != nil {
            print("Controller detected")
            controller!.playerIndex = GCControllerPlayerIndex.index1
            controller!.controllerPausedHandler = handleControllerDidPause
            
            if let pad = controller?.extendedGamepad {
                pad.leftTrigger.pressedChangedHandler  = leftTrigger
                pad.rightTrigger.pressedChangedHandler = rightTrigger
                pad.buttonA.pressedChangedHandler      = buttonA
                //pad.buttonB
                //pad.buttonX
                //pad.buttonY
                pad.dpad.valueChangedHandler = dpad
            }
        }
    }
    
    @objc func handleControllerDidDisconnectNotification(_ notification: Notification) {
        let disconnectedGameController = notification.object as! GCController
        
        if disconnectedGameController == controller {
            controller = nil
        }
    }
    
    func handleControllerDidPause(_ controller: GCController) {
        delegate?.pause()
    }
    
    func leftTrigger(_ button: GCControllerButtonInput, value: Float,  pressed: Bool) {
        if pressed {
            delegate?.shhh()
        }
    }
    
    func rightTrigger(_ button: GCControllerButtonInput, value: Float,  pressed: Bool) {
        if pressed {
            delegate?.releaseCat()
        }
    }

//# MARK: - buttins
    func buttonA(_ button: GCControllerButtonInput, value: Float,  pressed: Bool) {
        if pressed {
            delegate?.dropLastLetter()
        }
    }
    
    func buttonB(_ button: GCControllerButtonInput, value: Float,  pressed: Bool) {
        if pressed {
            delegate?.addZombie()
        }
    }
    
    func buttonX(_ button: GCControllerButtonInput, value: Float,  pressed: Bool) {
        if pressed {
            delegate?.scoreWord()
        }
    }

//# MARK: - dpad
    func dpad(_ pad: GCControllerDirectionPad, x: Float, y: Float) {
        if x == 0.0 && y == 0.0 {
            delegate?.goStop()
        }
        else if x != 0.0 {
            if x < 0.0 { // #MARK: dpad left
                delegate?.goLeft()
            }
            else { // #MARK: dpad right
                delegate?.goRight()
            }
        }
        else if y != 0.0 {
            if y < 0.0 { // #MARK: dpad down
                delegate?.goDown()
            }
            else { // #MARK: dpad up
                delegate?.goUp()
            }
        }
    }
}
