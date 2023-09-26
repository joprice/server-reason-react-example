// this open allows hiding internal modules to avoid breaking React's Fast Refresh
open {
       let showPath = (url: ReasonReactRouter.url) => {
         "/" ++ (url.path |> String.concat("/"));
       };

       module Counter = {
         [@react.component]
         let make = () => {
           let (count, setCount) = React.useState(() => 4);
           <div className="flex justify-center w-full">
             <div className="flex flex-col justify-center mt-8 w-1/4">
               <div className="flex justify-center mb-4 text-8xl text-white">
                 {React.string(string_of_int(count))}
               </div>
               <button
                 onClick={_ => setCount(count => count + 1)}
                 type_="button"
                 className="rounded-md bg-white/10 px-3.5 py-2.5 text-lg font-semibold text-white shadow-sm hover:bg-white/20">
                 {React.string("Increment")}
               </button>
             </div>
           </div>;
         };
       };

       module Home = {
         [@react.component]
         let make = () => {
           <div className="flex flex-row w-full justify-center">
             <div
               className="flex flex-col text-white text-center w-1/2 text-4xl">
               {React.string("Server Reason React")}
             </div>
           </div>;
         };
       };

       module NotFound = {
         [@react.component]
         let make = (~url) => {
           <div className="flex flex-row w-full justify-center">
             <div className="text-white text-2xl">
               {React.string("Not found: " ++ showPath(url))}
             </div>
           </div>;
         };
       };

       module Link = {
         [@react.component]
         let make = (~href, ~text) => {
           <a
             className="text-white"
             onClick={e => {
               ReactEvent.Mouse.preventDefault(e);
               ReasonReactRouter.push(href);
             }}
             href>
             {React.string(text)}
           </a>;
         };
       };
     };

[@react.component]
let make = (~serverUrl) => {
  let url =
    serverUrl
    |> Option.value(~default=ReasonReactRouter.useUrl(~serverUrl?, ()));
  let page =
    switch (url.path) {
    | [] => <Home />
    | ["counter"] => <Counter />
    | _ => <NotFound url />
    };
  <main id="main">
    <div className="flex flex-col">
      <div className="text-white p-4">
        <div> {React.string("Current path: " ++ showPath(url))} </div>
        <div className="hover:underline"> <Link href="/" text="home" /> </div>
        <div className="hover:underline">
          <Link href="/counter" text="counter" />
        </div>
        <div className="hover:underline">
          <Link href="/does-not-exist" text="missing" />
        </div>
      </div>
      page
    </div>
  </main>;
};
