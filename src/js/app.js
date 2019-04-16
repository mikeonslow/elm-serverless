import { Elm } from "../elm/Main.elm";

(function () {
    var startup = function () {
        // Start the Elm App.

        var app = Elm.Main.init({
            node: document.getElementById('main')
        });
    }

    window.addEventListener('load', startup, false);
}());