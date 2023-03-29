$(window).load(function () {
    var app = new Application(),
        loader = new Loader(),
        delay = 100;

    loader.wait(app.run, delay);
});