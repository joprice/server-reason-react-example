[%%raw "import '/ui/input.css'"];

switch (ReactDOM.querySelector("#root")) {
| Some(el) => ReactDOM.hydrate(<App serverUrl=None />, el)
| None => ()
};
