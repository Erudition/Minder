import insertionQ from 'insertion-query'
import { initialize } from "@ionic/core/components";
import { defineCustomElement as defineIonButton } from "@ionic/core/components/ion-button";
import { defineCustomElement as defineIonApp } from "@ionic/core/components/ion-app";
import { defineCustomElement as defineIonHeader } from "@ionic/core/components/ion-header";
import { defineCustomElement as defineIonFooter } from "@ionic/core/components/ion-footer";
import { defineCustomElement as defineIonToolbar } from "@ionic/core/components/ion-toolbar";
import { defineCustomElement as defineIonTabBar } from "@ionic/core/components/ion-tab-bar";
import { defineCustomElement as defineIonTab } from "@ionic/core/components/ion-tab";
import { defineCustomElement as defineIonTabButton } from "@ionic/core/components/ion-tab-button";
import { defineCustomElement as defineIonButtons } from "@ionic/core/components/ion-buttons";
import { defineCustomElement as defineIonTitle } from "@ionic/core/components/ion-title";
//import { defineCustomElement as defineIonIcon } from "@ionic/core/components/ion-icon";

//import { defineCustomElement as defineIonIcon } from 'ionicons/components/ion-icon'
//import { stopCircleOutline } from 'ionicons/icons'


// Initializes the Ionic config and `mode` behavior
initialize();

defineIonButton();
defineIonApp();
defineIonHeader();
defineIonFooter();
defineIonToolbar();
defineIonTabBar();
defineIonTab();
defineIonTabButton();
defineIonButtons();
defineIonTitle();
//defineIonIcon();
document.documentElement.classList.add('ion-ce');









function clean(node)
{
    for(var n = 0; n < node.childNodes.length; n ++)
    {
        var child = node.childNodes[n];
        if
        (
        child.nodeType === 8 
        || 
        (child.nodeType === 3 && !/\S/.test(child.nodeValue))
        )
        {
        node.removeChild(child);
        console.log("removed a superflous node:", child, "from", node);
        n --;
        }
        else if(child.nodeType === 1)
        {
        clean(child);
        }
    }
}

insertionQ('ion-footer, ion-header').every(function(element){
    clean(element)
});