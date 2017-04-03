setTimeout(function(){
	console.log("done");
}, 2000);

AudioContext = require('web-audio-api').AudioContext;
var vm = require("vm");
var fs = require("fs");
var data = fs.readFileSync("./trombone.js");
vm.runInThisContext(data);
UI.startMouse();


