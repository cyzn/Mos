//
//  StatusItemManager.swift
//  Mos
//  管理状态栏图标以及初始化
//  Created by Caldis on 2018/3/7.
//  Copyright © 2018年 Caldis. All rights reserved.
//

import Cocoa

enum STATUS_ITEM_TYPE {
    case menu
    case popover
}

class StatusItemManager: NSMenu, NSMenuDelegate {
    
    // 状态栏类型
    let panelType = STATUS_ITEM_TYPE.popover
    
    // 状态栏引用
    static let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let item = StatusItemManager.statusItem
    
    override func awakeFromNib() {
        // 设置图标
        item.image = #imageLiteral(resourceName: "StatusBarIcon")
        // 设置事件响应
        switch panelType {
            // 类型: 菜单
            case STATUS_ITEM_TYPE.menu:
                // 设置菜单代理
                item.menu = self
                item.menu?.delegate = self
                break
            // 类型: 弹出面板
            case STATUS_ITEM_TYPE.popover:
                // 点击事件 (需要设置 target 才能响应此处方法)
                item.button?.action = #selector(onMenuClick)
                item.button?.target = self
                break
        }
    }
    
}

/**
 * 菜单响应
 **/
extension StatusItemManager {
    // 打开菜单
    func menuWillOpen(_ menu: NSMenu) {
        onMenuClick()
    }
    @objc func onMenuClick()  {
        switch panelType {
        // 类型: 菜单
        case STATUS_ITEM_TYPE.menu:
            if let event = NSApp.currentEvent {
                // 无辅助功能选项显示要求权限菜单
                guard AXIsProcessTrusted() else {
                    buildRequireAccessibilityMenu()
                    return
                }
                // 当按下 option 键显示特殊菜单
                guard !event.modifierFlags.contains(.option) else {
                    buildOptionMenu()
                    return
                }
                // 常规菜单
                buildNormalMenu()
            }
            break
        // 类型: 弹出面板
        case STATUS_ITEM_TYPE.popover:
            PopoverManager.shared.togglePopover(withIdentifier: POPOVER_IDENTIFIER.preferencesPopoverController, relativeTo: item.button!)
            break
        }
    }
}

/**
 * 菜单构建
 **/
extension StatusItemManager {
    // 无辅助功能访问权限菜单
    @objc func buildRequireAccessibilityMenu() {
        if let menu = item.menu {
            menu.removeAllItems()
            menu.addItem(withTitle: i18n.needsAccessToAccessibilityControls, action: #selector(accessibilityRequire), keyEquivalent: "").target = self
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: i18n.quit, action: #selector(quitClick), keyEquivalent: "").target = self
        }
    }
    @objc func accessibilityRequire() {
        Utils.requireAccessibilityPermissions()
    }
    // 按下 Option 按钮的菜单
    @objc func buildOptionMenu() {
        if let menu = item.menu {
            menu.removeAllItems()
            menu.addItem(withTitle: i18n.hideIcon, action: #selector(hideStatusItem), keyEquivalent: "").target = self
        }
    }
    @objc func hideStatusItem() {
        WindowManager.shared.showWindow(withIdentifier: WINDOW_IDENTIFIER.hideStatusItemWindowController, withTitle: "")
    }
    // 常规菜单
    @objc func buildNormalMenu() {
        if let menu = item.menu {
            menu.removeAllItems()
            menu.addItem(withTitle: i18n.monitor, action: #selector(monitorClick), keyEquivalent: "").target = self
            menu.item(at: 0)?.image = #imageLiteral(resourceName: "MonitorLogo")
            menu.addItem(withTitle: i18n.preferences, action: #selector(preferencesClick), keyEquivalent: "").target = self
            menu.item(at: 1)?.image = #imageLiteral(resourceName: "PreferencesLogo")
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: i18n.quit, action: #selector(quitClick), keyEquivalent: "").target = self
        }
    }
    @objc func monitorClick() {
        WindowManager.shared.showWindow(withIdentifier: WINDOW_IDENTIFIER.monitorWindowController, withTitle: "")
    }
    @objc func preferencesClick() {
        WindowManager.shared.showWindow(withIdentifier: WINDOW_IDENTIFIER.preferencesWindowController, withTitle: i18n.preferences)
    }
    @objc func quitClick() {
        NSApplication.shared.terminate(self)
    }
}

/**
 * 图标显示
 **/
extension StatusItemManager {
    // 显示状态栏图标
    class func showStatusItem() {
        StatusItemManager.statusItem.length = NSStatusItem.variableLength
    }
    // 隐藏状态栏图标
    class func hideStatusItem() {
        StatusItemManager.statusItem.length = 0.0
    }
}
