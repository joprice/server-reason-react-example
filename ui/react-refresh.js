// See https://vitejs.dev/guide/backend-integration.html for instructions on integrating vite with
// a non-js backend
import RefreshRuntime from "http://localhost:5173/@react-refresh";
RefreshRuntime.injectIntoGlobalHook(window);
window.$RefreshReg$ = () => {};
window.$RefreshSig$ = () => (type) => type;
window.__vite_plugin_react_preamble_installed__ = true;
