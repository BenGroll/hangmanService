document.addEventListener("DOMContentLoaded", function () {
    
    const hangman = document.getElementById("hangman");

    if (!hangman) {
        return;
    }

    hangman.addEventListener("click", function (event) {

        const date = new Date();

        const formattedDate = date.toLocaleString('de-DE');

        event.target.dispatchEvent(new CustomEvent("notify", {
            bubbles: true,
            detail: {
                text: formattedDate + " - Hangman!"
            },
        }));

    });

});
