
import '../../node_modules/bootstrap-scss/bootstrap.scss';
import { Elm } from "../elm/Main.elm";

(function () {
    var startup = function () {
        // Start the Elm App.

        var app = Elm.Main.init({
            node: document.getElementById('main')
        });

        var xhr = new XMLHttpRequest();
        xhr.addEventListener('load', function (data) {
            console.log(data);
        });
        xhr.open('POST', '.netlify/functions/process');
        xhr.setRequestHeader('content-type', 'application/json');
        xhr.send(JSON.stringify({ 'by_state': 'michigan', 'by_city': 'ferndale' }));

    }

    window.addEventListener('load', startup, false);
}());