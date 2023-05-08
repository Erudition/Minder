import { initialize } from "@ionic/core/components";
import { defineCustomElement as defineIonButton } from "@ionic/core/components/ion-button";
import { defineCustomElement as defineIonApp } from "@ionic/core/components/ion-app";
import { defineCustomElement as defineIonContent } from "@ionic/core/components/ion-content";
import { defineCustomElement as defineIonHeader } from "@ionic/core/components/ion-header";
import { defineCustomElement as defineIonFooter } from "@ionic/core/components/ion-footer";
import { defineCustomElement as defineIonToolbar } from "@ionic/core/components/ion-toolbar";
import { defineCustomElement as defineIonTabBar } from "@ionic/core/components/ion-tab-bar";
import { defineCustomElement as defineIonTab } from "@ionic/core/components/ion-tab";
import { defineCustomElement as defineIonTabButton } from "@ionic/core/components/ion-tab-button";
import { defineCustomElement as defineIonButtons } from "@ionic/core/components/ion-buttons";
import { defineCustomElement as defineIonTitle } from "@ionic/core/components/ion-title";
import { defineCustomElement as defineIonMenu } from "@ionic/core/components/ion-menu";
import { defineCustomElement as defineIonMenuButton } from "@ionic/core/components/ion-menu-button";
import { defineCustomElement as defineIonMenuToggle } from "@ionic/core/components/ion-menu-toggle";
import { defineCustomElement as defineIonSplitPane } from "@ionic/core/components/ion-split-pane";
import { defineCustomElement as defineIonList } from "@ionic/core/components/ion-list";
import { defineCustomElement as defineIonListHeader } from "@ionic/core/components/ion-list-header";
import { defineCustomElement as defineIonItem } from "@ionic/core/components/ion-item";
import { defineCustomElement as defineIonItemDivider } from "@ionic/core/components/ion-item-divider";
import { defineCustomElement as defineIonItemGroup } from "@ionic/core/components/ion-item-group";
import { defineCustomElement as defineIonItemOption } from "@ionic/core/components/ion-item-option";
import { defineCustomElement as defineIonItemOptions } from "@ionic/core/components/ion-item-options";
import { defineCustomElement as defineIonItemSliding } from "@ionic/core/components/ion-item-sliding";
import { defineCustomElement as defineIonInput } from "@ionic/core/components/ion-input";
//import { defineCustomElement as defineIonIcon } from "@ionic/core/components/ion-icon";




// Initializes the Ionic config and `mode` behavior
initialize();
//initialize({_forceStatusbarPadding: true}); // for status bar underlay, when I get that working

defineIonButton();
defineIonApp();
defineIonContent();
defineIonHeader();
defineIonFooter();
defineIonToolbar();
defineIonTabBar();
defineIonTab();
defineIonTabButton();
defineIonButtons();
defineIonTitle();
defineIonMenu();
defineIonMenuButton();
defineIonMenuToggle();
defineIonSplitPane();
defineIonList();
defineIonListHeader();
defineIonItem();
defineIonItemDivider();
defineIonItemGroup();
defineIonItemOption();
defineIonItemOptions();
defineIonItemSliding();
defineIonInput();
//defineIonIcon();
document.documentElement.classList.add('ion-ce');
