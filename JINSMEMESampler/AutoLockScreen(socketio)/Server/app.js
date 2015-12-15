var io = require('socket.io')(8080);
var userHash = {};

io.on('connection', function (socket) {

    console.log(socket.id + ' has connected!');

    socket.on("connected", function (name) {
      userHash[socket.id] = name;
      console.log("stocked " + name);
    });

    socket.on("publish", function (data) {
      console.log("publish: " + data);
      io.sockets.emit("publish", data);
    });

    socket.on("disconnect", function () {
      console.log(socket.id + " has disconnected!");
      if (userHash[socket.id]) {
        var name = userHash[socket.id];
        delete userHash[socket.id];
        io.sockets.emit("exit", name);
      }
    });
});
