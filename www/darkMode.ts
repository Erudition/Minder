
export function detectDarkMode() {
    // Use matchMedia to check the user preference
const prefersLight = window.matchMedia('(prefers-color-scheme: light)');
console.log("Prefers light theme?", prefersLight)
toggleDarkTheme(!prefersLight.matches);

// Listen for changes to the prefers-color-scheme media query
prefersLight.addListener((mediaQuery) => toggleDarkTheme(!mediaQuery.matches));
}


// Add or remove the "dark" class based on if the media query matches
export function toggleDarkTheme(shouldAdd) {
  const ionApp = document.getElementById("ion-app");
  if (ionApp) {ionApp.classList.toggle('dark', shouldAdd);} else {console.error("can't find #ion-app for dark mode")}
}
globalThis.toggleDarkTheme = (darkBool) => toggleDarkTheme(darkBool);
