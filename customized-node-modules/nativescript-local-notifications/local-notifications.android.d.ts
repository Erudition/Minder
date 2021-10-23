import { LocalNotificationsApi, LocalNotificationsCommon, ReceivedNotification, ScheduleOptions } from "./local-notifications-common";
export declare class LocalNotificationsImpl extends LocalNotificationsCommon implements LocalNotificationsApi {
    private static IS_GTE_LOLLIPOP;
    private static getInterval;
    private static getIcon;
    private static cancelById;
    hasPermission(): Promise<boolean>;
    requestPermission(): Promise<boolean>;
    addOnMessageReceivedCallback(onReceived: (data: ReceivedNotification) => void): Promise<any>;
    addOnMessageClearedCallback(onReceived: (data: ReceivedNotification) => void): Promise<any>;
    cancel(id: number): Promise<boolean>;
    cancelAll(): Promise<void>;
    getScheduledIds(): Promise<number[]>;
    schedule(scheduleOptions: ScheduleOptions[]): Promise<Array<number>>;
}
export declare const LocalNotifications: LocalNotificationsImpl;
