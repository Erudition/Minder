
export function detectDarkMode() {
    // Use matchMedia to check the user preference
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');

toggleDarkTheme(prefersDark.matches);

// Listen for changes to the prefers-color-scheme media query
prefersDark.addListener((mediaQuery) => toggleDarkTheme(mediaQuery.matches));
}


// Add or remove the "dark" class based on if the media query matches
export function toggleDarkTheme(shouldAdd) {
  document.body.classList.toggle('dark', shouldAdd);
}