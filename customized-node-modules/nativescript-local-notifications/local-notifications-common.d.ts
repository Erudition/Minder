import { Color } from "@nativescript/core/color/color";
export declare type ScheduleInterval = "second" | "minute" | "hour" | "day" | "week" | "month" | "quarter" | "year";
export interface NotificationAction {
    id: string;
    type: "button" | "input";
    title?: string;
    launch?: boolean;
    submitLabel?: string;
    placeholder?: string;
    editable?: boolean;
    choices?: Array<string>;
}
export interface ScheduleOptions {
    id?: number;
    title?: string;
    subtitle?: string;
    body?: string;
    ticker?: string;
    at?: Date;
    trigger?: "timeInterval";
    autoCancel?: boolean;
    badge?: number;
    sound?: string;
    vibratePattern?: Array<number>;
    color?: Color;
    interval?: ScheduleInterval;
    icon?: string;
    silhouetteIcon?: string;
    thumbnail?: boolean | string;
    ongoing?: boolean;
    groupedMessages?: Array<string>;
    groupSummary?: string;
    image?: string;
    bigTextStyle?: boolean;
    notificationLed?: boolean | Color;
    channel?: string;
    channelDescription?: string;
    forceShowWhenInForeground?: boolean;
    importance?: number;
    actions?: Array<NotificationAction>;
    expiresAfter?: number;
    progress?: number;
    progressMax?: number;
}
export interface ReceivedNotification {
    id: number;
    foreground: boolean;
    title?: string;
    body?: string;
    event?: string;
    response?: string;
}
export interface LocalNotificationsApi {
    schedule(options: ScheduleOptions[]): Promise<Array<number>>;
    addOnMessageReceivedCallback(onReceived: (data: ReceivedNotification) => void): Promise<any>;
    getScheduledIds(): Promise<number[]>;
    cancel(id: number): Promise<boolean>;
    cancelAll(): Promise<any>;
    hasPermission(): Promise<boolean>;
    requestPermission(): Promise<boolean>;
}
export declare abstract class LocalNotificationsCommon {
    protected static defaults: {
        badge: number;
        interval: any;
        ongoing: boolean;
        groupSummary: any;
        bigTextStyle: boolean;
        channel: string;
        forceShowWhenInForeground: boolean;
    };
    protected static merge(obj1: {}, obj2: {}): any;
    protected static generateUUID(): string;
    protected static generateNotificationID(): number;
    protected static ensureID(opts: ScheduleOptions): number;
}
