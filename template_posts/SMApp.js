(function () {
    window.SMApp = window.SMApp || {};

    function extend(obj, props) {
        for (var i in props) {
            if (props.hasOwnProperty(i)) {
                obj[i] = props[i]; 
            }
        } 
    }

    var callbacks = [];
    var nope = function () {}

    extend(SMApp, {
        callback: function (callbackID, value) {
            var fn = callbacks[callbackID];
            if (typeof fn === 'function') {
                fn.apply(null, [value]);
            }
        },

        send_message: function (method, parameters, callback) {
            callback = callback || nope;
            parameters = parameters || {};
            callbacks.push(callback);
            var callbackID = callbacks.length - 1;
            parameters['callbackID'] = callbackID;
            var url = 'xsmth://_?method=' + method + '&parameters=' + encodeURIComponent(JSON.stringify(parameters));
            var ifr = document.createElement('iframe');
            ifr.style.display = 'none';
            document.body.appendChild(ifr);
            ifr.contentWindow.location.href = url;
            setTimeout(function () {
                document.body.removeChild(ifr);
            }, 0);
        },

        log: function (msg) {
            SMApp.send_message('log', {log: msg});
        },

        toast: function (msg) {
            SMApp.send_message('toast', {message: msg});
        },

        // apis
        ajax: function (opts) {
            var url = opts.url;
            var success = opts.success || nope;
            var fail = opts.fail || nope;
            SMApp.send_message('ajax', {url: url}, function (value) {
                if (value.response) {
                    success(value.response);
                } else {
                    fail(value.error); 
                }
            });
        },

        getPostInfo: function(callback) {
            SMApp.send_message('getPostInfo', {}, function (info) {
                console.log(info);
                callback(info);
            });
        },

        scrollTo: function (pos) {
            SMApp.send_message('scrollTo', {pos: pos});
        },

        getImageInfo: function (url, autoload, callback) {
            SMApp.send_message('getImageInfo', {url: url, autoload: autoload}, function (value) {
                callback(value);
            });
        },

        tapImage: function (url) {
            SMApp.send_message('tapImage', {url: url});
        },

        tapAction: function (pid) {
            SMApp.send_message('tapAction', {pid: pid});
        },

        savePostsInfo: function (info) {
        	SMApp.send_message('savePostsInfo', info);
        }
    });

})();

