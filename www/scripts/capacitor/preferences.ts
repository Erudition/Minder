import * as TaskPort from 'elm-taskport';
import { Preferences } from '@capacitor/preferences';


export async function registerPreferencesTaskPorts() {
    TaskPort.register("setPreference", Preferences.set);
    TaskPort.register("clearPreferences", Preferences.clear)
}