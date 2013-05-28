var $smth = {
    getData: function(json) {
        console.log(json);
        window.location.href = 'newsmth://' + JSON.stringify(json);
    }
};
