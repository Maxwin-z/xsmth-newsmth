var watch = require('watch');
var exec = require('child_process').exec;

watch.createMonitor('./', function (monitor) {
    monitor.files['./index.html', './SMApp.js'];
    monitor.on('changed', dopack);
});

function dopack () {
    console.log('changed', new Date());
    exec('./pack.sh', function (err, stdout, stderr) {
        console.log(stdout); 
    });
}

