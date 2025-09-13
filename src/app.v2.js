// Looking for a fancy multi-megabyte JavaScript application? Move along,
// nothing to see here: We <3 progressive enhancement and having *just enough*
// hand-crafted JavaScript to enhance user experience over vanilla behavior.
// Like what you're seeing? Let's get in touch via https://clue.engineering/contact
(function() {
    function init() {
        /* follow anchors without hash without reloading page */
        document.querySelectorAll("div[class^=tagged-] a, .overlay a").forEach(function (elem) {
            elem.addEventListener("click", function (ev) {
                window.location.hash = '';
                history.replaceState({}, document.title, window.location.pathname);
                ev.preventDefault();
            });
        });
    };
    document.readyState == "loading" ? window.addEventListener("DOMContentLoaded", init()) : init();
})();
