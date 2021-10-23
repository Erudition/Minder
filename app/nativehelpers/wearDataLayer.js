// WEAR OS DATA CLIENT

import { Utils, Device } from '@nativescript/core'

if (global.isAndroid) {

    // The Wearable Api, as found in Google play services
    const wearable = com.google.android.gms.wearable.Wearable
    const putDataRequestNamespace = com.google.android.gms.wearable.PutDataRequest

    // The API for working with the wearable data layer. Needs to be passed a context.
    let dataClient =  wearable.getDataClient(Utils.android.getApplicationContext());

    // the data I want to store
    let demoByteArray = [0];

    // creates a DataItem to be put, setting the path, the urgency, and finally adding the data
    let putDataRequest =  putDataRequestNamespace.create("/profile");
    putDataRequest.setUrgent();
    putDataRequest.setData(demoByteArray);

    // turn that request into a Task that will return a DataItem on success.
    let putItemTask = dataClient.putDataItem(putDataRequest);



    let getItemsTask = dataClient.getDataItems(android.net.Uri.parse("wear://*/profile"));

    var myListener = new com.google.android.gms.tasks.OnSuccessListener( {
         onSuccess : function (dataItemBuffer) {
             console.log("task completed successfully")


             let foundNodes = dataItemBuffer.getCount();
             console.log("Found " + foundNodes + " data items.");

             if (foundNodes > 0) {
                 let dataItemZero = dataItemBuffer.get(0);
                 let storedData = dataItemZero.getData();
                 console.log("data item 0 is stored as: " + storedData);
             }
         }
    });

    getItemsTask.addOnSuccessListener(myListener);


    var myPutListener = new com.google.android.gms.tasks.OnSuccessListener( {
         onSuccess : function (dataItem) {
             console.log("task completed successfully")
             console.log("data item " + dataItem);

             let putLocation = dataItem.getUri();
             console.log("Put the new data item at " + putLocation + " .")
         }
    });

    putItemTask.addOnSuccessListener(myPutListener);



}
