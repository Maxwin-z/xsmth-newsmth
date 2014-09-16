var $smth = {
    sendData: function(json) {
        console.log(json);
        window.location.href = 'newsmth://_?' + encodeURIComponent(JSON.stringify(json));
    }
};
