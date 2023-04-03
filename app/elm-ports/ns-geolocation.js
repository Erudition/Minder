import * as Geolocation from '@nativescript/geolocation';
import { CoreTypes } from "@nativescript/core";
export function addGeolocationPorts(elmPorts) {
    if (elmPorts.getCurrentLocation)
        elmPorts.getCurrentLocation.subscribe(async (_) => {
            await Geolocation.enableLocationRequest();
            const location = await Geolocation.getCurrentLocation({
                desiredAccuracy: CoreTypes.Accuracy.high,
                maximumAge: 5000,
                timeout: 20000
            });
            elmPorts.gotCurrentLocation.send(location);
        });
}
