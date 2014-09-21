function SMAppControl (domNode) {
    this.domNode = domNode;
    this.init();
}

$.extend(SMAppControl.prototype, {
    init: function () {
        this._touchStartTime = 0;
        this._touch = null;
        this._startEvent = null;

        this._longPressDelay = 0.5; // if user press more than {x}s, fire long press event;
        this._longPressTimer = null;
        this._longPressFired = false;
        this.highlight = true;

        $(this.domNode).addClass('SMAppControl');

        this.bindEvents();
    },

    bindEvents: function () {
        $(this.domNode).on('touchstart', $.proxy(this, 'onTouchStart'))
                    .on('touchend', $.proxy(this, 'onTouchEnd'))
                    .on('touchmove', $.proxy(this, 'onTouchMove'));

    },

    onTouchStart: function (evt) {
        this._touchStartTime = new Date().getTime();
        this._longPressFired = false;
        this._clearLongPressTimer();
        this._longPressTimer = setTimeout($.proxy(this, '_fireLongPress'), this._longPressDelay * 1000);
        this._startScrollTop = $(window).scrollTop();
        this._startScrollLeft = $(window).scrollLeft();
        this._scrolled = false;
        this._startEvent = evt;

        this.highlight && $(this.domNode).addClass('SMAppControl-highlight')

        // console.log(this.domNode, 'touchstart');
    },

    onTouchMove: function (evt) {
        this._clearLongPressTimer();

        var touch = evt.touches[0];
        if (touch) {
            this._touch = touch;
        }
        // console.log(this.domNode, evt);

        this._scrolled = true;
        this.highlight && $(this.domNode).removeClass('SMAppControl-highlight');
        /*
        var delta = 10;
        if (Math.abs($(window).scrollTop() - this._startScrollTop) > delta
            || Math.abs($(window).scrollLeft() - this._startScrollLeft) > delta) {
            this._scrolled = true;
        }
        */
    },

    onTouchEnd: function (evt) {
        this._clearLongPressTimer();
        if (this._longPressFired) return ;
        var touchInside = !this._touch || this._inRect({x: this._touch.pageX, y: this._touch.pageY}, $(this.domNode).offset());
        this.highlight && $(this.domNode).removeClass('SMAppControl-highlight');

        if (!this._scrolled) {
            touchInside ? this.onClick(this._startEvent) : this.onTouchUpOutside();
        }
        this._startEvent = null;
        this._touch = null;
        // console.log(this.domNode, this._touch, touchInside);
    },

    onClick: function () {

    },

    onTouchUpOutside: function () {

    },

    onLongPress: function () {

    },

    dispatchEvent: function (type, canBubble, cancelable /* ... */) {
        // @see https://developer.mozilla.org/en-US/docs/Web/API/event.initMouseEvent
        var evt = document.createEvent("MouseEvents");
        evt.initMouseEvent.apply(evt, Array.prototype.slice.call(arguments));
        this.domNode.dispatchEvent(evt);
    },

    _fireLongPress: function() {
        this.highlight && $(this.domNode).removeClass('SMAppControl-highlight');
        this._longPressFired = true;
        this.onLongPress();
    },

    _clearLongPressTimer: function () {
        if (this._longPressTimer != null) {
            clearTimeout(this._longPressTimer);
            this._longPressTimer = null;
        }
    },

    _inRect: function (point, rect) {
        return rect.left <= point.x && point.x <= rect.left + rect.width
            && rect.top <= point.y && point.y <= rect.top + rect.height;
    },


    emptyFn: function () {
    }
});
